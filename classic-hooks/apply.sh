#!/bin/sh

set -eux

target_kernel_dir="${1:-.}"

# We assume the cocci files are in the same directory as the script
sp_dir="$(dirname "$(realpath -- "$0")")"

# Files declared as patched in the cocci file
files="$(grep -Po 'file in "\K[^"]+' "$sp_file" | sort | uniq)"

cd "$target_kernel_dir"

while IFS= read -r p; do
    spatch --very-quiet --sp-file "$sp_file" --in-place --linux-spacing "$p" || true
done << EOF
"$files"
EOF

spatch --sp-file input_handle_event.cocci --in-place --linux-spacing "$target_kernel_dir/drivers/input/input.c"
find . -iname '*.cocci' | xargs -I{} -P0 spatch --sp-file {} --dir "$target_kernel_dir/fs" --in-place --linux-spacing