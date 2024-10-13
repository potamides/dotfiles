"""
Configuration file for ``ptpython``.
"""
from os import getenv
from sys import stdout

from prompt_toolkit.application.current import get_app
from prompt_toolkit.key_binding.vi_state import InputMode
from prompt_toolkit.styles import Style
from prompt_toolkit.styles.pygments import style_from_pygments_cls
from ptpython.layout import CompletionVisualisation
from ptpython.prompt_style import PromptStyle
from pygments.styles.gruvbox import GruvboxDarkStyle
from pygments.token import Token


__all__ = ("configure",)


class ViPrompt(PromptStyle):
    """
    Custom prompt with mode indicator.
    """

    @property
    def _mode(self):
        return get_app().vi_state.input_mode

    @property
    def _sel_state(self):
        return get_app().current_buffer.selection_state

    def _update_cursor_shape(self):
        if self._sel_state is not None or self._mode == InputMode.NAVIGATION:
            emul, virt = 2, 8
        elif self._mode in (InputMode.INSERT, InputMode.INSERT_MULTIPLE):
            emul, virt = 6, 0
        elif self._mode in (InputMode.REPLACE, InputMode.REPLACE_SINGLE):
            emul, virt = 4, 0
        else:
            return
        # linux console uses other escape codes than most terminal emulators
        if getenv("TERM") == "linux":
            stdout.write(f"\x1b[?{virt}c")
        else:
            stdout.write(f"\x1b[{emul} q")
        stdout.flush()

    def _get_mode_text(self):
        if self._sel_state is not None:
            return "(vis)"
        if self._mode == InputMode.NAVIGATION:
            return "(cmd)"
        if self._mode in (InputMode.INSERT, InputMode.INSERT_MULTIPLE):
            return "(ins)"
        if self._mode in (InputMode.REPLACE, InputMode.REPLACE_SINGLE):
            return "(rpl)"
        return ""

    def in_prompt(self):
        self._update_cursor_shape()
        return [("class:vi-prompt", f"{self._get_mode_text()}> ")]

    def in2_prompt(self, width: int):
        return [("class:vi-prompt.dots", "»")]

    def out_prompt(self):
        return []


class FixedGruvboxCodeStyle(GruvboxDarkStyle):
    styles = GruvboxDarkStyle.styles | { # type: ignore
            Token: GruvboxDarkStyle.highlight_color
    }


class GruvboxUIStyle(Style):
    _style_rules = {
        # Vi prompt.
        "vi-prompt": "#ebdbb2",
        "vi-prompt.dots": "#ebdbb2",
        # Separator between windows. (Used above docstring.)
        "separator": "#665c54",
        # System toolbar
        "system-toolbar": "#ebdbb2 noinherit",
        # "arg" toolbar.
        "arg-toolbar": "#ebdbb2 noinherit",
        "arg-toolbar.text": "noinherit",
        # Signature toolbar.
        "signature-toolbar": "bg:#504945 #ebdbb2",
        "signature-toolbar current-name": "fg:#83a598 bg:#504945 reverse bold",
        "signature-toolbar operator": "bg:#504945 #ebdbb2",
        "docstring": "#928373",
        # Status toolbar.
        "status-toolbar": "bg:#3c3836 #a89984",
        "status-toolbar.key": "bg:#3c3836 #a89984",
        "status-toolbar.input-mode": "bg:#a89984 #282828 bold",
        "record": "bg:#fb4934 #ebdbb2",
        # The options sidebar.
        "sidebar": "bg:#504945 #ebdbb2 hidden",
        "sidebar.helptext": "bg:#504945 #ebdbb2 nohidden",
        "sidebar.title": "#b8bb26 bold nohidden underline",
        "sidebar.label": "#83a598 nohidden",
        "sidebar.status": "nohidden",
        "sidebar.key": "reverse nohidden",
        "sidebar.description": "#ebdbb2 nohidden",
        "sidebar selected": "nohidden",
        # Meta-enter message.
        "accept-message": "#fabd2f bold",
        # Exit confirmation.
        "exit-confirmation": "#fabd2f bold",
        # Highlighting of select text in document.
        "selected": "bg:#665c54 noreverse",
        # Highlighting of matching brackets.
        "matching-bracket": "",
        "matching-bracket.other": "#ebdbb2 bg:#665c54",
        "matching-bracket.cursor": "#ebdbb2 bg:#665c54",
        # Validation toolbar.
        "validation-toolbar": "bg:#fb4934 #282828 bold",
        "window-too-small": "bg:#fb4934 #282828 bold",
        # Completions toolbar.
        "completion-toolbar": "bg:#504945 #ebdbb2",
        "completion-toolbar.arrow": "bg:#504945 #ebdbb2 bold",
        "completion-toolbar.completion": "bg:#504945 #ebdbb2",
        "completion-toolbar.completion.current": "fg:#83a598 bg:#504945 reverse bold",
        # Completions menu.
        "completion-menu": "bg:#504945 #ebdbb2",
        "completion-menu.completion": "",
        "completion-menu.completion.current": "fg:#83a598 bg:#504945 reverse bold",
        "completion-menu.meta.completion": "bg:#504945 #ebdbb2",
        "completion-menu.meta.completion.current": "fg:#83a598 bg:#504945 reverse bold",
        "completion-menu.multi-column-meta": "fg:#83a598 bg:#504945 reverse bold",
        # Fuzzy matches in completion menu (for FuzzyCompleter).
        "completion-menu.completion fuzzymatch.outside": "fg:#ebdbb2",
        "completion-menu.completion fuzzymatch.inside": "bold",
        "completion-menu.completion fuzzymatch.inside.character": "underline",
        "completion-menu.completion.current fuzzymatch.outside": "fg:#83a598 bg:#504945 reverse bold",
        "completion-menu.completion.current fuzzymatch.inside": "bold",
        # Styling of readline-like completions.
        "readline-like-completions": "",
        "readline-like-completions.completion": "",
        "readline-like-completions.completion fuzzymatch.outside": "#83a598",
        "readline-like-completions.completion fuzzymatch.inside": "",
        "readline-like-completions.completion fuzzymatch.inside.character": "underline",
        # Line numbers.
        "line-number": "#928374",
        "line-number.current": "bg:#3c3836 #fabd2f",
        # Scrollbars.
        "scrollbar.background": "bg:#504945",
        "scrollbar.button": "bg:#7c6f64",
        "scrollbar.arrow": "noinherit bold",
        # Trailing whitespace and tabs.
        "trailing-whitespace": "#504945",
        "tab": "#504945",
        # When Control-C/D has been pressed. Grayed.
        "aborting": "#928374 bg:default noreverse noitalic nounderline noblink",
        "exiting": "#928374 bg:default noreverse noitalic nounderline noblink",
        # Auto suggestions.
        "auto-suggestion": "#928374",
        # Entering a Vi digraph.
        "digraph": "#a89984",
        # Control characters, like ^C, ^X.
        "control-character": "#a89984",
        # Non-breaking space.
        "nbsp": "#504945 strike",
    }

    def __init__(self, ):
        super().__init__(list(self._style_rules.items()))


