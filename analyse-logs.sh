#!/bin/bash

###################################
#  Author:  Priyanka Yadav
#  Date:  02/02/2026
#
#  This script is for log anlaysis
#
#  Version: v1
###################################


TARGET=${1:-"./"}
PATTERN=${2:-"error|critical|fatal"}

echo "Processing target ${TARGET}"
echo "Applying search ${PATTERN}"
echo "-------------------------------------------------------------------------------"

# ZIP handling
if [[ "$TARGET" == *.zip ]]; then
    echo "--- ZIP file detected: $TARGET ---"

    TMP_DIR=$(mktemp -d)
    unzip -q "$TARGET" -d "$TMP_DIR"

    grep -rEiC 5 "$PATTERN" "$TMP_DIR" --color=auto

    rm -rf "$TMP_DIR"
    exit 0

elif [ -f "$TARGET" ]; then
    echo "--- Searching file: $TARGET ---"
    grep -EinC 5 "$PATTERN" "$TARGET" --color=auto

elif [ -d "$TARGET" ]; then
    echo "--- Searching directory recursively: $TARGET ---"
    grep -rEiC 5 "$PATTERN" "$TARGET" --color=auto

else
    echo "Error: '$TARGET' is not a valid file or directory."
    exit 1
fi
