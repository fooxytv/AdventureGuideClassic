#!/bin/bash

# Load .env file for all environments
if [ -f .env ]; then
    # Strip quotes and carriage returns from values when exporting
    while IFS='=' read -r key value || [ -n "$key" ]; do
        # Skip comments and empty lines
        [[ "$key" =~ ^#.*$ ]] && continue
        [[ -z "$key" ]] && continue
        # Remove carriage returns, surrounding quotes
        key=$(echo "$key" | tr -d '\r')
        value=$(echo "$value" | tr -d '\r')
        value="${value%\"}"
        value="${value#\"}"
        export "$key=$value"
    done < .env
else
    echo "Error: .env file not found."
    exit 1
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
    if [ -z "$wow_addons_dir_era" ]; then
        echo "Error: wow_addons_dir_era is not set in .env file."
        exit 1
    fi
    echo "Copying $zip_file to \"$wow_addons_dir_era/$addon_name\"..."
    unzip -o "$zip_file" -d "$wow_addons_dir_era/$addon_name"
    echo "Done."
}

ptr_deploy() {
    if [ -z "$wow_addons_dir_ptr" ]; then
        echo "Error: wow_addons_dir_ptr is not set in .env file."
        exit 1
    fi
    echo "Copying $zip_file to \"$wow_addons_dir_ptr/$addon_name\"..."
    unzip -o "$zip_file" -d "$wow_addons_dir_ptr/$addon_name"
    echo "Done."
}

tbc_deploy() {
    if [ -z "$wow_addons_dir_tbc" ]; then
        echo "Error: wow_addons_dir_tbc is not set in .env file."
        exit 1
    fi
    echo "Copying $zip_file to \"$wow_addons_dir_tbc/$addon_name\"..."
    unzip -o "$zip_file" -d "$wow_addons_dir_tbc/$addon_name"
    echo "Done."
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
