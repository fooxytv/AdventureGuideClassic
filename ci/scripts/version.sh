toc_file=$(find "$(pwd)" -name "*.toc" | head -n 1)
pre_release=false
pre_release_type=""
commit_hash=$(git rev-parse --short HEAD)

increment_version() {
    local version=$1
    local part=$2

    IFS='.' read -r major minor patch <<< "$version"

    case $part in
        major)
            ((major++))
            minor=0
            patch=0
            ;;
        minor)
            ((minor++))
            patch=0
            ;;
        patch)
            ((patch++))
            ;;
    esac

    echo "$major.$minor.$patch"
}

get_version_from_toc() {
    awk -F': ' '/^## Version:/ {print $2}' "$toc_file"
}

update_toc_version() {
    local new_version=$1
    sed -i.bak "s/^## Version:.*/## Version: $new_version/" "$toc_file"
    echo "Updated $toc_file with new version: $new_version"
}

commit_message=$(git log -1 --pretty=%B)

if [[ $commit_message == *"BREAKING CHANGE:"* ]]; then
    version_type="major"
elif [[ $commit_message == *"feat:"* ]]; then
    version_type="minor"
elif [[ $commit_message == *"fix:"* ]] || [[ $commit_message == *"Fix"* ]]; then
    version_type="patch"
else
    echo "No version increment detected in commit message."
    exit 1
fi

if [[ $1 == "alpha" || $1 == "beta" ]]; then
    pre_release=true
    pre_release_type=$1
fi

current_version=$(get_version_from_toc)
if [[ -z "$current_version" ]]; then
    echo "No version found in .toc file."
    exit 1
fi

# Strip any existing pre-release suffix from the current version
current_version=$(echo "$current_version" | sed 's/-.*//')

new_version=$(increment_version "$current_version" "$version_type")

if [[ $pre_release == true ]]; then
    new_version="$new_version-$pre_release_type.$commit_hash"
fi

update_toc_version "$new_version"
