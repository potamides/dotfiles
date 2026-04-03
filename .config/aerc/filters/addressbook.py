#!/usr/bin/env python

###############################################################################
#            Minimalistic address book for the aerc email client.             #
###############################################################################

from argparse import ArgumentParser
from email.utils import parseaddr
from logging import error, warning
from os import getenv
from pathlib import Path
from re import escape, search
from sys import stdin, exit

ADDRESS_BOOK = Path(getenv("XDG_CONFIG_HOME", Path.home())) / ".config/aerc/addressbook.tsv"


def match_addr(addr, content):
    return search(rf'\b{escape(addr)}\t', content) is not None


def iter_addrs(pattern):
    for line in ADDRESS_BOOK.read_text().splitlines():
        if pattern.lower() in line.lower():
            yield line


def add_addr(addr, verbose=False):
    name, email = parseaddr(addr, strict=False)
    name = " ".join(reversed(name.split(",", 1)))

    if name + email:
        if search(r'no.?reply', email.lower()):
            if verbose:
                warning("Skipping noreply address.")
        elif not match_addr(email, ADDRESS_BOOK.read_text()):
            with ADDRESS_BOOK.open("a") as f:
                f.write(f"{email}\t{name}\n")
        elif verbose:
            warning("Email already exists, skipping.")
    else:
        error("Address is not a RFC 5322 compliant string!")
        return 1


def remove_addr(addr, verbose=False):
    if match_addr(addr, content:=ADDRESS_BOOK.read_text()):
        lines = [line for line in content.splitlines(True) if not match_addr(addr, line)]
        ADDRESS_BOOK.write_text("".join(lines))
    elif verbose:
        error("Email does not exist!")
        return 1


def parse_args():
    parser = ArgumentParser(
        description="Minimalistic address book for the aerc email client."
    )
    parser.add_argument("--verbose",
        action="store_true",
        help="Enable verbose logging.",
    )

    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        "--match",
        help="Match search string against all registered addresses.",
    )
    group.add_argument(
        "--add",
        help="Manually add an address as an RFC 5322 compliant string.",
    )
    group.add_argument(
        "--remove",
        help="Remove an email from the addressbook.",
    )

    return parser.parse_args()


if __name__ == "__main__":
    ADDRESS_BOOK.touch(exist_ok=True)
    args = parse_args()

    if args.match:
        print(*iter_addrs(args.match), sep="\n")
    elif args.add:
        exit(add_addr(args.add, verbose=args.verbose))
    elif args.remove:
        exit(remove_addr(args.remove, verbose=args.verbose))
    elif addr:=getenv("AERC_FROM"):
        add_addr(addr, args.verbose)
        print(stdin.read())
