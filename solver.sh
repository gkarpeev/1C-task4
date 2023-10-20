#!/bin/bash

dir_first="$1"
dir_second="$2"
percentage_of_similarity="$3"

# check if they are dirs
if [ ! -d "$dir_first" ] || [ ! -d "$dir_second" ]
then
    echo "Ошибка, неверный формат"
    exit 1
fi

echo "Идентичные файлы:"
for file1 in "$dir_first"/*
do
    for file2 in "$dir_second"/*
    do
        if diff -q "$file1" "$file2" >/dev/null
        then
            echo "$file1 - $file2"
        fi
    done
done

echo "Похожие файлы:"
for file1 in "$dir_first"/*
do
    for file2 in "$dir_second"/*
    do
        count_lines_file1=$(wc -l < "$file1")
        count_lines_file2=$(wc -l < "$file2")
        count_lines_file1=$((count_lines_file1 + 1))
        count_lines_file1=$((count_lines_file2 + 1))
        if [ "$count_lines_file1" -gt "$count_lines_file2" ]
        then
            max_count_lines="$count_lines_file1"
        else
            max_count_lines="$count_lines_file2"
        fi

        similar_lines=$(diff -y --suppress-common-lines "$file1" "$file2" | grep -c "|")
        similarity=$(bc <<< "scale=2; ($similar_lines / $max_count_lines) * 100")
        result=$(echo "$similarity >= $percentage_of_similarity" | bc)
        if [ "$result" -eq 1 ]
        then
            echo "$file1 - $file2 - $similarity"
        fi
    done
done

compare_dirs() {
    dir_first="$1"
    dir_second="$2"
    for file1 in "$dir_first"/*
    do
        is_missing=1
        for file2 in "$dir_second"/*
        do
            if diff -q "$file1" "$file2" >/dev/null
            then
                is_missing=0
                break
            fi
        done
        if [ $is_missing -eq 1 ]
        then
            echo "$file1"
        fi
    done
}

echo "Файлы присутствующие в Dir1, но отсутствующие в Dir2:"

compare_dirs $dir_first $dir_second

echo "Файлы присутствующие в Dir2, но отсутствующие в Dir1:"

compare_dirs $dir_second $dir_first
