#!/bin/bash --

# Building Researcher (Merging Builder - Example).

# Defining colours
BLUE='\033[1;34m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'
PURPLE='\033[1;35m'

# Exit immediately if a command exits with a non-zero status.
set -e

# Folder name
FOLDER=$(basename $PWD)

echo
echo -e "${CYAN}=== Preparing Example $PWD...${RESET}"
echo

# Resolving dependencies
echo
echo -e "${BLUE}=== Resolving Dependencies $PWD...${RESET}"
echo

# Make sure .dart_tool/package_config.json exists.
dart pub get

# Upgrade packages.
dart pub upgrade

echo
echo -e "${PURPLE}=== Checking Source Code Formatting${RESET} $PWD..."
echo
# Overwrite files with formatted content: -w
# Dry run: -n
dart format bin lib

# Analyze dart files
echo
echo -e "${BLUE}=== Analyzing $PWD...${RESET}"
echo
dart analyze \
    --fatal-warnings \
    --fatal-infos \

echo
echo -e "${CYAN}=== Building $PWD...${RESET}"
echo
rm -rf .dart_tool/build/
grep -q build_runner pubspec.yaml && \
    dart run build_runner build \
        --delete-conflicting-outputs \
        --fail-on-severe

# Running tests
# echo
# echo -e "${CYAN}=== Testing $PWD...${RESET}"
# echo
# dart test -r expanded