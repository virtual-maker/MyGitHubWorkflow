#!/bin/bash
result=0

missing_keywords=$(for keyword in $(grep -A999 '#if DOXYGEN' MyConfig.h | grep -B999 '#endif' | grep '#define' | awk '{ print $2 '} | grep -e '^MY_'); do grep -q $keyword keywords.txt || echo $keyword; done)
if [ -n "$missing_keywords" ]; then
  echo "<b>Keywords that are missing from keywords.txt:</b>" > missing_keywords.txt
  echo "$missing_keywords" >> missing_keywords.txt
  sed -i -e 's/$/<br>/' missing_keywords.txt
  result=1
fi

#missing_keywords_2=$(SOURCE_FILES="core/ drivers/ hal/ examples/ examples_linux/ MyConfig.h MySensors.h"; for keyword in $(grep -whore  'MY_[A-Z][A-Z_0-9]*' $SOURCE_FILES | sort -u ); do grep -q $keyword keywords.txt || echo $keyword; done)
missing_keywords_2=$(SOURCE_FILES="Projects/ MyConfig.h"; for keyword in $(grep -whore  'MY_[A-Z][A-Z_0-9]*' $SOURCE_FILES | sort -u ); do grep -q $keyword keywords.txt || echo $keyword; done)
if [ -n "$missing_keywords_2" ]; then
  echo "<b>Keywords in code that don't exist in keywords.txt:</b>" > missing_keywords_2.txt
  echo "If keywords aren't in keywords.txt, they will not be highlighted in the Arduino IDE. Highlighting makes the code easier to follow and helps spot spelling mistakes." > missing_keywords_2.txt
  echo "$missing_keywords_2" >> missing_keywords_2.txt
  sed -i -e 's/$/<br>/' missing_keywords_2.txt
  result=1
fi

#missing_keywords_3=$(SOURCE_FILES="core/ drivers/ hal/ examples/ examples_linux/ MyConfig.h MySensors.h"; for keyword in $(grep -whore  'MY_[A-Z][A-Z_0-9]*' $SOURCE_FILES | sort -u ); do grep -q $keyword keywords.txt || echo $keyword; done)
missing_keywords_3=$(SOURCE_FILES="Projects/ MyConfig.h"; for keyword in $(grep -whore  'MY_[A-Z][A-Z_0-9]*' $SOURCE_FILES | sort -u ); do grep -q $keyword keywords.txt || echo $keyword; done)
if [ -n "$missing_keywords_3" ]; then
  echo "<b>Keywords in code that don't have Doxygen comments and aren't blacklisted in keywords.txt:</b>" > missing_keywords_3.txt
  echo "If keywords don't have Doxygen comments, they will not be available at https://www.mysensors.org/apidocs/index.html Add Doxygen comments to make it easier for users to find and understand how to use the new keywords." > missing_keywords_3.txt
  echo "$missing_keywords_3" >> missing_keywords_3.txt
  sed -i -e 's/$/<br>/' missing_keywords_3.txt
  result=1
fi

tab_spaces_keywords=$(grep -e '[[:space:]]KEYWORD' -e '[[:space:]]LITERAL1' keywords.txt | grep -v -e $'\tLITERAL1' -e $'\tKEYWORD')
if [ -n "$tab_spaces_keywords" ]; then
  echo "<b>Keywords that use space instead of TAB in keywords.txt:</b>" > tab_spaces_keywords.txt
  echo "$tab_spaces_keywords" >> tab_spaces_keywords.txt
  sed -i -e 's/$/<br>/' tab_spaces_keywords.txt
  result=1
fi

# Evaluate if there exists booleans in the code tree (not counting this file)
if git grep -q boolean -- `git ls-files | grep -v butler.sh`; then
  echo "<b>You have added at least one occurence of the deprecated boolean data type. Please use bool instead.</b><br>" > booleans.txt
  result=1
fi

echo "Greetings! Here is my evaluation of your pull request:<br>" > butler.html
awk 'FNR==1{print "<br>"}1' missing_keywords.txt missing_keywords_2.txt missing_keywords_3.txt tab_spaces_keywords.txt booleans.txt >> butler.html
echo "<br>" >> butler.html
if [ $result -ne 0 ]; then
	echo "<b>I am afraid there are some issues with your commit messages and/or use of keywords.</b><br>" >> butler.html
	echo "I highly recommend reading <a href="http://chris.beams.io/posts/git-commit">this guide</a> for tips on how to write a good commit message.<br>" >> butler.html
	echo "More specifically, MySensors have some <a href="https://www.mysensors.org/download/contributing">code contribution guidelines</a> that I am afraid all contributers need to follow.<br>" >> butler.html
	echo "<br>" >> butler.html
	echo "I can help guide you in how to change the commit message for a single-commit pull request:<br>" >> butler.html
	echo "git checkout &lt;your_branch&gt;<br>" >> butler.html
	echo "git commit --amend<br>" >> butler.html
	echo "git push origin HEAD:&lt;your_branch_on_github&gt; -f<br>" >> butler.html
	echo "<br>" >> butler.html
	echo "To change the commit messages for a multiple-commit pull request:<br>" >> butler.html
	echo "git checkout &lt;your_branch&gt;<br>" >> butler.html
	echo "git rebase -i &lt;sha_of_parent_to_the_earliest_commit_you_want_to_change&gt;<br>" >> butler.html
	echo "Replace \"pick\" with \"r\" or \"reword\" on the commits you need to change message for<br>" >> butler.html
	echo "git push origin HEAD:&lt;your_branch_on_github&gt; -f<br>" >> butler.html
	echo "<br>" >> butler.html
fi
