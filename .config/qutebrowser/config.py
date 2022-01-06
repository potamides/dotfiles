# pyright: reportUndefinedVariable=false
from os import getenv

## General
# -----------------------------------------------------------------------------
config.load_autoconfig(False)
c.input.insert_mode.leave_on_load = True
c.search.incremental = False
c.spellcheck.languages = ["en-US", "de-DE"]

terminal, editor = getenv("TERMCMD", "termite"), getenv("EDITOR", "nvim")
c.editor.command = [terminal, "-e", editor + " {file} +normal{line}G{column0}l"]

c.confirm_quit = ["downloads"]
#c.auto_save.session = True

c.downloads.location.directory = "~/Downloads"
c.downloads.location.prompt = False

c.tabs.last_close = "close"
c.tabs.select_on_remove = "last-used"

c.content.cookies.store = False
c.content.cookies.accept = "no-3rdparty"
c.content.pdfjs = True
#c.content.javascript.enabled = False

## Colorscheme
# -----------------------------------------------------------------------------
c.colors.webpage.preferred_color_scheme = "dark"
config.source("colorschemes/gruvbox.py")

## Keybindings
# -----------------------------------------------------------------------------
for mode in ["normal", "caret"]:
    config.bind('gs', 'spawn --userscript yomichad', mode=mode)
    config.bind('gS', 'spawn --userscript yomichad --prefix-search', mode=mode)

config.bind('<Ctrl-e>', 'scroll down')
config.bind('<Ctrl-y>', 'scroll up')
