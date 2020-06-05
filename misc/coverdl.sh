#!/bin/bash

###############################################################################
#                Download Album Covers from coverartarchive.org               #
###############################################################################

search_url="https://musicbrainz.org/ws/2/release-group/?query="
cover_url="https://coverartarchive.org/release-group/"
cover_type="front"

function find_mbids() {
  IFS=+
  curl -s "$search_url$*" | grep -Po '(?<=release-group id=").*?(?=")'
}

function download_cover() {
  link=$(curl -s $cover_url$1/$cover_type | awk '{print $2;}')
  extension="${link##*.}"
  curl -L#o cover.$extension $link
}

download_cover $(find_mbids $@)
