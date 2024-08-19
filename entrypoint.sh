#!/bin/bash
set -e

contains_russian() {
    echo "$1" | grep -q '[а-яА-Я]'
}

changed_files=$(git diff --name-only "$GITHUB_REF" "$GITHUB_SHA")

for filename in $changed_files; do
    if [[ "$filename" == *.blade.php ]]; then
        while IFS= read -r line; do
            if contains_russian "$line"; then
                echo "File \"$filename\": Line \"$line\" - need locale."
            fi
        done < "$filename"
    fi
done
