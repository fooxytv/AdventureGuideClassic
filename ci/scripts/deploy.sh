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

addon_name=$(grep -oP '^## Title:\s*\K.*' "$toc_file" | tr -d '\r')
version=$(grep -oP '^## Version:\s*\K.*' "$toc_file" | tr -d '\r')

echo "Detected TOC file: $toc_file"
echo "Extracted Addon Name: '$addon_name'"
echo "Extracted Version: '$version'"

if [ -z "$addon_name" ] || [ -z "$version" ]; then
    echo "Error: Addon name or version not found in .toc file."
    exit 1
fi

./ci/scripts/package.sh

zip_file="ci/dist/${addon_name}-${version}.zip"
echo "Zip file will be: '$zip_file'"

local_deploy() {
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

tbc_deploy() {
    if [ "$ostype" == "windows" ]; then
        wow_addons_dir_tbc="/e/Program Files/World of Warcraft/_anniversary_/Interface/AddOns"
        echo "Copying $zip_file to \"$wow_addons_dir_tbc/$addon_name\"..."
        unzip -o "$zip_file" -d "$wow_addons_dir_tbc/$addon_name"
        echo "Done."
    else
        echo "Copying $zip_file to "$wow_addons_dir_tbc/$addon_name"..."
        unzip -o "$zip_file" -d "$wow_addons_dir_tbc/$addon_name"
        echo "Done."
    fi
}

if [ "$1" == "local" ] || [ "$1" == "lcl" ]; then
    local_deploy
elif [ "$1" == "ptr" ]; then
    ptr_deploy
elif [ "$1" == "tbc" ]; then
    tbc_deploy
else
    echo "Error: Invalid argument. Use 'local' or 'lcl', or 'ptr' to deploy."
    exit 1
fi
