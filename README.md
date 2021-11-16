<a href="#readme">
  <img alt="🍙 Dotfiles" width="100%" src="https://gist.githubusercontent.com/potamides/35387b4d0c47aea421f75aa0b9f78b5f/raw/dotfiles-headline.svg"/>
</a>

---

This repository contains my personal
[dotfiles](https://wiki.archlinux.org/title/Dotfiles) for most of the
programs I use on a daily basis. Primarily, this allows me to organize my
[rice](https://thatnixguy.github.io/posts/ricing/) and to easily set up the
computing experience I enjoy on any machine I come across. However, it also
allows me to share my preferences with others. I think there are some
interesting things here worth discovering, and that's why I take the time to
write (or at least try to write) sufficient comments and documentation.

My principles are to find a satisfactory balance between functionality and
design while keeping an eye on resource consumption. I prefer keyboard-focused
control over everything else and place a high value on visual consistency
(preferably by using the [gruvbox](https://github.com/morhetz/gruvbox) color
scheme). I use [Arch Linux](https://archlinux.org/) as my daily driver, but
there shouldn't be much here requiring this specific distribution, so using my
configurations on other distros or, in the worst case, porting it shouldn't be
too hard. I prefer a slightly retro design, but I don't shy away from
occasionally using Unicode symbols and [Nerd Font](https://www.nerdfonts.com/)
glyphs in my terminal applications. However, since I sometimes only work with
the [Linux console](https://wiki.archlinux.org/title/Linux_console), I always
make sure to fall back to settings that look good in [VGA text
mode](https://en.wikipedia.org/wiki/VGA_text_mode) with [code page
437](https://en.wikipedia.org/wiki/Code_page_437), if that should be the case.

---

<a href="https://gist.githubusercontent.com/potamides/35387b4d0c47aea421f75aa0b9f78b5f/raw/rice.png">
  <img alt="CRT Monitor with rice" width="100%" src="https://gist.githubusercontent.com/potamides/35387b4d0c47aea421f75aa0b9f78b5f/raw/rice-crt.svg"/>
</a>

## Installation
**Disclaimer:** My dotfiles are heavily customized to my own needs. I,
therefore, advise everyone not to use this repository blindly. Instead, I
recommend checking each relevant component thoroughly before use to avoid
unexpected complications.

If you just want to hack at your own leisure, this repository and its
submodules can be cloned with the following command:
```sh
git clone --recurse-submodules https://github.com/potamides/dotfiles
```
For actual use, I recommend the installation as a bare Git repository. This
makes it possible to manage dotfiles with git only in an uncomplicated and
effective way without having to rely on additional external tools <sup>
[1](https://news.ycombinator.com/item?id=11070797),
[2](https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo/),
[3](https://harfangk.github.io/2016/09/18/manage-dotfiles-with-a-git-bare-repository.html)
</sup>. For this use case, the project contains a
[script](.local/bin/install-dotfiles), that installs a bare git repository to
`$HOME/.dotfiles` and updates configuration files in `$HOME` with its content
(conflicting files are moved to `$HOME/dotfiles.backup`). For convenience the
script can be executed as follows:
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
Configuration files and other information for the core components of this rice
are listed in the following table. Many programs do not differ significantly
from the default settings in terms of usage, which is why I simply refer to the
respective homepages for further information. For applications where I
developed a more individual workflow, I give additional instructions below.
| | Name | Files & Directories | Links |
|-| ---- | ------- | ----- |
| **Shell**                | bash     | [.inputrc](.inputrc), [.bashrc](.bashrc), [.bash\_profile](.bash_profile) | [Repository](https://git.savannah.gnu.org/cgit/bash.git), [Homepage](https://www.gnu.org/software/bash/) |
| **Window Manager**       | awesome  | [.config/awesome](.config/awesome), [.xinitrc](.xinitrc) | [Repository](https://github.com/awesomeWM/awesome), [Homepage](https://awesomewm.org/) |
| **Editor**               | neovim   | [.config/nvim](.config/nvim) | [Repository](https://github.com/neovim/neovim), [Homepage](https://neovim.io/) |
| **Terminal**             | termite  | [.config/termite](.config/termite) | [Repository](https://github.com/thestinger/termite) | 
| **Terminal Multiplexer** | tmux     | [.config/tmux](.config/tmux) | [Repository](https://github.com/tmux/tmux), [Homepage](https://tmux.github.io) |
| **Music Player**         | ncmpcpp  | [.config/ncmpcpp](.config/ncmpcpp) | [Repository](https://github.com/ncmpcpp/ncmpcpp), [Homepage](https://rybczak.net/ncmpcpp/) |
| **System Monitor**       | conky    | [.config/conky](.config/conky) | [Repository](https://github.com/brndnmtthws/conky), [Homepage](https://github.com/brndnmtthws/conky/wiki) |
| **Mail Client**          | mutt     | [.config/mutt](.config/mutt) | [Repository](https://gitlab.com/muttmua/mutt), [Homepage](http://www.mutt.org/) |
| **IRC Client**           | weechat  | [.config/weechat](.config/weechat) | [Repository](https://github.com/weechat/weechat), [Homepage](https://weechat.org/) |
| **File Manager**         | ranger   | [.config/ranger](.config/ranger) | [Repository](https://github.com/ranger/ranger), [Homepage](https://ranger.github.io/) |
| **Calculator** ;-)       | ptpython | [.config/ptpython](.config/ptpython) | [Repository](https://github.com/prompt-toolkit/ptpython) |
| **Calendar**             | when     | [.when](.when) | [Repository](https://github.com/bcrowell/when), [Homepage](http://www.lightandmatter.com/when/when.html) |
| **Document Viewer**      | qpdfview | [.config/qpdfview](.config/qpdfview) | [Homepage](https://launchpad.net/qpdfview) |

Apart from the applications mentioned in the table, this repository also
contains some additional [scripts](.local/bin) to automate or facilitate
various tasks. All scripts contain a header explaining how to use them.

### Awesome
Instead of the standard
[awful.key](https://awesomewm.org/doc/api/libraries/awful.key.html)
keybindings, my awesome configuration uses
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

### Conky
My conky configuration merges with my background image, so the position and
size must be set precisely. Since I often use multiple screens with different
resolutions throughout the day, I need to be able to scale conky's dimensions
accordingly. Unfortunately, I am not aware of any built-in feature that could
solve this problem. For this reason I wrote the conky plugin
[scaling.lua](.config/conky/scaling.lua). It introduces new configuration
options through a new table `conky.sizes`, which can be used to specify
different sizes for arbitrary screen resolutions. For unspecified screen
resolutions, the plugin tries to calculate the best scaling automatically.

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
