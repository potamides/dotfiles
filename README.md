# 🍚 Dotfiles 🍚
> Ohne Fleiß kein Rice.
> - potamides

A repository for more sophisticated configuration files of applications I use
on a daily basis. My philosophy is to find a good balance between functionality
and design, while keeping an eye on resource consumption. I put a lot of care
into a consistent and pleasant look, that is easy on the eyes and try to use
the [gruvbox](https://github.com/morhetz/gruvbox) colorscheme for everything.
![](.rice.png)

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
</sup>. The project contains a [script](.local/bin/install-dotfiles), which
places administrative files in `$HOME/.dotfiles` and updates configuration
files in `$HOME` with the content of the repository (**warning:** this
overwrites existing files). For convenience the script can be executed like so:
```sh
curl -LfsS https://github.com/potamides/dotfiles/raw/master/.local/bin/install-dotfiles | bash
```

With a simple alias (already included in [bashrc](.bashrc)) this dotfiles
project can then be managed like any other git repository:
```sh
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```

This repository also contains a [script](.local/bin/install-packages) that
installs all required packages and performs necessary application setup
automatically. Note however that this script is specific to [Arch
Linux](https://www.archlinux.org/). It can be invoked like this:
```sh
curl -LfsS https://github.com/potamides/dotfiles/raw/master/.local/bin/install-packages | bash
```

## Contents
The project contains configuration files for the following programs. Many
applications are straightforward to use. For programs where I developed a more
individual workflow, I give basic usage instructions below.
| | Name | Files \& Directories | Links |
|-| ---- | ------- | ----- |
| **Window Manager**          | awesome  | [.config/awesome](.config/awesome), [.xinitrc](.xinitrc) | [Repository](https://github.com/awesomeWM/awesome), [Homepage](https://awesomewm.org/) |
| **Terminal**                | termite  | [.config/termite](.config/termite) | [Repository](https://github.com/thestinger/termite) | 
| **Terminal Multiplexer**    | tmux     | [.tmux.conf](.tmux.conf) | [Repository](https://github.com/tmux/tmux), [Homepage](https://tmux.github.io) |
| **Shell**                   | bash     | [.inputrc](.inputrc), [.bashrc](.bashrc), [.bash\_profile](.bash_profile) | [Repository](https://git.savannah.gnu.org/cgit/bash.git), [Homepage](https://www.gnu.org/software/bash/) |
| **Editor**                  | neovim   | [.config/nvim](.config/nvim) | [Repository](https://github.com/neovim/neovim), [Homepage](https://neovim.io/) |
| **Mail Client**             | mutt     | [.config/mutt](.config/mutt) | [Repository](https://gitlab.com/muttmua/mutt), [Homepage](http://www.mutt.org/) |
| **File Manager**            | ranger   | [.config/ranger](.config/ranger) | [Repository](https://github.com/ranger/ranger), [Homepage](https://ranger.github.io/) |
| **Music Player**            | ncmpcpp  | [.config/ncmpcpp](.config/ncmpcpp) | [Repository](https://github.com/ncmpcpp/ncmpcpp), [Homepage](https://rybczak.net/ncmpcpp/) |
| **Document Viewer**         | qpdfview | [.config/qpdfview](.config/qpdfview) | [Homepage](https://launchpad.net/qpdfview) |
| **System Monitor**          | conky    | [.conkyrc](.conkyrc) | [Repository](https://github.com/brndnmtthws/conky), [Homepage](https://github.com/brndnmtthws/conky/wiki) |
| **System Information Tool** | neofetch | [.config/neofetch](.config/neofetch) | [Repository](https://github.com/dylanaraps/neofetch), [Homepage](https://github.com/dylanaraps/neofetch/wiki) |
| **Display Locker**          | physlock | [.config/.../physlock@.service](.config/systemd/user/physlock@.service) | [Repository](https://github.com/muennich/physlock) |
| **Calculator**              | ptpython | [.config/ptpython](.config/ptpython) | [Repository](https://github.com/prompt-toolkit/ptpython) |

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

Additionally [mpd](https://www.musicpd.org/) is highly integrated into the
configuration. I have a server where all my audio files are located. A systemd
[service file](.config/systemd/user/mpd-tunnel.service) then creates an ssh
tunnel to control mpd and to receive the audio stream, which is then played via
[mpv](https://mpv.io/).

### Mutt
Mutt is configured for multiple email accounts. It makes use of the command
line tool distributed with [keepassxc](https://keepassxc.org/) to access
passwords. The location of the password database and the keyfile can be
controlled with the `KEYPASSXC_DATABASE` and `KEYPASSXC_KEYFILE` environment
variables.

Mutt also contains a [script](.config/mutt/scripts/create-alias.sh) which
automatically creates aliases for addresses in the `FROM` field, when reading
an email. It also contains the
[markdown2html](https://git.madduck.net/etc/mutt.git/blob_plain/HEAD:/.mutt/markdown2html)
script to conveniently create `multipart/alternative` emails when the need
arises.
