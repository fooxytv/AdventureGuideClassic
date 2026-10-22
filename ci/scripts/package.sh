#!/bin/bash

toc_file=$(find "$(pwd)" -name "*.toc" | head -n 1)

if [ -z "$toc_file" ]; then
    echo -e "\033[31mError: Could not find a .toc file in the current directory or any of its subdirectories.\033[0m"
    exit 1
fi

addon_name=$(awk -F': ' '/^## Title:/{print $2}' "$toc_file" | tr -d '\r')
version=$(awk -F': ' '/^## Version:/{print $2}' "$toc_file" | tr -d '\r')

if [ -z "$addon_name" ] || [ -z "$version" ]; then
    echo -e "\033[31mError: Could not find the addon name or version in the .toc file.\033[0m"
    exit 1
fi

if [ -d "./ci/dist" ]; then
    echo "Removing existing dist directory.."
    rm -r ./ci/dist
fi

echo "Creating 'dist' directory.."
mkdir ./ci/dist

zip_file="ci/dist/${addon_name}-${version}.zip"
echo "Packaging addon into $zip_file.."

#[[
# `zip` is not a given. A Git Bash install ships without it, and there is no
# 7-Zip to fall back on either, so a machine that can run every other script here
# still cannot package. Python already has to be present for ci/tests, so it
# stands in when zip is missing.
#
# The fallback prints every path it adds. The exclusions are the point of this
# step -- .env carries local paths and CLAUDE.local.md is deliberately
# uncommitted -- and a silent reimplementation of someone else's -x list is
# exactly how one of those ends up inside a package. Printed, it can be read.
#
# CLAUDE.local.md is excluded here and not in the zip line above because the
# release build runs on a clean checkout where it does not exist. Locally it
# does.
#]]
if command -v zip >/dev/null 2>&1; then
    zip -r "$zip_file" . -x "*.git*" "dist/*" "ci/*" "README.md" ".vscode/*" ".env*" "code/*" ".claude/*" "CLAUDE.md" "CLAUDE.local.md" "__pycache__/*" "*/__pycache__/*"
else
    echo "zip not found; packaging with python instead."
    python - "$zip_file" <<'PYTHON'
import os, sys, zipfile

EXCLUDED_DIRS = {".git", "dist", "ci", ".vscode", "code", ".claude", "__pycache__"}
EXCLUDED_FILES = {"README.md", "CLAUDE.md", "CLAUDE.local.md"}

written = []
with zipfile.ZipFile(sys.argv[1], "w", zipfile.ZIP_DEFLATED) as archive:
    for root, dirs, files in os.walk("."):
        dirs[:] = [d for d in dirs
                   if d not in EXCLUDED_DIRS and not d.startswith(".git")]
        for name in sorted(files):
            if name in EXCLUDED_FILES or name.startswith(".env") or ".git" in name:
                continue
            path = os.path.relpath(os.path.join(root, name), ".")
            archive.write(path, path.replace(os.sep, "/"))
            written.append(path.replace(os.sep, "/"))
print(f"  {len(written)} files")
for path in written:
    if "/" not in path:
        print(f"    {path}")
PYTHON
fi

if [ $? -eq 0 ]; then
    echo -e "\033[32mSuccessfully packaged addon.\033[0m"
else
    echo -e "\033[31mError: Failed to package addon.\033[0m"
    exit 1
fi
