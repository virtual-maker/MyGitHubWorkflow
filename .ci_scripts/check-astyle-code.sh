#!/bin/bash
result=0

# Create empty file to store the astyle issue
: > error_log.txt

# Evaluate coding style
astyle --options=.mystools/astyle/config/style.cfg -nq --recursive "*.h" "*.c" "*.cpp"
####git diff > restyling.patch
git diff -- . ':!.ci_scripts' > restyling.patch
if [ -s restyling.patch ]; then
	echo "I am afraid your coding style is not entirely in line with the MySensors prefered style." >> error_log.txt
	echo "The restyling.patch file, if applied to your PR, will make it follow the MySensors coding standards." >> error_log.txt
	echo "You can apply the patch using:" >> error_log.txt
	echo "git apply restyling.patch" >> error_log.txt
	echo "" >> error_log.txt
	result=1
else
	echo "This commit is meeting the coding standards, well done!" >> error_log.txt
	rm restyling.patch
fi

if [ $result -ne 0 ]; then
	echo "If you have any questions, please first read the code contribution guidelines:" >> error_log.txt
	echo "https://www.mysensors.org/download/contributing" >> error_log.txt
	echo "If you disagree to this, please discuss it in the GitHub pull request thread." >> error_log.txt
fi
echo "Thank you for contributing to the MySensors community." >> error_log.txt
cat error_log.txt
exit $result
