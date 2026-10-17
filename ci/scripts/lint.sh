#!/bin/bash

# Automatically detect the addon directory by finding the .toc file in the root
ADDON_DIR=$(dirname "$(find . -maxdepth 1 -name "*.toc" | head -n 1)")

if [ -z "$ADDON_DIR" ]; then
    echo -e "\033[31mError: Could not find a .toc file. Please make sure you're in the root of your addon project.\033[0m"
    exit 1
fi

if ! command -v luacheck &> /dev/null
then
    echo -e "\033[31mError: luacheck is not installed. Please install luacheck manually.\033[0m"
    echo "Install with: luarocks install luacheck"
    exit 1
fi

echo "Running Lua lint checks on directory: $(pwd)"

# The 11x undefined-global diagnostics are deliberately NOT ignored.
#
# They used to be, which made the globals list decorative. It matters more in
# this addon than most: every file does `setfenv(2, globalFacade)`, and that
# table's __index falls through to _G -- so a mistyped API name does not raise,
# it resolves to nil and shows up later as a missing icon or a nil compare.
# With 11x on, .luacheckrc is the enumeration of every name allowed to resolve
# that way, and a typo is caught here instead. If a legitimate new API trips
# this, add it to .luacheckrc rather than restoring the ignore.
#
# Still ignored, because they are noise in a WoW addon:
# 211 - unused local variable
# 212 - unused argument
# 213 - unused loop variable
# 231 - variable is never accessed
# 431 - shadowing an upvalue
# 432 - shadowing upvalue argument
# 542 - empty if branch
# 611 - line consists of whitespace
# 612 - line contains trailing whitespace
# 631 - line is too long
#
# The style codes above are pre-existing across the tree (65 findings when this
# gate was first run, 0 of them errors). Silencing them is what lets the gate
# land green and start catching *new* problems today, rather than blocking on a
# tidy-up of files this change does not otherwise touch. The 11x codes, which
# are the ones worth having, stay on.
#
# .lua and .luarocks are the toolchain the CI actions unpack into the
# workspace, so linting $ADDON_DIR would otherwise walk straight into
# luarocks' own source.
luacheck "$ADDON_DIR" \
    --std max \
    --codes \
    --ignore 211 \
    --ignore 212 \
    --ignore 213 \
    --ignore 231 \
    --ignore 431 \
    --ignore 432 \
    --ignore 542 \
    --ignore 611 \
    --ignore 612 \
    --ignore 631 \
    --exclude-files "ci/**" \
    --exclude-files "lib/**" \
    --exclude-files "tools/**" \
    --exclude-files ".lua/**" \
    --exclude-files ".luarocks/**"
