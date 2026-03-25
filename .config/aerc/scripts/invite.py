#!/usr/bin/env python3

from datetime import datetime
from os import readlink
from sys import exit, stderr
from uuid import uuid4
from zoneinfo import ZoneInfo

import vobject


def prompt(label, default=""):
    suffix = f" [{default}]" if default else ""
    print(f"{label}{suffix}: ", end="", flush=True, file=stderr)
    value = input().strip()
    return value or default


def create_event():
    summary = prompt("Summary")
    description = prompt("Description (optional)")
    location = prompt("Location (optional)")

    date_str = prompt("Date (DD.MM.YY)")
    start_str = prompt("Start time (HH:MM)")
    end_str = prompt("End time (HH:MM)")

    dtstart = datetime.strptime(f"{date_str} {start_str}", "%d.%m.%y %H:%M")
    dtend = datetime.strptime(f"{date_str} {end_str}", "%d.%m.%y %H:%M")
    tz = ZoneInfo(readlink("/etc/localtime").split("zoneinfo/")[-1])

    cal = vobject.iCalendar()
    event = cal.add('vevent')
    event.add('uid').value = str(uuid4())
    event.add('summary').value = summary
    event.add('dtstart').value = dtstart.replace(tzinfo=tz) # pyright: ignore
    event.add('dtend').value = dtend.replace(tzinfo=tz) # pyright: ignore
    if description:
        event.add('description').value = description
    if location:
        event.add('location').value = location

    return cal.serialize()

if __name__ == "__main__":
    try:
        print(create_event())
    except KeyboardInterrupt:
       exit(130)
    except Exception as e:
        with open("/home/potamides/aerc.log", "w") as f:
            f.write(f"Error: {e}")
            print(f"Error: {e}", file=stderr)
            exit(1)
