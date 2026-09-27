#!/usr/bin/env bash
#
# Installs Adventure Guide Classic straight from GitHub into a WoW AddOns folder,
# with the branch name stamped into the version. The macOS and Linux counterpart
# of Install-AdventureGuide.ps1, and deliberately kept in step with it: same
# exclusions, same version stamp, same remembered-folder behaviour, so a build
# installed on either machine reports the same string in the addon list.
#
# For a machine that plays the game rather than builds the addon. No git, no
# toolchain -- it downloads the branch itself, drops the files that do not belong
# in an addon, and installs what is left.
#
# Usage:
#   ./install-adventure-guide.sh [options]
#   curl -fsSL <raw-url>/install-adventure-guide.sh | bash -s -- [options]
#
#   -b, --branch <name>     Branch, tag or commit to install (default: main)
#   -p, --addons-path <dir> Install into this Interface/AddOns folder
#   -f, --flavour <text>    Install to the client whose folder matches, e.g. era
#   -a, --all               Install to every client found
#       --forget            Ignore the remembered folder and pick again
#   -h, --help              Show this
#
# Download it once and keep it:
#   curl -fsSLO https://raw.githubusercontent.com/fooxytv/AdventureGuideClassic/main/ci/scripts/install-adventure-guide.sh
#   chmod +x install-adventure-guide.sh
#   ./install-adventure-guide.sh --branch feat/my-thing
#
# Or run it straight from the pipe, naming a client since there is no terminal
# to ask at:
#   curl -fsSL <that url> | bash -s -- --branch feat/my-thing --flavour era
#
# Written for bash 3.2, which is what macOS ships.

set -euo pipefail

OWNER='fooxytv'
REPO='AdventureGuideClassic'
ADDON_NAME='AdventureGuideClassic'   # must match the .toc basename

# Mirrors the exclusion list in Install-AdventureGuide.ps1 and ci/scripts/package.sh.
# Deny rather than allow: a new folder of addon content then ships by default,
# where an allow-list would silently leave it out.
EXCLUDE_DIRS='.git .github ci tools docs code dist .vscode .claude'
EXCLUDE_FILES='README.md CLAUDE.md CLAUDE.local.md todo.md .luacheckrc .gitignore .gitattributes'

BRANCH='main'
ADDONS_PATH=''
FLAVOUR=''
INSTALL_ALL=0
FORGET=0

SETTINGS_DIR="${XDG_CONFIG_HOME:-$HOME/Library/Application Support}/$ADDON_NAME"
SETTINGS_FILE="$SETTINGS_DIR/install-settings"

