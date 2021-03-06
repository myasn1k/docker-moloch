#!/bin/bash

# apply patches in the /patch directory
# they must be relative to the moloch base directory
for patch_file in $MOLOCHDIR/*.patch; do
    [ -f "$patch_file" ] || break

    # check if it's a git patch or not
    if grep -q -- "--git" "$patch_file"; then
        # ignore a or b path prefix in the patch file
        patch -d $MOLOCHDIR -p1 < "$patch_file"
    else
        patch -d $MOLOCHDIR < "$patch_file"
    fi

    # remove the applied patch file
    rm "$patch_file"
done
