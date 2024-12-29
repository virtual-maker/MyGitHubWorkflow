#!/bin/bash
result=0
echo "" > commit_issues.txt

commits=$(git log --format=%H)
for commit in $commits; do
  header=$(git log --format=%s -n 1 $commit)
  body=$(git log --format=%b -n 1 $commit)

  if [ -z "$header" ]; then
    echo "Commit ${commit:0:7} message header is empty." >> commit_issues.txt
    result=1
	continue
  fi
  if [ ${#header} -gt 72 ]; then
    echo "Commit ${commit:0:7} message header is too long (max. 72 chars): $header" >> commit_issues.txt
    result=1
  fi
  if [[ $header =~ ^[a-z] ]]; then
    echo "Commit ${commit:0:7} message header must not start with a lowercase letter: $header" >> commit_issues.txt
    result=1
  fi
  if [[ $header =~ \.$ ]]; then
    echo "Commit ${commit:0:7} message header must not end with a dot: $header" >> commit_issues.txt
    result=1
  fi

  # Check for too long lines in the commit message body
  # ToDo: Do we really need this? 
  if [ -n "$body" ]; then
    while IFS= read -r line; do
      if [ ${#line} -gt 72 ]; then
        echo "Commit ${commit:0:7} message body line is too long (max. 72 chars): $line" >> commit_issues.txt
        result=1
      fi
    done <<< "$body"
  fi

if [ $result -ne 0 ]; then
  exit 1
fi
done

echo "Greetings! Here is my evaluation of your pull request:" > error_log.txt
awk 'FNR==1{print ""}1' commit_issues.txt >> error_log.txt
if [ $result -ne 0 ]; then
	echo "" >> error_log.txt
	echo "I am afraid there are some issues with your commit messages." >> error_log.txt
	echo "I highly recommend reading this guide: http://chris.beams.io/posts/git-commit for tips on how to write a good commit message." >> error_log.txt
	echo "More specifically, MySensors have some code contribution guidelines: https://www.mysensors.org/download/contributing that I am afraid all contributers need to follow." >> error_log.txt
	echo "" >> error_log.txt
	echo "I can help guide you in how to change the commit message for a single-commit pull request:" >> error_log.txt
	echo "git checkout <your_branch>" >> error_log.txt
	echo "git commit --amend" >> error_log.txt
	echo "git push origin HEAD:<your_branch_on_github> -f" >> error_log.txt
	echo "" >> error_log.txt
	echo "To change the commit messages for a multiple-commit pull request:" >> error_log.txt
	echo "git checkout <your_branch>" >> error_log.txt
	echo "git rebase -i <sha_of_parent_to_the_earliest_commit_you_want_to_change>" >> error_log.txt
	echo "Replace \"pick\" with \"r\" or \"reword\" on the commits you need to change message for" >> error_log.txt
	echo "git push origin HEAD:<your_branch_on_github> -f" >> error_log.txt
	echo "" >> error_log.txt
fi

if [ $result -ne 0 ]; then
  cat error_log.txt
  exit 1
fi

