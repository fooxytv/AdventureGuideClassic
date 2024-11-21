#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define paths
dist_dir="./ci/dist"
temp_dir="./ci/temp"

# Define the addon name
addon_name="AdventureGuideClassic"

# Find the existing ZIP file in ci/dist/
existing_zip=$(find "$dist_dir" -type f -name "*.zip" | head -n 1)

# Ensure there is a ZIP file to process
if [ -z "$existing_zip" ]; then
    echo -e "\033[31mError: No ZIP file found in $dist_dir.\033[0m"
    exit 1
fi

# Extract the base name and version_build from the ZIP file name
base_name=$(basename "$existing_zip" .zip)
version_build=$(echo "$base_name" | sed "s/^$addon_name-//")

if [ -z "$version_build" ]; then
    echo -e "\033[31mError: Could not extract version and build number from the ZIP file name.\033[0m"
    exit 1
fi

# Prepare temporary directories
echo "Setting up temporary directory..."
rm -rf "$temp_dir"
mkdir -p "$temp_dir/$addon_name"

# Unzip the existing file into the addon directory
echo "Extracting $existing_zip to $temp_dir/$addon_name..."
unzip -q "$existing_zip" -d "$temp_dir/$addon_name"

# Create the new ZIP file
output_zip="$(pwd)/$dist_dir/${version_build}.zip"
echo "Creating new ZIP file: $output_zip"
cd "$temp_dir"
zip -r "$output_zip" "$addon_name"
cd - > /dev/null

# Clean up
echo "Cleaning up temporary files..."
rm -rf "$temp_dir"

# Final confirmation
if [ -f "$output_zip" ]; then
    echo -e "\033[32mSuccessfully created new ZIP file: $output_zip\033[0m"
else
    echo -e "\033[31mError: Failed to create new ZIP file.\033[0m"
    exit 1
fi