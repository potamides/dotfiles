# pylint: disable=no-self-use,too-few-public-methods
"""
Confload: Create dotfiles-managable weechat configs with password manager integration.

    * reads config file containing weechat commands with m4 macro processor
    * config file is expected to be in $WEECHAT_HOME/weechatrc
    * provides special m4 macro KEEPASS(<title>, <attr>) to read KeePassXC database
    * specify KeyPassXC files with KEYPASSXC_DATABASE and KEYPASSXC_KEYFILE env vars
"""
from subprocess import check_output, CalledProcessError
from os import getenv
from os.path import join
from shlex import quote
from abc import ABC
import weechat as w # pylint: disable=import-error
import __main__

DATABASE = getenv("KEYPASSXC_DATABASE", "~/Passwords.kdbx")
KEYFILE = getenv("KEYPASSXC_KEYFILE", "~/Secret.key")
TEMPLATE = join(getenv("WEECHAT_HOME", join(getenv("HOME"), ".weechat")), "weechatrc")

class Confload():
    """Preprocess config file and execute execute commands."""
    keexc = "keepassxc-cli show --quiet --attributes $2 --key-file {} {} $1 <<< {}"
    abort = "ifelse(eval(sysval != 0), 1, `m4exit(sysval)')dnl"
    commands = None

    def preprocess(self, password):
        """Preprocess weechat config file."""
        keexc = self.keexc.format(KEYFILE, DATABASE, quote(password))
        try:
            self.commands = check_output(["m4", "-DKEEPASS=syscmd(" + keexc + ")"
                                          + self.abort, TEMPLATE])
            return True
        except CalledProcessError:
            return False

    def execute_commands(self):
        """Execute weechat commands."""
        for command in self.commands.splitlines():
            if command.strip():
                w.command("", command.decode())

class CallbackCreator(ABC):
    """Base class used by classes who must specify weechat callbacks as strings."""

    def callback(self, method):
        """This function will take a bound method or function and make it a callback."""
        name = str(id(method))
        setattr(__main__, name, method)
        return name


class CommandAdder(CallbackCreator):
    """Add weechat command to trigger confload manually."""
    confload = Confload()

    def add_command(self):
        """Add command and create callbacks."""
        name = "confload"
        desc = "Load $WEECHAT_HOME/weechatrc. Expects KeePassXC passphrase"
        args = "<passphrase>"

        w.hook_command(name, desc, args, '', '', self.callback(self.command_cb), '')
        w.hook_modifier("input_text_display", self.callback(self.passwd_conceil_cb), "")

    def command_cb(self, data, buffer, password):
        """Callback for command hook which triggers processing of config file."""
        if self.confload.preprocess(password):
            self.confload.execute_commands()
            return w.WEECHAT_RC_OK
        w.prnt("", "{}Something went wrong! Maybe wrong password?".format(w.prefix("error")))
        return w.WEECHAT_RC_ERROR

    def passwd_conceil_cb(self, data, modifier, modifier_data, string):
        """Callback for hook which hides password when entering command."""
        prefix = "/confload "
        if string.startswith(prefix):
            return prefix + (len(string) - len(prefix)) * "*"
        return string

class Initializer(CallbackCreator):
    """Class which initializes stuff when loading confload for the first time."""
    option = "initialized"
    confload = Confload()
    passwd_conceil_hook = None
    passwd_grab_hook = None

    @staticmethod
    def initialized():
        """Returns true when loading confload for the first time else false."""
        return w.config_get_plugin(Initializer.option) == "on"

    def initialize(self):
        """Create hooks to grab all user input to obtain KeePassXC password."""
        w.config_set_desc_plugin(
            self.option,
            "If not yet initialized, run once. (default: \"off\")")
        self.passwd_conceil_hook = w.hook_modifier(
            "input_text_display_with_cursor",
            self.callback(self.passwd_conceil_cb),
            "")
        self.passwd_grab_hook = w.hook_modifier(
            "input_text_for_buffer",
            self.callback(self.passwd_grab_cb),
            "")

    def is_command(self, cmd):
        """Check if string is a valid weechat command."""
        if cmd.startswith("/") and not cmd.startswith("//"):
            return True
        return False

    def passwd_conceil_cb(self, data, modifier, modifier_data, string):
        """Add a prompt to notify user and mask all user input."""
        prompt = f"Enter password to unlock {DATABASE}: "
        if self.is_command(string):
            return prompt + string
        return prompt + (len(string) - 3) * "*" + string[-3:]

    def passwd_grab_cb(self, data, modifier, modifier_data, string):
        """Check if user input is a potential password and try to load config."""
        if self.is_command(string):
            return string
        if self.confload.preprocess(string):
            self.confload.execute_commands()
            self.cleanup_and_finish()
            return "/input delete_line"
        w.prnt("", "{}Something went wrong! Maybe wrong password?".format(w.prefix("error")))
        return ""

    def cleanup_and_finish(self):
        """Remove all hooks and set a config option to remember that confload is initialized."""
        w.unhook(self.passwd_conceil_hook)
        w.unhook(self.passwd_grab_hook)
        w.config_set_plugin(self.option, "on")

def register_script():
    """Register the script for weechat."""
    name = "confload"
    author = "potamides"
    version = "0.1"
    license_ = "GPL3"
    desc = __doc__

    return w.register(name, author, version, license_, desc, "", "")

if __name__ == "__main__" and register_script():
    if not Initializer.initialized():
        Initializer().initialize()
    CommandAdder().add_command()
