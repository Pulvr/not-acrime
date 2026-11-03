#!/bin/bash

# Check if a directory argument was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <subdirectory_path>"
    exit 1
fi

TARGET_DIR=$1

# Check if the provided path is actually a directory
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

echo "Running gdlint on all .gd files in: $TARGET_DIR"
echo "------------------------------------------------"

# Use 'find' to locate all .gd files and execute gdlint on them
# -type f: Look for files only
# -name "*.gd": Filter for Godot script files
# -exec gdlint {} +: Run gdlint on the found files as efficiently as possible
find "$TARGET_DIR" -type f -name "*.gd" -exec gdlint {} +

echo "------------------------------------------------"
echo "Linting complete."
