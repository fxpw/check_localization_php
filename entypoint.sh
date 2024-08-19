#!/bin/bash
set -e

contains_russian() {
    echo "$1" | grep -q '[а-яА-Я]'
}

# Получаем список измененных файлов
changed_files=$(git diff --name-only "$GITHUB_REF" "$GITHUB_SHA")

for filename in $changed_files; do
    if [[ "$filename" == *.blade.php ]]; then  # Правильная проверка на окончание файла
        while IFS= read -r line; do
            if contains_russian "$line"; then
                echo "Файл \"$filename\": строка \"$line\" - требует локализации."
            fi
        done < "$filename"
    fi
done
