# pyright: reportUndefinedVariable=false
from os import getenv
from os.path import join

## General
# -----------------------------------------------------------------------------
config.load_autoconfig(False)
c.search.incremental = False
c.spellcheck.languages = ["en-US", "de-DE"]

terminal, editor = getenv("TERMCMD", "alacritty"), getenv("EDITOR", "nvim")
c.editor.command = [
    *terminal.split(), "-e", editor, "{file}", "+norm{line}G{column0}l"
]

c.confirm_quit = ["downloads", "multiple-tabs"]
#c.auto_save.session = True

c.downloads.location.directory = "~/Downloads"
c.downloads.location.prompt = False
c.downloads.open_dispatcher = join(config.configdir, "userscripts/dispatcher")

c.tabs.last_close = "close"
c.tabs.select_on_remove = "last-used"
c.tabs.show = "multiple"

c.content.cookies.store = False
c.content.cookies.accept = "no-3rdparty"
#c.content.pdfjs = True
#c.content.javascript.enabled = False
#content.javascript.clipboard = True

## Search Engines
# -----------------------------------------------------------------------------
c.url.open_base_url = True

for bang in ["!jt", "!jotoba"]:
    c.url.searchengines[bang] = 'https://jotoba.de/search/{quoted}'

## Colorscheme
# -----------------------------------------------------------------------------
c.colors.webpage.preferred_color_scheme = "dark"
config.source("colorschemes/gruvbox.py")

## Keybindings & Aliases
# -----------------------------------------------------------------------------
for mode in ["normal", "caret"]:
    config.bind("gs", "spawn --userscript yomichad", mode=mode)
    config.bind("gS", "spawn --userscript yomichad --prefix-search", mode=mode)

config.bind("<Ctrl-e>", "scroll down")
config.bind("<Ctrl-y>", "scroll up")
config.bind("ao", "download-open")

config.bind('xt', 'open translate.google.com/translate?hl=en&tl=en&u={url}')

optval = "content.javascript.clipboard access access-paste none ;; reload"
config.bind("tXH", " ".join(["config-cycle -pu *://*.{url:host}/*", optval]))
config.bind("tXh", " ".join(["config-cycle -pu *://{url:host}/*", optval]))
config.bind("tXu", " ".join(["config-cycle -pu {url}", optval]))
config.bind("txH", " ".join(["config-cycle -ptu *://*.{url:host}/*", optval]))
config.bind("txh", " ".join(["config-cycle -ptu *://{url:host}/*", optval]))
config.bind("txu", " ".join(["config-cycle -ptu {url}", optval]))

c.aliases.update({
    "zotero": "spawn --userscript zotero",
    "Zotero": "hint links userscript zotero",

    "proxy": "spawn ssh proxy ;; set -t content.proxy socks5://localhost:8080",
    "noproxy": "spawn ssh -O exit proxy ;; config-unset -t content.proxy",

    "login": "open -p http://neverssl.com",
})

## Per-domain
# -----------------------------------------------------------------------------
with config.pattern("www.duden.de") as p:
    p.content.blocking.enabled = False
with config.pattern("jisho.org") as p:
    p.input.insert_mode.leave_on_load = False
with config.pattern("meet.jit.si") as p:
    p.content.desktop_capture = True
    p.content.media.audio_capture = True
    p.content.media.video_capture = True
    p.content.media.audio_video_capture = True
