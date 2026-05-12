#!/bin/bash
#########################################################
# SCRIPT  : tag-release.sh                              #
#########################################################
# AUTHORS : swtor00                                     #
# EMAIL   : swtor00@protonmail.com                      #
# OS      : Tails 7.7.3 or higher                       #
#                                                       #
# VERSION : 0.91                                        #
# STATE   : BETA                                        #
#                                                       #
# This shell script is part of the swtor-addon-to-tails #
#                                                       #
# DATE    : 12-05-2026                                  #
# LICENCE : GPL 2                                       #
#########################################################
# Github-Homepage :                                     #
# https://github.com/swtor00/swtor-addon-to-tails       #
#########################################################

# Determine repo directory (parent of shell-scripts/)
REPO_DIR="$(dirname "$(pwd)")"

# Git directory check
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "ERROR: No Git repository found in: $REPO_DIR"
    echo "Please check the directory structure."
    exit 1
fi

cd "$REPO_DIR"

git fetch --tags

# Get the latest tag
LAST_TAG=$(git tag --sort=-v:refname | head -n 1)

if [ -z "$LAST_TAG" ]; then
    echo "No existing tag found. Creating first tag."
    SUGGESTED="v0.91"
else
    echo "Last tag: $LAST_TAG"
    # Calculate next number (e.g. v0.80 -> v0.81)
    LAST_NUM=$(echo "$LAST_TAG" | sed 's/v0\.//')
    NEXT_NUM=$(echo "$LAST_NUM + 1" | bc)
    SUGGESTED="v0.$NEXT_NUM"
fi

echo "Suggested version: $SUGGESTED"
echo ""
read -p "Enter version number (press Enter for $SUGGESTED): " USER_INPUT

# If nothing entered, use the suggested version
if [ -z "$USER_INPUT" ]; then
    VERSION="$SUGGESTED"
else
    VERSION="$USER_INPUT"
fi

# Prepend 'v' if missing
if [[ "$VERSION" != v* ]]; then
    VERSION="v$VERSION"
fi

echo ""
echo "=== TAG-RELEASE ==="
echo "Date:    $(date '+%d.%m.%Y %H:%M:%S')"
echo "Version: $VERSION"
echo ""
read -p "Confirm? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "Aborted."
    exit 0
fi

git tag -a "$VERSION" -m "Version $VERSION - stable release"
if [ $? -ne 0 ]; then
    echo "ERROR: Could not create Git tag!"
    exit 1
fi
echo "Tag created: OK"

git push origin "$VERSION"
if [ $? -ne 0 ]; then
    echo "ERROR: Git push failed!"
    exit 1
fi
echo "Tag pushed:  OK"

echo ""
echo "=== Tag-Release completed ==="


