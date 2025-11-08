#!/bin/bash

# Script for creating reproducible .ISO images from a specified path.
# Path can be specified as user input after running the script,
# or passed as an argument from the terminal.
# Resulting file will be created near the script and called 'TAS_CD.iso'.
# To make it reproducible, we force date (2001-01-01) and mode (0444) on all files.
# At the end we print paths and hashes of all packaged files (MD5 and SHA-1).

export SOURCE_DATE_EPOCH="$(date -d20010101 -u +%s)"
output_filename=TAS_CD # also used as volume ID, so must be [A-Z_]+
file_mode=0444

folder="$1"
while [ ! -d "$folder" ]; do
	[ -z "$folder" ] || printf "'%s' not a directory?\n" "$folder"
	read -p "Enter path to dir containing source files: " folder
done
list="$(mktemp)"
(cd "$folder"; for f in *; do printf "%s\n" "$f=$PWD/$f"; done) \
	| LC_ALL=C sort >"$list"

xorriso \
	-preparer_id xorriso \
	-volume_date 'all_file_dates' "=$SOURCE_DATE_EPOCH" \
	-as mkisofs \
	-iso-level 3 \
	-volid "$output_filename" \
	-graft-points \
	-full-iso9660-filenames \
	-joliet \
	-file-mode $file_mode \
	-uid 0 \
	-gid 0 \
	-path-list "$list" \
	-output "$output_filename".iso

rm -f "$list"
cd "$folder"

echo "MD5:"
find . -type f -exec md5sum {} \;
echo
echo "SHA-1:"
find . -type f -exec sha1sum {} \;