# Where WoW usually lives. macOS has no drive letters, but a second disk is
# just as common and mounts under /Volumes, so every mounted volume is searched
# the way the PowerShell script searches every fixed drive. A remembered root is
# searched too, so a client installed somewhere unusual is named only once.
default_roots() {
    {
        printf '%s\n' '/'
        printf '%s\n' "$HOME"
        if [ -d /Volumes ]; then
            for vol in /Volumes/*/; do
                [ -d "$vol" ] || continue
                printf '%s\n' "${vol%/}"
            done
        fi
    } | while IFS= read -r base; do
        [ -n "$base" ] || continue
        # "/" would otherwise produce "//Applications".
        case "$base" in
            /) base='' ;;
        esac
        printf '%s\n' "$base/Applications/World of Warcraft"
        printf '%s\n' "$base/World of Warcraft"
        printf '%s\n' "$base/Games/World of Warcraft"
        printf '%s\n' "$base/Applications/Battle.net/World of Warcraft"
    done
}

flavour_label() {
    # Only the folders whose meaning is certain get a friendly name. Anything
    # else keeps its own: a confident-sounding wrong label is worse than the raw
    # folder, which is at least what the player sees in the launcher.
    case "$1" in
        _classic_era_ptr_) printf 'Classic Era PTR' ;;
        _classic_era_)     printf 'Classic Era (incl. Season of Discovery, Hardcore)' ;;
        _classic_ptr_)     printf 'Classic progression PTR' ;;
        _classic_beta_)    printf 'Classic beta' ;;
        _classic_)         printf 'Classic progression (Anniversary / TBC)' ;;
        _retail_)          printf 'Retail' ;;
        _ptr_)             printf 'Retail PTR' ;;
        _beta_)            printf 'Retail beta' ;;
        *)                 printf '%s' "$1" ;;
    esac
}

say()  { printf '%s\n' "$*"; }
dim()  { printf '\033[2m%s\033[0m\n' "$*"; }
warn() { printf '\033[33m%s\033[0m\n' "$*" >&2; }
die()  { printf '\033[31m%s\033[0m\n' "$*" >&2; exit 1; }

usage() {
    # Piped from curl there is no script file to read the header out of, so the
    # summary is spelled out rather than extracted.
    if [ -r "$0" ] && [ "$0" != "bash" ] && [ "$0" != "-" ]; then
        sed -n '3,26p' "$0" | sed 's/^# \{0,1\}//'
    else
        cat <<'USAGE'
Installs Adventure Guide Classic from GitHub into a WoW AddOns folder.

  -b, --branch <name>     Branch, tag or commit to install (default: main)
  -p, --addons-path <dir> Install into this Interface/AddOns folder
  -f, --flavour <text>    Install to the client whose folder matches, e.g. era
  -a, --all               Install to every client found
      --forget            Ignore the remembered folder and pick again
  -h, --help              Show this
USAGE
    fi
    exit 0
}

while [ $# -gt 0 ]; do
    case "$1" in
        -b|--branch)       BRANCH="${2:-}"; shift 2 ;;
        -p|--addons-path)  ADDONS_PATH="${2:-}"; shift 2 ;;
        -f|--flavour)      FLAVOUR="${2:-}"; shift 2 ;;
        -a|--all)          INSTALL_ALL=1; shift ;;
        --forget)          FORGET=1; shift ;;
        -h|--help)         usage ;;
        *)                 die "Unknown option: $1  (try --help)" ;;
    esac
done

for tool in curl unzip awk sed; do
    command -v "$tool" >/dev/null 2>&1 || die "Required tool not found: $tool"
done

# --- settings -------------------------------------------------------------

remembered_path() {
    [ -f "$SETTINGS_FILE" ] || return 0
    sed -n 's/^addons_path=//p' "$SETTINGS_FILE" | head -1
}

remembered_roots() {
    [ -f "$SETTINGS_FILE" ] || return 0
    sed -n 's/^root=//p' "$SETTINGS_FILE"
}

remember() {
    # An AddOns path is <root>/<flavour>/Interface/AddOns, so its WoW root is
    # three levels up. Remembering the root as well as the leaf is what lets a
    # later --all find the other clients installed beside it.
    local path="$1" root existing
    root="$(cd "$path/../../.." 2>/dev/null && pwd || true)"
    existing="$(remembered_roots)"
    mkdir -p "$SETTINGS_DIR"
    {
        printf 'addons_path=%s\n' "$path"
        # Roots accumulate rather than replace. Naming one unusual install by
        # hand teaches the script where this machine keeps WoW, and a later
        # --all then finds the clients sitting beside it.
        printf '%s\n' "$existing" | while IFS= read -r known; do
            [ -n "$known" ] && [ "$known" != "$root" ] && printf 'root=%s\n' "$known"
        done
        [ -n "$root" ] && printf 'root=%s\n' "$root"
    } > "$SETTINGS_FILE.new"
    mv "$SETTINGS_FILE.new" "$SETTINGS_FILE"
}

# --- discovery ------------------------------------------------------------

# Prints "flavour<TAB>path" for every AddOns folder found.
discover() {
    { remembered_roots; default_roots; } | while IFS= read -r root; do
        [ -n "$root" ] && [ -d "$root" ] || continue
        for client in "$root"/*/; do
            [ -d "${client}Interface/AddOns" ] || continue
            local name
            name="$(basename "$client")"
            printf '%s\t%s\n' "$name" "${client}Interface/AddOns"
        done
    done | sort -u
}

# --- version --------------------------------------------------------------

branch_slug() {
    # Kept in step with Install-AdventureGuide.ps1 and ci/scripts/deploy-branch.sh
    # so a build made any of the three ways reports the same version string.
    printf '%s' "$1" \
        | sed -E 's#^(claude|feat|feature|fix|hotfix|docs|chore|release)/##' \
        | sed -E 's/[^A-Za-z0-9]+/-/g' \
        | sed -E 's/^-+//; s/-+$//' \
        | cut -c1-40
}

commit_sha() {
    # Anonymous and rate-limited to 60/hour, far more than anyone installs. The
    # sha is only for the version stamp, so failing here must not stop the install.
    curl -fsSL --max-time 30 -H "User-Agent: $ADDON_NAME" \
        "https://api.github.com/repos/$OWNER/$REPO/commits/$1" 2>/dev/null \
        | sed -n 's/.*"sha"[[:space:]]*:[[:space:]]*"\([0-9a-f]\{7\}\).*/\1/p' \
        | head -1
}

# --- install --------------------------------------------------------------

staging="$(mktemp -d "${TMPDIR:-/tmp}/agc-install.XXXXXX")"
cleanup() { rm -rf "$staging"; }
trap cleanup EXIT

say "Downloading $BRANCH ..."
archive="$staging/source.zip"
curl -fsSL --max-time 120 -H "User-Agent: $ADDON_NAME" \
    -o "$archive" \
    "https://codeload.github.com/$OWNER/$REPO/zip/refs/heads/$BRANCH" \
    || die "Could not download '$BRANCH'. Is it a branch of $OWNER/$REPO?"

unzip -q "$archive" -d "$staging" || die "The download was not a readable zip."
extracted="$(find "$staging" -maxdepth 1 -type d -name "$REPO-*" | head -1)"
[ -n "$extracted" ] || die "The downloaded archive did not contain a folder."
[ -f "$extracted/$ADDON_NAME.toc" ] \
    || die "No $ADDON_NAME.toc in the download -- is '$BRANCH' a branch of this addon?"

slug="$(branch_slug "$BRANCH")"
sha="$(commit_sha "$BRANCH" || true)"
[ -n "$sha" ] || warn "Could not read the commit for '$BRANCH'; stamping without a sha."

base_version="$(sed -n 's/^## Version:[[:space:]]*//p' "$extracted/$ADDON_NAME.toc" \
    | head -1 | tr -d '\r' | cut -d'-' -f1)"
[ -n "$base_version" ] || die "No '## Version:' line in $ADDON_NAME.toc."

if [ -n "$sha" ]; then stamped="$base_version-$slug.$sha"; else stamped="$base_version-$slug"; fi

# Stamp every .toc, so whichever flavour the client loads reports the same.
# The .toc files are CRLF, and awk strips only the line terminator, so the
# carriage return is put back explicitly rather than left half-converted.
for toc in "$extracted"/*.toc; do
    [ -f "$toc" ] || continue
    awk -v v="$stamped" '
        /^## Version:/ { sub(/\r$/, ""); printf "## Version: %s\r\n", v; next }
        { print }
    ' "$toc" > "$toc.stamped" && mv "$toc.stamped" "$toc"
done
say "Version: $stamped"

# --- choose where ---------------------------------------------------------

targets=''
if [ -n "$ADDONS_PATH" ]; then
    [ -d "$ADDONS_PATH" ] || die "No such folder: $ADDONS_PATH"
    targets="$ADDONS_PATH"
    remember "$ADDONS_PATH"
else
    [ "$FORGET" -eq 1 ] && rm -f "$SETTINGS_FILE"
    found="$(discover)"
    [ -n "$found" ] || die "No WoW AddOns folder found. Pass --addons-path to name one."

    if [ -n "$FLAVOUR" ]; then
        targets="$(printf '%s\n' "$found" | awk -F'\t' -v f="$FLAVOUR" \
            'tolower($1) ~ tolower(f) { print $2 }')"
        [ -n "$targets" ] || die "No client matched '--flavour $FLAVOUR'."
    elif [ "$INSTALL_ALL" -eq 1 ]; then
        targets="$(printf '%s\n' "$found" | cut -f2)"
    else
        saved="$(remembered_path)"
        if [ "$FORGET" -eq 0 ] && [ -n "$saved" ] && [ -d "$saved" ]; then
            targets="$saved"
        elif [ "$(printf '%s\n' "$found" | wc -l)" -eq 1 ]; then
            targets="$(printf '%s\n' "$found" | cut -f2)"
            remember "$targets"
        elif [ -t 0 ]; then
            say ""
            say "More than one client found:"
            i=1
            while IFS="$(printf '\t')" read -r name path; do
                printf '  [%d] %-18s %s\n' "$i" "$name" "$(flavour_label "$name")"
                dim "      $path"
                i=$((i + 1))
            done <<EOF
$found
EOF
            printf '  [A] all of them\n\n'
            printf 'Which one? (1-%d, or A) ' "$((i - 1))"
            read -r answer
            case "$answer" in
                [Aa]) targets="$(printf '%s\n' "$found" | cut -f2)" ;;
                ''|*[!0-9]*) die "Not a valid choice: '$answer'" ;;
                *)
                    targets="$(printf '%s\n' "$found" | sed -n "${answer}p" | cut -f2)"
                    [ -n "$targets" ] || die "Not a valid choice: '$answer'"
                    remember "$targets"
                    dim "Remembered. Use --flavour, --all or --forget to install elsewhere."
                    ;;
            esac
        else
            # Piped from curl, so there is no one to ask.
            say "More than one client found:"
            printf '%s\n' "$found" | awk -F'\t' '{ print "  " $1 }'
            die "Pass --flavour or --all when running this from a pipe."
        fi
    fi
fi

# --- copy -----------------------------------------------------------------

rsync_excludes=''
for d in $EXCLUDE_DIRS; do rsync_excludes="$rsync_excludes --exclude=/$d/"; done
for f in $EXCLUDE_FILES; do rsync_excludes="$rsync_excludes --exclude=/$f"; done

printf '%s\n' "$targets" | while IFS= read -r addons; do
    [ -n "$addons" ] || continue
    destination="$addons/$ADDON_NAME"

    # Removed rather than copied over, so a file deleted or renamed upstream
    # cannot linger in the AddOns folder and keep being loaded from the .toc.
    rm -rf "$destination"
    mkdir -p "$destination"

    if command -v rsync >/dev/null 2>&1; then
        # shellcheck disable=SC2086
        rsync -a $rsync_excludes "$extracted/" "$destination/"
    else
        cp -R "$extracted/." "$destination/"
        for d in $EXCLUDE_DIRS; do rm -rf "${destination:?}/$d"; done
        for f in $EXCLUDE_FILES; do rm -f "${destination:?}/$f"; done
    fi

    say "Installed to $destination"
done

say ""
say "Done. Reload the game, or /reload if it is already running."
