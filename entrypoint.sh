#!/bin/bash
set -e

contains_russian() {
    echo "$1" | grep -q '[а-яА-Я]'
}

git config --global credential.helper "store --file=.git/credentials"
echo "https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com" > .git/credentials
git config --global --add safe.directory /github/workspace

pr_number="${GITHUB_REF##*/}"
git fetch origin
git fetch origin pull/"$pr_number"/merge:refs/remotes/origin/pr"$pr_number"
changed_files=$(git diff --name-only refs/remotes/origin/pr"$pr_number" "$GITHUB_SHA")

# changed_files=$(git diff --name-only FETCH_HEAD "$GITHUB_SHA")
localization_needed=false
for filename in $changed_files; do
    if [[ "$filename" == *.blade.php ]]; then
        while IFS= read -r line; do
            if contains_russian "$line"; then
                echo "File \"$filename\": Line \"$line\" - need locale."
				localization_needed=true
            fi
        done < "$filename"
    fi
done

if $localization_needed; then
    echo "Find files for localization."
    exit 1
fi
