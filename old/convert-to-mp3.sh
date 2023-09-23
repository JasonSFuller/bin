#!/bin/bash

# convert all the files in the "orig/" dir to mp3s and store in a "copy/" dir

function a {
  local src="$1"
  local src_dir=$(dirname -- "$src")
  local src_ext="${src##*.}"
  local src_file=$(basename -s ".${src_ext}" -- "$src")
  local dest_dir=$(sed -r 's#^orig/#copy/#' <<< "$src_dir")
  local dest="$dest_dir/$src_file.mp3"
  #printf "src  = %s\ndest = %s" "$src" "$dest"

  if [[ -f "$dest" ]]; then
		echo "INFO: dest exists, skipping: $dest"
		return 1
 	fi
  if [[ ! -d "$dest_dir" ]]; then mkdir -p "$dest_dir"; fi

  ffmpeg -i "$src" \
    -codec:v copy -codec:a libmp3lame -q:a 2 \
    -map_metadata 0 -id3v2_version 3 -write_id3v1 1 \
    "$dest"
}

export -f a

find orig/ -type f -exec bash -c 'a "$0"' {} \;

