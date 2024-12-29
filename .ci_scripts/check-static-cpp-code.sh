#!/bin/bash +e
set -x

echo "Doing cppcheck for AVR..."
find . -type f \( -iname \*.c -o -iname \*.cpp -o -iname \*.ino \) | \
cppcheck -j 4 --force --file-list=- \
--enable=style,portability,performance \
--platform=.mystools/cppcheck/config/avr.xml \
--suppressions-list=.mystools/cppcheck/config/suppressions.cfg \
--includes-file=.mystools/cppcheck/config/includes.cfg \
--language=c++ --inline-suppr --xml --xml-version=2 2> cppcheck-avr.xml

cppcheck-htmlreport --file="cppcheck-avr.xml" \
--title="cppcheck-avr" \
--report-dir=cppcheck-avr_cppcheck_reports \
--source-dir=.

grep -q "<td>0</td><td>total</td>" cppcheck-avr_cppcheck_reports/index.html || exit_code=$?
exit $((exit_code == 0 ? 0 : 1))
