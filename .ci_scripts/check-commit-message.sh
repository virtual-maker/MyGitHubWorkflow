#!/bin/bash

commits=$(git log --format=%H)
for commit in $commits; do
  header=$(git log --format=%s -n 1 $commit)
  body=$(git log --format=%b -n 1 $commit)
  if [ ${#header} -gt 72 ]; then
    echo "Commit message header is too long: $header"
    exit 1
  fi
  if [ -n "$body" ] && [[ "$body" != $'\n'* ]]; then
    echo "Commit message body must start with an empty line: $header"
    exit 1
  fi
done
