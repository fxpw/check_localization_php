#!/bin/bash
set -e

contains_russian() {
	echo "$1" | grep -i '[а-яА-Я]';
}

git config --global credential.helper "store --file=.git/credentials"
echo "https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com" >.git/credentials
git config --global --add safe.directory /github/workspace

if [[ "$GITHUB_EVENT_NAME" == "pull_request" ]]; then
	BASE_BRANCH="${GITHUB_BASE_REF}"
else
	BASE_BRANCH="test-branch"
fi

git fetch origin

changed_files=$(git diff --name-only "origin/$BASE_BRANCH" "$GITHUB_SHA")

need_throw_error=false
for filename in $changed_files; do
	if [[ -f "$filename" ]]; then
		if [[ "$filename" == *.blade.php ]]; then
			line_number=0
			while IFS= read -r line; do
				line_number=$((line_number + 1))
				if contains_russian "$line"; then
					echo "File ${filename}:${line_number} Line \"$line\""
					need_throw_error=true
				fi
			done <"$filename"
		fi
	fi
done

if $need_throw_error; then
	echo "Find files for localization."
	exit 1
fi
