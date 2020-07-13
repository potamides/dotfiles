#!/usr/bin/python

###############################################################################
#                Download Album Covers from coverartarchive.org               #
###############################################################################

from sys import argv
from urllib.request import urlopen
from urllib.error import HTTPError
from xml.etree import ElementTree

SEARCH_URL = "https://musicbrainz.org/ws/2/release-group"
COVER_URL = "https://coverartarchive.org/release-group"
COVER_TYPE = "front"

def find_mbids(params):
    with urlopen(f"{SEARCH_URL}/?query={'+'.join(params)}") as conn:
        root = ElementTree.fromstring(conn.read())
        namespace = {"rls": root.tag.split("}")[0].lstrip("{")}
        mbids = list()

        for release_group in root.find("rls:release-group-list", namespace):
            path = "./rls:artist-credit/rls:name-credit/rls:artist/rls:name"

            mbid = release_group.get("id")
            title = release_group.find("rls:title", namespace).text
            artist = release_group.find(path, namespace).text

            mbids.append((mbid, f"{artist} - {title}"))

        return mbids

def select_mbid(mbids):
    print("\n".join([f"{idx:2}. {name}" for idx, (_, name) in enumerate(mbids, 1)]))
    while True:
        try:
            idx = input("Enter a selection (default=1): ")
            return mbids[int(idx) - 1 if idx else 0][0]
        except ValueError:
            continue

def download_cover(mbid):
    try:
        with urlopen(f"{COVER_URL}/{mbid}/{COVER_TYPE}") as conn:
            extension = conn.info().get_content_subtype()
            with open(f"cover.{extension}", "wb") as f:
                f.write(conn.read())
            return True
    except HTTPError:
        return False


if __name__ == "__main__" and len(argv) > 1:
    mbids = find_mbids(argv[1:])
    mbid = select_mbid(mbids)
    while not download_cover(mbid):
        print("\nNo cover for current selection available, try something else.")
        mbids = [item for item in mbids if item[0] != mbid]
        mbid = select_mbid(mbids)
