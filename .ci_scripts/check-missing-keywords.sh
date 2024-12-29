#!/bin/bash
result=0

missing_keywords=$(for keyword in $(grep -A999 '#if DOXYGEN' MyConfig.h | grep -B999 '#endif' | grep '#define' | awk '{ print $2 '} | grep -e '^MY_'); do grep -q $keyword keywords.txt || echo $keyword; done)
if [ -n "$missing_keywords" ]; then
  echo "Keywords that are missing from keywords.txt:" > missing_keywords.txt
  echo "$missing_keywords" >> missing_keywords.txt
  result=1
fi

#missing_keywords_2=$(SOURCE_FILES="core/ drivers/ hal/ examples/ examples_linux/ MyConfig.h MySensors.h"; for keyword in $(grep -whore  'MY_[A-Z][A-Z_0-9]*' $SOURCE_FILES | sort -u ); do grep -q $keyword keywords.txt || echo $keyword; done)
missing_keywords_2=$(SOURCE_FILES="Projects/ MyConfig.h"; for keyword in $(grep -whore  'MY_[A-Z][A-Z_0-9]*' $SOURCE_FILES | sort -u ); do grep -q $keyword keywords.txt || echo $keyword; done)
if [ -n "$missing_keywords_2" ]; then
  echo "Keywords in code that don't exist in keywords.txt:" > missing_keywords_2.txt
  echo "If keywords aren't in keywords.txt, they will not be highlighted in the Arduino IDE. Highlighting makes the code easier to follow and helps spot spelling mistakes." > missing_keywords_2.txt
  echo "$missing_keywords_2" >> missing_keywords_2.txt
  result=1
fi

#missing_keywords_3=$(SOURCE_FILES="core/ drivers/ hal/ examples/ examples_linux/ MyConfig.h MySensors.h"; for keyword in $(grep -whore  'MY_[A-Z][A-Z_0-9]*' $SOURCE_FILES | sort -u ); do grep -q $keyword keywords.txt || echo $keyword; done)
missing_keywords_3=$(SOURCE_FILES="Projects/ MyConfig.h"; for keyword in $(grep -whore  'MY_[A-Z][A-Z_0-9]*' $SOURCE_FILES | sort -u ); do grep -q $keyword keywords.txt || echo $keyword; done)
if [ -n "$missing_keywords_3" ]; then
  echo "Keywords in code that don't have Doxygen comments and aren't blacklisted in keywords.txt:" > missing_keywords_3.txt
  echo "If keywords don't have Doxygen comments, they will not be available at https://www.mysensors.org/apidocs/index.html Add Doxygen comments to make it easier for users to find and understand how to use the new keywords." > missing_keywords_3.txt
  echo "$missing_keywords_3" >> missing_keywords_3.txt
  result=1
fi

tab_spaces_keywords=$(grep -e '[[:space:]]KEYWORD' -e '[[:space:]]LITERAL1' keywords.txt | grep -v -e $'\tLITERAL1' -e $'\tKEYWORD')
if [ -n "$tab_spaces_keywords" ]; then
  echo "Keywords that use space instead of TAB in keywords.txt:" > tab_spaces_keywords.txt
  echo "$tab_spaces_keywords" >> tab_spaces_keywords.txt
  result=1
fi

# Evaluate if there exists booleans in the code tree (not counting this file)
if git grep -q boolean -- `git ls-files | grep -v butler.sh`; then
  echo "You have added at least one occurence of the deprecated boolean data type. Please use bool instead." > booleans.txt
  result=1
fi

echo "Greetings! Here is my evaluation of your pull request:" > error_log.txt
awk 'FNR==1{print ""}1' missing_keywords.txt missing_keywords_2.txt missing_keywords_3.txt tab_spaces_keywords.txt booleans.txt >> error_log.txt
if [ $result -ne 0 ]; then
	echo "" >> error_log.txt
	echo "I am afraid there are some issues with your commit messages and/or use of keywords." >> error_log.txt
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
