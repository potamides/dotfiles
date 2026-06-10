from collections import namedtuple
import fcntl
import mmap
import os
from os.path import abspath, basename, isdir
from shlex import quote
import struct
from subprocess import CalledProcessError, DEVNULL, PIPE, check_call
import sys
from tempfile import TemporaryFile
import termios

from ranger.api.commands import Command
from ranger.core.loader import CommandLoader
from ranger.core.shared import FileManagerAware
from ranger.ext.img_display import (
    ImageDisplayError,
    ImageDisplayer,
    register_image_displayer,
    temporarily_moved_cursor,
)


class umount(Command):
    """
    :umount [device_mount_point]

    unmount removable devices
    """

    def execute(self):
        cmd = "umount "
        if self.arg(1):
            self.fm.run(cmd + quote(self.arg(1)))
        else:
            self.fm.run(cmd + quote(self.fm.thisfile.path))


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


class fzf_select(Command):
    """
    :fzf_select

    Find a file using fzf.

    With a prefix argument select only directories.

    See: https://github.com/junegunn/fzf
    """
    def execute(self):
        if self.quantifier:
            # match only directories
            command=r"find -L . \( -path '*/\.*' -o -fstype 'dev' -o -fstype 'proc' \) -prune \
            -o -type d -print 2> /dev/null | sed 1d | cut -b3- | fzf +m"
        else:
            # match files and directories
            command=r"find -L . \( -path '*/\.*' -o -fstype 'dev' -o -fstype 'proc' \) -prune \
            -o -print 2> /dev/null | sed 1d | cut -b3- | fzf +m"
        fzf = self.fm.execute_command(command, universal_newlines=True, stdout=PIPE)
        stdout, _ = fzf.communicate()
        if fzf.returncode == 0:
            fzf_file = abspath(stdout.rstrip('\n'))
            if isdir(fzf_file):
                self.fm.cd(fzf_file)
            else:
                self.fm.select_file(fzf_file)


class extracthere(Command):
    def execute(self):
        """
        :extracthere

        Extract copied files to current directory
        """
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
            descr = "extracting: " + basename(one_file.path)
        else:
            descr = "extracting files from: " + basename(one_file.dirname)
        obj = CommandLoader(args=['aunpack'] + au_flags + [f.path for f in copied_files], descr=descr)

        obj.signal_bind('after', refresh)
        self.fm.loader.add(obj)


@register_image_displayer("sixel")
class SixelImageDisplayer(ImageDisplayer, FileManagerAware):
    """Backport of SIXEL ImageDisplayer of ranger-git."""

    CacheableSixelImage = namedtuple("_CacheableSixelImage", ("width", "height", "inode"))
    CachedSixelImage = namedtuple("_CachedSixelImage", ("image", "fh"))

    def __init__(self):
        self.win = None
        self.cache = {}
        self.fm.signal_bind('preview.cleared', lambda signal: self._clear_cache(signal.path))

    @staticmethod
    def get_terminal_size():
        farg = struct.pack("HHHH", 0, 0, 0, 0)
        fd_stdout = sys.stdout.fileno()
        fretint = fcntl.ioctl(fd_stdout, termios.TIOCGWINSZ, farg)
        return struct.unpack("HHHH", fretint)

    @classmethod
    def get_font_dimensions(cls):
        rows, cols, xpixels, ypixels = cls.get_terminal_size()
        return (xpixels // cols), (ypixels // rows)

    def _clear_cache(self, path):
        if os.path.exists(path):
            self.cache = {
                ce: cd
                for ce, cd in self.cache.items()
                if ce.inode != os.stat(path).st_ino
            }

    def _sixel_cache(self, path, width, height):
        stat = os.stat(path)
        cacheable = self.CacheableSixelImage(width, height, stat.st_ino)

        if cacheable not in self.cache:
            font_width, font_height = self.get_font_dimensions()
            fit_width = font_width * width
            fit_height = font_height * height

            cached = TemporaryFile("w+", prefix="ranger", suffix=path.replace(os.sep, "-"))

            environ = dict(os.environ)
            environ.setdefault("MAGICK_OCL_DEVICE", "true")
            try:
                check_call(
                    [
                        "convert",
                        path + "[0]",
                        "-geometry",
                        "{0}x{1}>".format(fit_width, fit_height),
                        "-dither",
                        "FloydSteinberg",
                        "sixel:-",
                    ],
                    stdout=cached,
                    stderr=DEVNULL,
                    env=environ,
                )
            except CalledProcessError:
                raise ImageDisplayError("ImageMagick failed processing the SIXEL image")
            except FileNotFoundError:
                raise ImageDisplayError("SIXEL image previews require ImageMagick")
            finally:
                cached.flush()

            if os.fstat(cached.fileno()).st_size == 0:
                raise ImageDisplayError("ImageMagick produced an empty SIXEL image file")

            self.cache[cacheable] = self.CachedSixelImage(mmap.mmap(cached.fileno(), 0), cached)

        return self.cache[cacheable].image

    # pylint: disable=too-many-positional-arguments
    def draw(self, path, start_x, start_y, width, height):
        if self.win is None:
            self.win = self.fm.ui.win.subwin(height, width, start_y, start_x)
        else:
            self.win.mvwin(start_y, start_x)
            self.win.resize(height, width)

        with temporarily_moved_cursor(start_y, start_x):
            sixel = self._sixel_cache(path, width, height)[:]
            sys.stdout.buffer.write(sixel)
            sys.stdout.flush()

    def clear(self, start_x, start_y, width, height):
        if self.win is not None:
            self.win.clear()
            self.win.refresh()

            self.win = None

        self.fm.ui.win.redrawwin()

    def quit(self):
        self.clear(0, 0, 0, 0)
        self.cache = {}
