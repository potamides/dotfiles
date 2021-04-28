from subprocess import PIPE
from shlex import quote
from ranger.api.commands import Command
from ranger.core.loader import CommandLoader
from os.path import isdir, abspath, basename

class umount(Command):
    """
    :umount [device_mount_point]

    unmount removable devices
    """

    def execute(self):
        cmd = "umount "
        if self.arg(1):
            self.fm.run(cmd + quote(self.arg(1)))
        else:
            self.fm.run(cmd + quote(self.fm.thisfile.path))

class toggle_flat(Command):
    """
    :toggle_flat

    Flattens or unflattens the directory view.
    """

    def execute(self):
        if self.fm.thisdir.flat == 0:
            self.fm.thisdir.unload()
            self.fm.thisdir.flat = -1
            self.fm.thisdir.load_content()
        else:
            self.fm.thisdir.unload()
            self.fm.thisdir.flat = 0
            self.fm.thisdir.load_content()

class fzf_select(Command):
    """
    :fzf_select

    Find a file using fzf.

    With a prefix argument select only directories.

    See: https://github.com/junegunn/fzf
    """
    def execute(self):
        if self.quantifier:
            # match only directories
            command="find -L . \( -path '*/\.*' -o -fstype 'dev' -o -fstype 'proc' \) -prune \
            -o -type d -print 2> /dev/null | sed 1d | cut -b3- | fzf +m"
        else:
            # match files and directories
            command="find -L . \( -path '*/\.*' -o -fstype 'dev' -o -fstype 'proc' \) -prune \
            -o -print 2> /dev/null | sed 1d | cut -b3- | fzf +m"
        fzf = self.fm.execute_command(command, universal_newlines=True, stdout=PIPE)
        stdout, _ = fzf.communicate()
        if fzf.returncode == 0:
            fzf_file = abspath(stdout.rstrip('\n'))
            if isdir(fzf_file):
                self.fm.cd(fzf_file)
            else:
                self.fm.select_file(fzf_file)


class extracthere(Command):
    def execute(self):
        """
        :extracthere

        Extract copied files to current directory
        """
        copied_files = tuple(self.fm.copy_buffer)

        if not copied_files:
            return

        def refresh(_):
            cwd = self.fm.get_directory(original_path)
            cwd.load_content()

        one_file = copied_files[0]
        cwd = self.fm.thisdir
        original_path = cwd.path
        au_flags = ['-X', cwd.path]
        au_flags += self.line.split()[1:]
        au_flags += ['-e']

        self.fm.copy_buffer.clear()
        self.fm.cut_buffer = False
        if len(copied_files) == 1:
            descr = "extracting: " + basename(one_file.path)
        else:
            descr = "extracting files from: " + basename(one_file.dirname)
        obj = CommandLoader(args=['aunpack'] + au_flags + [f.path for f in copied_files], descr=descr)

        obj.signal_bind('after', refresh)
        self.fm.loader.add(obj)
