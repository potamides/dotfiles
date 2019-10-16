from __future__ import (absolute_import, division, print_function)

import os
from shlex import quote
from ranger.api.commands import Command
from ranger.core.loader import CommandLoader


class umount(Command):
    """
    :umount <device_mount_point>

    A command that uitilizes udiskie to unmount removable devices.
    """

    def execute(self):
        def callback(answer):
            if answer in ['y', 'Y']:
                self.fm.run("udiskie-umount -a")

        if self.arg(1):
            self.fm.run("udiskie-umount " + self.arg(1))
        elif "/run/media/" + self.fm.username == self.fm.thisdir.path:
            self.fm.run("udiskie-umount " + quote(self.fm.thisfile.path))
        else:
            self.fm.ui.console.ask(
                "Confirm unmounting of all devices (y/N)",
                callback,
                ('n', 'N', 'y', 'Y'),
            )


class toggle_flat(Command):
    """
    :toggle_flat

    Flattens or unflattens the directory view.
    """

    def execute(self):
        if self.fm.thisdir.flat == 0:
            self.fm.thisdir.unload()
            self.fm.thisdir.flat = -1
            self.fm.thisdir.load_content()
        else:
            self.fm.thisdir.unload()
            self.fm.thisdir.flat = 0
            self.fm.thisdir.load_content()


class extracthere(Command):
    def execute(self):
        """ Extract copied files to current directory """
        copied_files = tuple(self.fm.copy_buffer)

        if not copied_files:
            return

        def refresh(_):
            cwd = self.fm.get_directory(original_path)
            cwd.load_content()

        one_file = copied_files[0]
        cwd = self.fm.thisdir
        original_path = cwd.path
        au_flags = ['-X', cwd.path]
        au_flags += self.line.split()[1:]
        au_flags += ['-e']

        self.fm.copy_buffer.clear()
        self.fm.cut_buffer = False
        if len(copied_files) == 1:
            descr = "extracting: " + os.path.basename(one_file.path)
        else:
            descr = "extracting files from: " + \
                os.path.basename(one_file.dirname)
        obj = CommandLoader(
            args=['aunpack'] + au_flags + [f.path for f in copied_files],
            descr=descr)

        obj.signal_bind('after', refresh)
        self.fm.loader.add(obj)
