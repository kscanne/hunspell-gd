#!/bin/bash
echo "GOC-correct words reported as misspellings by GOC checker..."
cat good-GOC.txt | hunspell -d ./gd_GB -l
cat propernouns.txt semigaelic.txt | egrep -v '[./]' | hunspell -d ./gd_GB -l
echo "non-GOC words reported as correct by GOC checker..."
cat good-non-GOC.txt | hunspell -G -d ./gd_GB
echo "Incorrect words reported as correct by GOC checker..."
cat bad-universal.txt | hunspell -G -d ./gd_GB
echo "GOC-correct words reported as misspellings by universal checker..."
cat good-GOC.txt | hunspell -d ./gd_GB_2 -l
cat propernouns.txt semigaelic.txt | egrep -v '[./]' | hunspell -d ./gd_GB_2 -l
echo "non-GOC words reported as misspellings by universal checker..."
cat good-non-GOC.txt | hunspell -l -d ./gd_GB_2
echo "Incorrect words reported as correct by universal checker..."
cat bad-universal.txt | hunspell -G -d ./gd_GB_2
