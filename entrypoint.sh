#!/bin/bash
set -e

contains_russian() {
    echo "$1" | grep -q '[а-яА-Я]'
}

git config --global credential.helper "store --file=.git/credentials"
echo "https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com" > .git/credentials
git config --global --add safe.directory /github/workspace


if [[ "$GITHUB_EVENT_NAME" == "pull_request" ]]; then
    BASE_BRANCH="${GITHUB_BASE_REF}"
else
    BASE_BRANCH="main"
fi

pr_number="${GITHUB_REF##*/}"
git fetch origin

changed_files=$(git diff --name-only "origin/$BASE_BRANCH" "$GITHUB_SHA")

localization_needed=false
for filename in $changed_files; do
    if [[ "$filename" == *.blade.php ]]; then
        while IFS= read -r line; do
            if contains_russian "$line"; then
				line_number=$(echo "$line" | awk '{ print NR }')
                echo "File ${filename}:${line_number} Line \"$line\""
				localization_needed=true
            fi
        done < "$filename"
    fi
done

if $localization_needed; then
    echo "Find files for localization."
    exit 1
fi
