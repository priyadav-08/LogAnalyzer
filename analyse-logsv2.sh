#!/bin/bash

###################################
#  Author:  Priyanka Yadav
#  Date:  02/02/2026
#
#  Log Analysis Utility
#
#  Version: v2
###################################

TARGET=${1:-"./"}
PATTERN=${2:-"error|critical|fatal"}
CLEANUP=${3:-true}

SCRIPT_PATH=$(realpath "$0")
SCRIPT_NAME=$(basename "$SCRIPT_PATH")

TMP_DIR=""

cleanup_tmp() {
    if [[ -n "$TMP_DIR" && -d "$TMP_DIR" && "$CLEANUP" == "true" ]]; then
        rm -rf "$TMP_DIR"
    fi
}

trap cleanup_tmp EXIT


search_logs() {

    local PATH_TO_SEARCH=$1

    if [[ -f "$PATH_TO_SEARCH" ]]; then

        if [[ "$(realpath "$PATH_TO_SEARCH")" == "$SCRIPT_PATH" ]]; then
            return
        fi

        grep -EinC 5 "$PATTERN" "$PATH_TO_SEARCH" \
        --exclude="$SCRIPT_NAME" \
        --color=auto

    elif [[ -d "$PATH_TO_SEARCH" ]]; then

        grep -rEiC 5 "$PATTERN" "$PATH_TO_SEARCH" \
        --exclude="$SCRIPT_NAME" \
        --color=auto

    fi
}


extract_archive() {

    local FILE=$1
    local TS
    TS=$(date +%Y%m%d_%H%M%S)

    # Base archive name without extension
    local ARCHIVE_NAME
    ARCHIVE_NAME=$(basename "$FILE")
    ARCHIVE_NAME="${ARCHIVE_NAME%.tar.gz}"
    ARCHIVE_NAME="${ARCHIVE_NAME%.tgz}"
    ARCHIVE_NAME="${ARCHIVE_NAME%.tar}"
    ARCHIVE_NAME="${ARCHIVE_NAME%.zip}"

    # Extraction directory: archiveName_timestamp
    TMP_DIR="./${ARCHIVE_NAME}_${TS}"

    mkdir -p "$TMP_DIR"

    case "$FILE" in

        *.tar)
            tar -xf "$FILE" -C "$TMP_DIR"
            ;;

        *.tar.gz|*.tgz)
            tar -xzf "$FILE" -C "$TMP_DIR"
            ;;

        *.zip)
            unzip -q "$FILE" -d "$TMP_DIR"
            ;;

        *)
            echo "Unsupported archive file format"
            exit 1
            ;;

    esac

    search_logs "$TMP_DIR"
}



if [[ -f "$TARGET" ]]; then

    case "$TARGET" in

        *.tar|*.tar.gz|*.tgz|*.zip)
            extract_archive "$TARGET"
            ;;

        *)
            search_logs "$TARGET"
            ;;

    esac

elif [[ -d "$TARGET" ]]; then

    search_logs "$TARGET"

else

    echo "Error: '$TARGET' is not a valid file or directory."
    exit 1

fi