def configure(repl):
    """
    Configuration method. This is called during the start-up of ptpython.
    """

    ## Input Completion/Information
    # -------------------------------------------------------------------------
    # Show function signature (bool).
    repl.show_signature = False
    # Show docstring (bool).
    repl.show_docstring = True
    # Complete while typing. (Don't require tab before the
    # completion menu is shown.)
    repl.complete_while_typing = False
    # Enable auto suggestions. (Pressing right arrow will complete the input,
    # based on the history.)
    repl.enable_auto_suggest = True
    # History Search.
    # When True, going back in history will filter the history on the records
    # starting with the current input. (Like readline.)
    # Note: When enable, please disable the `complete_while_typing` option.
    #       otherwise, when there is a completion available, the arrows will
    #       browse through the available completions instead of the history.
    repl.enable_history_search = True

    ## User Interface Behavior
    # -------------------------------------------------------------------------
    # Show status bar.
    repl.show_status_bar = False
    # Show the "[Meta+Enter] Execute" message when pressing [Enter] only
    # inserts a newline instead of executing the code.
    repl.show_meta_enter_message = False
    # Ask for confirmation on exit.
    repl.confirm_exit = False
    # Highlight matching parentheses.
    repl.highlight_matching_parenthesis = True
    # Mouse support.
    repl.enable_mouse_support = True
    # Don't insert a blank line after the output
    repl.insert_blank_line_after_output = False
    # Show completions in popup window.
    repl.completion_visualisation = CompletionVisualisation.POP_UP

    ## Vi Mode
    # -------------------------------------------------------------------------
    repl.vi_mode = True
    # Reduce delay when pressing escape.
    repl.app.ttimeoutlen = 0.05
    # Use custom prompt that displays current vi mode.
    repl.all_prompt_styles["vi"] = ViPrompt()
    repl.prompt_style = "vi"

    ## Gruvbox Colorscheme
    # -------------------------------------------------------------------------
    repl.install_code_colorscheme("gruvbox", style_from_pygments_cls(FixedGruvboxCodeStyle))
    repl.install_ui_colorscheme("gruvbox", GruvboxUIStyle())
    repl.use_code_colorscheme("gruvbox")

    if getenv("TERM") != "linux" and getenv("COLORTERM") is not None:
        repl.use_ui_colorscheme("gruvbox")
        repl.color_depth = 'DEPTH_24_BIT'
    else:
        repl.color_depth = 'DEPTH_4_BIT'
