#!/bin/bash

###################################
#  Author:  Priyanka Yadav
#  Date:  02/02/2026
#
#  This script is for log anlaysis
#
#  Version: v1
###################################


# If $1 is not provided process current directory
TARGET=${1:-"./"}

# If $2 is empty, use default pattern
PATTERN=${2:-"error|critical|fatal"} # This looks for error, critical, or fatal

echo "Processing target ${TARGET}"
echo "Applying search ${PATTERN}"
echo "-------------------------------------------------------------------------------"

if [ -f "$TARGET" ]; then
    echo "--- Searching file: $TARGET ---"
    # -i: ignore case, -E: extended regex, -H: print filename
    grep -EinC 5 "$PATTERN" "$TARGET" --color=auto

elif [ -d "$TARGET" ]; then
    echo "--- Searching directory recursively: $TARGET ---"
    # -r: recursive, -i: ignore case, -E: extended regex
    grep -rEiC 5 "$PATTERN" "$TARGET" --color=auto

else
    echo "Error: '$TARGET' is not a valid file or directory."
    exit 1
fi

