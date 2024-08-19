#!/bin/bash
set -e

contains_russian() {
    echo "$1" | grep -q '[а-яА-Я]'
}

echo "GITHUB_REF: $GITHUB_REF"
echo "GITHUB_SHA: $GITHUB_SHA"
echo "GITHUB_ACTOR: $GITHUB_ACTOR"
echo "GITHUB_TOKEN: $GITHUB_TOKEN"

git config --global credential.helper "store --file=.git/credentials"
echo "https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com" > .git/credentials
git config --global --add safe.directory /github/workspace
git fetch origin pull/"${GITHUB_REF##*/}"/merge

changed_files=$(git diff --name-only FETCH_HEAD "$GITHUB_SHA")

for filename in $changed_files; do
    if [[ "$filename" == *.blade.php ]]; then
        while IFS= read -r line; do
            if contains_russian "$line"; then
                echo "File \"$filename\": Line \"$line\" - need locale."
            fi
        done < "$filename"
    fi
done
