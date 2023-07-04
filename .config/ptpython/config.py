"""
Configuration file for ``ptpython``.
"""
from sys import stdout
from os import getenv
from prompt_toolkit.application.current import get_app
from prompt_toolkit.key_binding.vi_state import InputMode
from ptpython.layout import CompletionVisualisation
from ptpython.prompt_style import PromptStyle

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
        return [("", f"{self._get_mode_text()}> ")]

    def in2_prompt(self, width: int):
        return [("ansigray", ">>>")]

    def out_prompt(self):
        return []

def configure(repl):
    """
    Configuration method. This is called during the start-up of ptpython.

    :param repl: `PythonRepl` instance.
    """
    # Show function signature (bool).
    repl.show_signature = False

    # Show docstring (bool).
    repl.show_docstring = True

    # Show the "[Meta+Enter] Execute" message when pressing [Enter] only
    # inserts a newline instead of executing the code.
    repl.show_meta_enter_message = False

    # Show completions. (NONE, POP_UP, MULTI_COLUMN or TOOLBAR)
    repl.completion_visualisation = CompletionVisualisation.TOOLBAR

    # When CompletionVisualisation.POP_UP has been chosen, use this
    # scroll_offset in the completion menu.
    repl.completion_menu_scroll_offset = 0

    # Show line numbers (when the input contains multiple lines.)
    repl.show_line_numbers = False

    # Show status bar.
    repl.show_status_bar = False

    # When the sidebar is visible, also show the help text.
    repl.show_sidebar_help = True

    # Swap light/dark colors on or off
    repl.swap_light_and_dark = False

    # Highlight matching parethesis.
    repl.highlight_matching_parenthesis = True

    # Line wrapping. (Instead of horizontal scrolling.)
    repl.wrap_lines = True

    # Mouse support.
    repl.enable_mouse_support = False

    # Complete while typing. (Don't require tab before the
    # completion menu is shown.)
    repl.complete_while_typing = False

    # Fuzzy and dictionary completion.
    repl.enable_fuzzy_completion = False
    repl.enable_dictionary_completion = False

    # Paste mode. (When True, don't insert whitespace after new line.)
    repl.paste_mode = False

    # Vi mode.
    repl.vi_mode = True

    # reduce delay when pressing escape
    repl.app.ttimeoutlen = 0.05

    # Use custom prompt that displays current vi mode
    repl.all_prompt_styles["vi"] = ViPrompt()
    repl.prompt_style = "vi"  # could also be 'classic' or 'ipython'


    # Don't insert a blank line after the output.
    repl.insert_blank_line_after_output = False

    # History Search.
    # When True, going back in history will filter the history on the records
    # starting with the current input. (Like readline.)
    # Note: When enable, please disable the `complete_while_typing` option.
    #       otherwise, when there is a completion available, the arrows will
    #       browse through the available completions instead of the history.
    repl.enable_history_search = True

    # Enable auto suggestions. (Pressing right arrow will complete the input,
    # based on the history.)
    repl.enable_auto_suggest = True

    # Enable open-in-editor. Pressing C-x C-e in emacs mode or 'v' in
    # Vi navigation mode will open the input in the current editor.
    repl.enable_open_in_editor = True

    # Enable system prompt. Pressing meta-! will display the system prompt.
    # Also enables Control-Z suspend.
    repl.enable_system_bindings = True

    # Ask for confirmation on exit.
    repl.confirm_exit = False

    # Enable input validation. (Don't try to execute when the input contains
    # syntax errors.)
    repl.enable_input_validation = True

    # Use this colorscheme for the code.
    repl.use_code_colorscheme("igor")

    # Set color depth (keep in mind that not all terminals support true color).

    # repl.color_depth = 'DEPTH_1_BIT'  # Monochrome.
    repl.color_depth = 'DEPTH_4_BIT'  # ANSI colors only.
    # repl.color_depth = "DEPTH_8_BIT"  # The default, 256 colors.
    # repl.color_depth = 'DEPTH_24_BIT'  # True color.

    # Syntax.
    repl.enable_syntax_highlighting = True

    # Get into Vi navigation mode at startup
    repl.vi_start_in_navigation_mode = False

    # Preserve last used Vi input mode between main loop iterations
    repl.vi_keep_last_used_mode = False

    # minimum brightness for the colorscheme
    repl.min_brightness = 0.25
