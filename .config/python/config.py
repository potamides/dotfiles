from importlib.util import find_spec
from os import getenv, makedirs
from os.path import exists, join, dirname
import sys

# embed ptpython if it is installed and isn't the current REPL
if "ptpython" not in getenv("_", "") and find_spec("ptpython"):
    from ptpython.repl import embed, run_config
    from appdirs import user_config_dir, user_data_dir

    config_file = join(getenv("PTPYTHON_CONFIG_HOME", user_config_dir("ptpython", "prompt_toolkit")), "config.py")
    history_file = join(user_data_dir("ptpython", "prompt_toolkit"), "history")

    # create histfile if it doesn't exist (else ptpython complains)
    if not exists(history_file):
        makedirs(dirname(history_file), exist_ok=True)
        with open(history_file, 'w'): pass

    sys.exit(embed(globals(), locals(), lambda repl: run_config(repl, config_file), False, history_file))
# if not customize standard python REPL
else:
    # make primary prompt shorter because ~/.config/readline/inputrc shows vi editing mode
    sys.ps1 = "> "
    sys.ps2 = "» "
