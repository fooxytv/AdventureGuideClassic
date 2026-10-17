#!/usr/bin/env bash

# Build the CURRENT BRANCH with its name stamped into the .toc version, so the
# in-game addon list says which build is loaded rather than just "1.7.1".
#
#   ./ci/scripts/deploy-branch.sh local   # stamp, package, install to Classic Era
#   ./ci/scripts/deploy-branch.sh tbc     # ... to the TBC / Anniversary client
#   ./ci/scripts/deploy-branch.sh ptr     # ... to the PTR client
#   ./ci/scripts/deploy-branch.sh         # stamp and package only, no install
#
# The flavour argument is passed straight through to ci/scripts/deploy.sh, so
# whatever that accepts works here. It reads the target directories from .env.
#
# Two builds of the same version string are the thing this exists to prevent:
# testing a feature branch and a main build that both report 1.7.1 is
# indistinguishable in game until something behaves unexpectedly, and by then
# you are debugging the wrong build.
#
# The .toc edit is temporary. The originals are restored on the way out --
# including on failure or Ctrl-C -- so this never leaves a stamped version to be
# committed by accident. Restoring copies the saved bytes back rather than
# re-editing, which also keeps the mixed CRLF/LF line endings the tracked files
# happen to use.

set -euo pipefail

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo -e "\033[31mError: not inside a git repository.\033[0m" >&2
    exit 1
}

flavour="${1:-}"

mapfile -t toc_files < <(find . -maxdepth 1 -name "*.toc" -printf '%P\n')
if [[ ${#toc_files[@]} -eq 0 ]]; then
    echo -e "\033[31mError: no .toc file in the project root.\033[0m" >&2
    exit 1
fi

branch=$(git rev-parse --abbrev-ref HEAD)
short_sha=$(git rev-parse --short HEAD)

if [[ "$branch" == "HEAD" ]]; then
    # Detached HEAD has no branch name to stamp; the sha is all there is.
    slug="detached"
else
    # Drop the conventional prefix and reduce to something that reads in the
    # addon list's narrow version column, without losing which branch it was.
    # Kept in step with Get-BranchSlug in Install-AdventureGuide.ps1 so a build
    # made either way reports the same version string.
    slug=$(printf '%s' "$branch" \
        | sed -E 's#^(claude|feat|feature|fix|hotfix|docs|chore|release)/##' \
        | sed -E 's#[^A-Za-z0-9]+#-#g; s#^-+##; s#-+$##' \
        | cut -c1-40)
fi

# A dirty tree means the build does not correspond to any commit. Say so in the
# version rather than letting it pass for the sha it is stamped with.
dirty=""
if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
    dirty=".dirty"
    echo -e "\033[33mWorking tree has uncommitted changes; marking the build .dirty\033[0m"
fi

read_version() {
    awk -F': ' '/^## Version:/{print $2}' "$1" | tr -d '\r'
}

base_version=$(read_version "${toc_files[0]}" | sed 's/-.*//')
if [[ -z "$base_version" ]]; then
    echo -e "\033[31mError: no '## Version:' line found in ${toc_files[0]}.\033[0m" >&2
    exit 1
fi

stamped="${base_version}-${slug}.${short_sha}${dirty}"

backup_dir=$(mktemp -d)
restore() {
    local status=$?
    for toc in "${toc_files[@]}"; do
        [[ -f "$backup_dir/$toc" ]] && cp "$backup_dir/$toc" "$toc"
    done
    rm -rf "$backup_dir"
    if [[ $status -ne 0 ]]; then
        echo -e "\033[33mRestored the original .toc versions after a failed run.\033[0m" >&2
    fi
}
trap restore EXIT INT TERM

for toc in "${toc_files[@]}"; do
    cp "$toc" "$backup_dir/$toc"
    # The capture group keeps whatever line ending the Version line already had.
    # These files are mostly CRLF but the release workflow's `sed -i` has left
    # the Version line LF-only, and stamping must not silently change either.
    sed -i -E "s/^(## Version:)[^\r]*(\r?)$/\1 ${stamped}\2/" "$toc"
done

echo "Branch:  $branch"
echo "Version: $stamped"
echo

# Invoked through bash rather than executed: the scripts are tracked mode 644
# (CI chmods the one it runs), so calling them directly works on Git Bash but
# fails with "Permission denied" on a Linux checkout.
if [[ -z "$flavour" ]]; then
    bash ./ci/scripts/package.sh
    echo
    echo -e "\033[32mPackaged only -- pass a flavour (local|tbc|ptr) to install.\033[0m"
else
    bash ./ci/scripts/deploy.sh "$flavour"
fi

echo
echo -e "\033[32mIn game, the addon list should show version ${stamped}.\033[0m"
