# pyright: reportUndefinedVariable=false
from os import getenv

## General
# -----------------------------------------------------------------------------
config.load_autoconfig(False)
c.search.incremental = False
c.spellcheck.languages = ["en-US", "de-DE"]

terminal, editor = getenv("TERMCMD", "alacritty"), getenv("EDITOR", "nvim")
c.editor.command = [terminal, "-e", editor + " {file} +normal{line}G{column0}l"]

c.confirm_quit = ["downloads"]
#c.auto_save.session = True

c.downloads.location.directory = "~/Downloads"
c.downloads.location.prompt = False

c.tabs.last_close = "close"
c.tabs.select_on_remove = "last-used"
c.tabs.show = "multiple"

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
    config.bind("gs", "spawn --userscript yomichad", mode=mode)
    config.bind("gS", "spawn --userscript yomichad --prefix-search", mode=mode)

config.bind("<Ctrl-e>", "scroll down")
config.bind("<Ctrl-y>", "scroll up")

## Per-domain
# -----------------------------------------------------------------------------
with config.pattern('jisho.org') as p:
    p.input.insert_mode.leave_on_load = False
with config.pattern('meet.jit.si') as p:
    p.content.desktop_capture = True
    p.content.media.audio_capture = True
    p.content.media.video_capture = True
    p.content.media.audio_video_capture = True
