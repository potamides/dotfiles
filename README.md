<p align="center">
  <img alt="🍚 Dotfiles" width="100%" src="https://gist.githubusercontent.com/potamides/35387b4d0c47aea421f75aa0b9f78b5f/raw/dotfiles-headline.svg"/>
</p>

---

<p align="center">
  <img alt="CRT Monitor with rice" width="60%" src="https://gist.githubusercontent.com/potamides/35387b4d0c47aea421f75aa0b9f78b5f/raw/1146067037af8bc8f87850e36a06f63c1f365591/rice-crt.svg"/>
</p>

---

This is a repository for configuration files of various applications that I use
on a daily basis. My goal is to find a satisfactory balance between
functionality and design, while keeping an eye on resource consumption. I put a
lot of care into a consistent look, that is easy on the eyes and try to use the
[gruvbox](https://github.com/morhetz/gruvbox) colorscheme for everything.

## Installation
**Disclaimer:** The steps below are highly tailored to my needs and I would
advise anyone else to review each instruction and only proceed if they know
what it is doing.

If you just want to hack at your own leisure, this repository and its
submodules can be cloned with the following command:
```sh
git clone --recurse-submodules https://github.com/potamides/dotfiles
```

Alternatively it can be installed as a bare git repository, which allows for
efficient dotfiles management without having to rely on additional external
tools <sup> [1](https://news.ycombinator.com/item?id=11070797),
[2](https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo/),
[3](https://harfangk.github.io/2016/09/18/manage-dotfiles-with-a-git-bare-repository.html)
</sup>. For that the project contains a [script](.local/bin/install-dotfiles),
that places administrative files in `$HOME/.dotfiles` and updates configuration
files in `$HOME` with the content of the repository (**warning:** this
overwrites existing files). For convenience the script can be executed like so:
```sh
bash <(curl -LfsS https://github.com/potamides/dotfiles/raw/master/.local/bin/install-dotfiles)
```

With a simple alias (already included in [bashrc](.bashrc)) this dotfiles
project can then be managed like any other git repository:
```sh
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```

This repository also contains a [script](.local/bin/install-packages) which can
be used to install all required packages, note however that it is specific to
[Arch Linux](https://www.archlinux.org/). When this script is sourced it
defines the array variables `PKG`, `PIP` and `AUR`. You can then use `pacman`,
`pip` and an [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers) of
your choice to install everything:
```sh
source <(curl -LfsS https://github.com/potamides/dotfiles/raw/master/.local/bin/install-packages)
sudo pacman -S "${PKG[@]}" && yay -Sa "${AUR[@]}" && pip install "${PIP[@]}" --user
```

## Contents
The project contains configuration files for the following programs. Many
applications are straightforward to use. For programs where I developed a more
individual workflow, I give basic usage instructions below.
| | Name | Files \& Directories | Links |
|-| ---- | ------- | ----- |
| **Shell**                | bash     | [.inputrc](.inputrc), [.bashrc](.bashrc), [.bash\_profile](.bash_profile) | [Repository](https://git.savannah.gnu.org/cgit/bash.git), [Homepage](https://www.gnu.org/software/bash/) |
| **Window Manager**       | awesome  | [.config/awesome](.config/awesome), [.xinitrc](.xinitrc) | [Repository](https://github.com/awesomeWM/awesome), [Homepage](https://awesomewm.org/) |
| **Editor**               | neovim   | [.config/nvim](.config/nvim) | [Repository](https://github.com/neovim/neovim), [Homepage](https://neovim.io/) |
| **Terminal**             | termite  | [.config/termite](.config/termite) | [Repository](https://github.com/thestinger/termite) | 
| **Terminal Multiplexer** | tmux     | [.tmux.conf](.tmux.conf) | [Repository](https://github.com/tmux/tmux), [Homepage](https://tmux.github.io) |
| **Music Player**         | ncmpcpp  | [.config/ncmpcpp](.config/ncmpcpp) | [Repository](https://github.com/ncmpcpp/ncmpcpp), [Homepage](https://rybczak.net/ncmpcpp/) |
| **System Monitor**       | conky    | [.conkyrc](.conkyrc) | [Repository](https://github.com/brndnmtthws/conky), [Homepage](https://github.com/brndnmtthws/conky/wiki) |
| **Mail Client**          | mutt     | [.config/mutt](.config/mutt) | [Repository](https://gitlab.com/muttmua/mutt), [Homepage](http://www.mutt.org/) |
| **IRC Client**           | weechat  | [.config/weechat](.config/weechat) | [Repository](https://github.com/weechat/weechat), [Homepage](https://weechat.org/) |
| **File Manager**         | ranger   | [.config/ranger](.config/ranger) | [Repository](https://github.com/ranger/ranger), [Homepage](https://ranger.github.io/) |
| **Calculator**           | ptpython | [.config/ptpython](.config/ptpython) | [Repository](https://github.com/prompt-toolkit/ptpython) |
| **Calendar**             | when     | [.when](.when) | [Repository](https://github.com/bcrowell/when), [Homepage](http://www.lightandmatter.com/when/when.html) |
| **Document Viewer**      | qpdfview | [.config/qpdfview](.config/qpdfview) | [Homepage](https://launchpad.net/qpdfview) |

Completely independent from the aforementioned applications this repository
also contains some additional [scripts](.local/bin), that can be used to
automate various tasks.

### Awesome
Instead of the standard
[awful.key](https://awesomewm.org/doc/api/libraries/awful.key.html)
keybindings, this configuration uses
[modalawesome](https://github.com/potamides/modalawesome) to create vi-like
keybindings with motions, counts and multiple modes. To understand how to
control my awesome configuration, I recommend to check it out beforehand.

Additionally, if an [mpd](https://www.musicpd.org/) server is running on
`$MPD_HOST:$MPD_PORT`, song information is displayed in the status bar. Songs
are also played back via [mpv](https://mpv.io/) by listening on
`$MPD_HOST:$MPD_STREAM_PORT`. In my case, all my audio files are located on a
server and to connect to its mpd instance I use an ssh tunnel via a [systemd
user service](.config/systemd/user/mpd-tunnel.service):
```sh
systemctl --user enable --now mpd-tunnel
```

### Mutt
Mutt is configured for multiple email accounts. It makes use of the command
line tool distributed with [KeePassXC](https://keepassxc.org/) to access
passwords. The location of the password database and the keyfile can be
controlled with the `KEEPASSXC_DATABASE` and `KEEPASSXC_KEYFILE` environment
variables.

Mutt also contains a [script](.config/mutt/scripts/create-alias.sh) which
automatically creates aliases for addresses in the `FROM` field, when reading
an email. It also utilizes the
[markdown2html](https://git.madduck.net/etc/mutt.git/blob_plain/HEAD:/.mutt/markdown2html)
script to conveniently create `multipart/alternative` emails when the need
arises.

### Weechat
>Weechat keeps a lot of separate configuration files, which contain both
>default options and options altered by the user. Also some of the files
>contain highly sensitive information. Combined with the fact, that weechat
>doesn't support standalone password managers to obtain secrets, this makes it
>hard to manage a weechat config with a dotfiles repository.

That's why I wrote the script
[confload.py](.config/weechat/python/confload.py). It reads a configuration
file called [weechatrc](.config/weechat/weechatrc) located in the weechat home
directory. The file itself should be written in
[m4](https://www.gnu.org/software/m4/) macro language and after processing
should contain valid weechat commands. The script also provides the special
macro `KEEPASS(<title>, <attr>)`, which can be used to obtain sensitive
information managed with KeePassXC. When this script is loaded for the first
time it prompts the user for the KeePassXC password and then loads the config
file. On subsequent launches of weechat this process can be manually invoked
with the command `/confload <passphrase>`. Again you can use the
`KEEPASSXC_DATABASE` and `KEEPASSXC_KEYFILE` environment variables for the
locations of KeePassXC files.
