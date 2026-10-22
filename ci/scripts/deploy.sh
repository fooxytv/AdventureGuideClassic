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

# sed, not `grep -oP`. PCRE needs a unibyte or UTF-8 locale, and a Git Bash whose
# locale is neither fails the match outright -- "grep: -P supports only unibyte and
# UTF-8 locales" -- leaving both of these empty and killing the deploy on the next
# check. sed has no such dependency.
addon_name=$(sed -n 's/^## Title:[[:space:]]*//p' "$toc_file" | tr -d '\r')
version=$(sed -n 's/^## Version:[[:space:]]*//p' "$toc_file" | tr -d '\r')

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

forever_deploy() {
    if [ -z "$wow_addons_dir_forever" ]; then
        echo "Error: wow_addons_dir_forever is not set in .env file."
        exit 1
    fi
    echo "Copying $zip_file to \"$wow_addons_dir_forever/$addon_name\"..."
    unzip -o "$zip_file" -d "$wow_addons_dir_forever/$addon_name"
    echo "Deployment to Forever complete."
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
elif [ "$1" == "forever" ]; then
    forever_deploy
else
    echo "Error: Invalid argument. Use 'local' or 'lcl', 'tbc', 'forever', or 'ptr'."
    exit 1
fi
