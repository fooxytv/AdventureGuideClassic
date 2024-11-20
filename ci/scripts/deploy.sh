#!/bin/bash

if [[ -d "/e" ]]; then
    ostype="windows"
else
    ostype="linux"
    
    if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
    else
        echo "Error: .env file not found."
        exit 1
    fi

    # Confirm that wow_addons_dir is set
    if [ -z "$wow_addons_dir" ]; then
        echo "Error: wow_addons_dir is not set in the .env file."
        exit 1
    fi
fi

# Locate .toc file
toc_file=$(find "$(pwd)" -name "*.toc" | head -n 1)
if [ -z "$toc_file" ]; then
    echo "Error: No .toc file found."
    exit 1
fi

# Extract addon name and version, clean up \r characters, and print debug info
addon_name=$(grep -oP '^## Title:\s*\K.*' "$toc_file" | tr -d '\r')
version=$(grep -oP '^## Version:\s*\K.*' "$toc_file" | tr -d '\r')

echo "Detected TOC file: $toc_file"
echo "Extracted Addon Name: '$addon_name'"
echo "Extracted Version: '$version'"

# Verify that addon_name and version are both populated
if [ -z "$addon_name" ] || [ -z "$version" ]; then
    echo "Error: Addon name or version not found in .toc file."
    exit 1
fi

# # Run package script
./ci/scripts/package.sh

# Define zip file path and output for confirmation
zip_file="ci/dist/${addon_name}-${version}.zip"
echo "Zip file will be: '$zip_file'"

# Local deployment function with quoted paths
local_deploy() {
    # Determine the ostype for the unzip command volume paths in the Docker container
    if [ "$ostype" == "windows" ]; then
        wow_addons_dir="/e/Program Files/World of Warcraft/_classic_era_/Interface/AddOns"
        echo "Copying $zip_file to \"$wow_addons_dir/$addon_name\"..."
        unzip -o "$zip_file" -d "$wow_addons_dir/$addon_name"
        echo "Done."
    else
        echo "Copying $zip_file to "$wow_addons_dir/$addon_name"..."
        unzip -o "$zip_file" -d "$wow_addons_dir/$addon_name"
        echo "Done."
    fi
}

ptr_deploy() {
    # Determine the ostype for the unzip command volume paths in the Docker container
    if [ "$ostype" == "windows" ]; then
        wow_addons_dir_ptr="/e/Program Files/World of Warcraft/_classic_era_ptr_/Interface/AddOns"
        echo "Copying $zip_file to \"$wow_addons_dir_ptr/$addon_name\"..."
        unzip -o "$zip_file" -d "$wow_addons_dir_ptr/$addon_name"
        echo "Done."
    else
        echo "Copying $zip_file to "$wow_addons_dir_ptr/$addon_name"..."
        unzip -o "$zip_file" -d "$wow_addons_dir_ptr/$addon_name"
        echo "Done."
    fi
}

# Run local deploy if the correct argument is provided
if [ "$1" == "local" ] || [ "$1" == "lcl" ]; then
    local_deploy
elif [ "$1" == "ptr" ]; then
    ptr_deploy
else
    echo "Error: Invalid argument. Use 'local' or 'lcl', or 'ptr' to deploy."
    exit 1
fi
