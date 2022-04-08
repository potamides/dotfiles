<a href="#readme">
  <img alt="🍙 Dotfiles" width="100%" src="https://user-images.githubusercontent.com/53401822/162452560-4addbc36-c894-47b0-8479-c99e7fb5818c.svg"/>
</a>

---

This repository contains my personal
[dotfiles](https://wiki.archlinux.org/title/Dotfiles) for most of the programs
I use on a daily basis. Primarily, this allows me to organize my
[rice](https://thatnixguy.github.io/posts/ricing) and to easily set up the
computing experience I enjoy on any machine I come across. However, it also
allows me to share my preferences with others. I think there are some
interesting things here worth discovering, and that's why I take the time to
write (or at least try to write) sufficient comments and documentation.

My principles are to find a satisfactory balance between functionality and
design while keeping an eye on resource consumption. I prefer keyboard-focused
control over everything else and place a high value on visual consistency
(preferably by using the [gruvbox](https://github.com/morhetz/gruvbox) color
scheme). I use [Arch Linux](https://archlinux.org) as my daily driver, but
there shouldn't be much here requiring this specific distribution, so using my
configurations on other distros or, in the worst case, porting them shouldn't be
too hard. I prefer a slightly retro design, but I don't shy away from
occasionally using Unicode symbols and [Nerd Font](https://www.nerdfonts.com)
glyphs in my terminal applications. However, since I sometimes only work with
the [Linux console](https://wiki.archlinux.org/title/Linux_console), I always
make sure to fall back to settings that look good in [VGA text
mode](https://en.wikipedia.org/wiki/VGA_text_mode) with [code page
437](https://en.wikipedia.org/wiki/Code_page_437), if that should be the case.

<details><summary>Past Discussions</summary>

  * [Vi-like keybindings for awesome](https://www.reddit.com/r/awesomewm/comments/i4pj35/vilike_keybindings_for_awesome_with_motions_and) (6. Aug. 2020)
  * [Streets of Gruvbox](https://www.reddit.com/r/unixporn/comments/i60b10/awesome_streets_of_gruvbox) (8. Aug. 2020)
  * [Confload: Create dotfiles-manageable weechat configs with password manager integration](https://www.reddit.com/r/unixporn/comments/l1unqe/oc_confload_create_dotfilesmanageable_weechat) (21. Jan. 2021)
  * [Snipcomp.lua: LuaSnip companion plugin for omni completion](https://www.reddit.com/r/neovim/comments/rddugs/snipcomplua_luasnip_companion_plugin_for_omni) (10. Dec. 20221)
</details>

---

<a href="https://user-images.githubusercontent.com/53401822/162453427-35cd1699-0b5b-49b6-9023-783bbeea0ebf.png">
  <img alt="CRT Monitor with rice" width="100%" src="https://user-images.githubusercontent.com/53401822/162453210-a2e00d8d-9f14-4ffa-a511-fbc99f99aecb.svg"/>
</a>

## Installation
**Disclaimer:** My dotfiles are heavily customized to my own needs. I,
therefore, advise everyone not to use this repository blindly. Instead, I
recommend that you treat this project solely as a source of inspiration, or at
least thoroughly check each relevant component before using it to avoid
unexpected complications.

If you just want to hack at your own leisure, this repository and its
submodules can be cloned with the following command:
```sh
git clone --recurse-submodules https://github.com/potamides/dotfiles
```
For actual use, I recommend the installation as a bare Git repository. This
makes it possible to manage dotfiles with git only in an uncomplicated and
effective way without having to rely on additional external tools[^1]. For this
use case, I provide a [script](.local/bin/install-dotfiles) that installs a
bare git repository to `$HOME/.dotfiles` and updates configuration files in
`$HOME` with the contents of this project (conflicting files are moved to
`$HOME/dotfiles.backup`). For convenience the script can be executed as
follows:
```sh
bash <(curl -LfsS https://github.com/potamides/dotfiles/raw/master/.local/bin/install-dotfiles)
```
With a simple alias (already included in [bashrc](.bashrc)) this dotfiles
project can then be managed like any other git repository:
```sh
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```
This repository also contains a [script](.local/bin/install-packages) which can
be used to install all required packages. However, please note that it is
specific to [Arch Linux](https://www.archlinux.org). When this script is
sourced it defines the array variables `PKG`, `PIP` and `AUR`. You can then use
`pacman`, `pip` and an [AUR
helper](https://wiki.archlinux.org/index.php/AUR_helpers) of your choice to
install everything:
```sh
source <(curl -LfsS https://github.com/potamides/dotfiles/raw/master/.local/bin/install-packages)
sudo pacman -S "${PKG[@]}" && yay -Sa "${AUR[@]}" && pip install "${PIP[@]}" --user
```

## Content
Configuration files and other information for the core components of this rice
are listed in the following table. Many programs do not differ significantly
from the default settings in terms of usage, which is why I simply refer to the
respective homepages for further information. For applications where I
developed a more individual workflow, I give additional instructions below.
| | Name | Files & Directories | Links |
|-| ---- | ------- | ----- |
| **Shell**                | bash        | [.inputrc](.inputrc), [.bashrc](.bashrc), [.bash\_profile](.bash_profile) | [Repository](https://git.savannah.gnu.org/cgit/bash.git), [Homepage](https://www.gnu.org/software/bash) |
| **Window Manager**       | awesome     | [.config/awesome](.config/awesome), [.xinitrc](.xinitrc) | [Repository](https://github.com/awesomeWM/awesome), [Homepage](https://awesomewm.org) |
| **Editor**               | neovim      | [.config/nvim](.config/nvim) | [Repository](https://github.com/neovim/neovim), [Homepage](https://neovim.io) |
| **Terminal**             | alacritty   | [.config/alacritty](.config/alacritty) | [Repository](https://github.com/alacritty/alacritty), [Homepage](https://alacritty.org) |
| **Terminal Multiplexer** | tmux        | [.config/tmux](.config/tmux) | [Repository](https://github.com/tmux/tmux), [Homepage](https://tmux.github.io) |
| **Music Player**         | ncmpcpp     | [.config/ncmpcpp](.config/ncmpcpp) | [Repository](https://github.com/ncmpcpp/ncmpcpp), [Homepage](https://rybczak.net/ncmpcpp) |
| **System Monitor**       | conky       | [.config/conky](.config/conky) | [Repository](https://github.com/brndnmtthws/conky), [Homepage](https://github.com/brndnmtthws/conky/wiki) |
| **Mail Client**          | mutt        | [.config/mutt](.config/mutt) | [Repository](https://gitlab.com/muttmua/mutt), [Homepage](http://www.mutt.org) |
| **IRC Client**           | weechat     | [.config/weechat](.config/weechat) | [Repository](https://github.com/weechat/weechat), [Homepage](https://weechat.org) |
| **File Manager**         | ranger      | [.config/ranger](.config/ranger) | [Repository](https://github.com/ranger/ranger), [Homepage](https://ranger.github.io) |
| **Calculator** ;-)       | ptpython    | [.config/ptpython](.config/ptpython) | [Repository](https://github.com/prompt-toolkit/ptpython) |
| **Calendar**             | when        | [.when](.when) | [Repository](https://github.com/bcrowell/when), [Homepage](http://www.lightandmatter.com/when/when.html) |
| **Document Viewer**      | qpdfview    | [.config/qpdfview](.config/qpdfview) | [Repository](https://launchpad.net/qpdfview) |
| **Web Browser**          | qutebrowser | [.config/qutebrowser](.config/qutebrowser) | [Repository](https://github.com/qutebrowser/qutebrowser), [Homepage](https://qutebrowser.org) |

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

Additionally, if an [mpd](https://www.musicpd.org) server is running on
`$MPD_HOST:$MPD_PORT`, song information is displayed in the status bar. Songs
are also played back via [mpv](https://mpv.io) by listening on
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

### Neovim
For my Neovim configuration, I made heavy use of the new features introduced
with [Neovim 0.5](https://neovim.io/news/2021/07) and wrote it entirely in Lua.
I wrote a small wrapper around the
[packer.nvim](https://github.com/wbthomason/packer.nvim) plugin manager called
[autopacker.lua](.config/nvim/lua/autopacker.lua), which makes sure to install
itself and all specified plugins on its own on the first launch of Neovim,
eliminating the need for any further setup steps. I tried to keep the main
configuration file, [init.lua](.config/nvim/init.lua), mostly language
agnostic. Therefore, I refactored language-specific and buffer-local code into
stand-alone [ftplugins](.config/nvim/ftplugin). Similarly, I moved a lot of
complex functionality into [libraries](.config/nvim/lua) and
[plugins](.config/nvim/plugin) to keep the main configuration uncluttered and
readable. Notable examples include
[components.lua](.config/nvim/lua/components.lua), a collection of (mostly
LSP-related) components for the
[lightline.vim](https://github.com/itchyny/lightline.vim) status line, and
[snipcomp.lua](.config/nvim/plugin/snipcomp.lua), a companion plugin for the
[LuaSnip](https://github.com/L3MON4D3/LuaSnip) snippet engine, which provides a
snippet completion function for the built-in insert mode completion commands.
Consult `:h ins-completion` for details.

### Mutt
Mutt is configured for multiple email accounts. It makes use of the command
line tool distributed with [KeePassXC](https://keepassxc.org) to access
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
[m4](https://www.gnu.org/software/m4) macro language and after processing
should contain valid weechat commands. The script also provides the special
macro `KEEPASS(<title>, <attr>)`, which can be used to obtain sensitive
information managed with KeePassXC. When this script is loaded for the first
time it prompts the user for the KeePassXC password and then loads the config
file. On subsequent launches of weechat this process can be manually invoked
with the command `/confload <passphrase>`. Again you can use the
`KEEPASSXC_DATABASE` and `KEEPASSXC_KEYFILE` environment variables for the
locations of KeePassXC files.

### Ptpython
I configured ptpython to embed itself into the default Python REPL. That way,
it can be started by simply executing the standard Python binary. This is
realized through the environment variable `PYTHONSTARTUP`, which points to a
setup [script](.config/python/config.py) that is executed when Python is
launched in interactive mode.

## Miscellaneous
Besides the things mentioned above, this repository also contains configuration
files for a number of other programs. However, these are only optionally
required and perform specific tasks that are often not needed. Therefore, these
programs are not included in the package installation script and must be
installed manually. The corresponding packages and their functions are listed
below:
* For Japanese Kana and Kanji input, install
  [fcitx5-im](https://archlinux.org/groups/x86_64/fcitx5-im) and
  [fcitx5-mozc](https://archlinux.org/packages/community/x86_64/fcitx5-mozc).
* To enable automounting, install
  [udiskie](https://archlinux.org/packages/community/any/udiskie).
* To compile L<sup>A</sup>T<sub>E</sub>X with Neovim using qpdfview as the
  previewer, install [T<sub>E</sub>X
  Live](https://wiki.archlinux.org/title/TeX_Live). For inverse search also
  install [neovim-remote](https://aur.archlinux.org/packages/neovim-remote)
  and set `nvr --remote-silent +%2 %1` as the source editor in qpdfview.
* Install [mythes](https://archlinux.org/packages/?sort=&q=mythes-) for
  thesaurus lookup and
  [languagetool-word2vec](https://aur.archlinux.org/packages/?K=languagetool-word2vec-)
  and/or
  [languagetool-ngrams](https://aur.archlinux.org/packages/?K=languagetool-ngrams-)
  to detect confusion errors with [ltex](https://github.com/valentjn/ltex-ls)
  in Neovim.
* For Japanese pop-up dictionary search in qutebrowser install
  [jamdict](https://pypi.org/project/jamdict) and
  [jamdict-data](https://pypi.org/project/jamdict-data) (for further
  information see [yomichad](https://github.com/potamides/yomichad)).

[^1]: [Ask HN: What do you use to manage dotfiles?](https://news.ycombinator.com/item?id=11070797)  
  [The best way to store your dotfiles: A bare Git repository](https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo)  
  [Manage Dotfiles With a Bare Git Repository](https://harfangk.github.io/2016/09/18/manage-dotfiles-with-a-git-bare-repository.html)  
