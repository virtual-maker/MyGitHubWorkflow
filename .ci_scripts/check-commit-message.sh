#!/bin/bash
result=0

commits=$(git log --format=%H)
for commit in $commits; do
  header=$(git log --format=%s -n 1 $commit)
  body=$(git log --format=%b -n 1 $commit)

  if [ -z "$header" ]; then
    echo "Commit message header is empty for commit: $commit"
    exit 1
  fi
  if [ ${#header} -gt 72 ]; then
    echo "Commit message header is too long: $header"
    result=1
  fi
  if [[ ! $header =~ ^[a-z] ]]; then
    echo "Commit message header must start with a lowercase letter: $header"
    result=1
  fi
  if [[ $header =~ \.$ ]]; then
    echo "Commit message header must not end with a dot: $header"
    result=1
  fi

  if [ -n "$body" ]; then
    while IFS= read -r line; do
      if [ ${#line} -gt 72 ]; then
        echo "Commit ${commit:0:7} message body line is too long: $line"
        result=1
      fi
    done <<< "$body"
  fi

if [ $result -ne 0 ]; then
  exit 1
fi
done
