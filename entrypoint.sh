#!/bin/bash
set -e

contains_russian() {
    echo "$1" | grep -q '[а-яА-Я]'
}

echo "GITHUB_REF: $GITHUB_REF"
echo "GITHUB_SHA: $GITHUB_SHA"

changed_files=$(git diff --name-only origin/test-branch...HEAD)

for filename in $changed_files; do
    if [[ "$filename" == *.blade.php ]]; then
        while IFS= read -r line; do
            if contains_russian "$line"; then
                echo "File \"$filename\": Line \"$line\" - need locale."
            fi
        done < "$filename"
    fi
done
