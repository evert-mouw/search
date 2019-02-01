#!/bin/bash

# Sort a file line by line,
# based on multiple keywords,
# giving a higher rank when
# all keywords are present
# in a line, and otherwise
# ordering in order of keywords.

# It reads the whole file or stream
# into memory so beware...

# Evert Mouw <post@evert.net>
# 2019-01-30 first version
# 2019-01-31 improvements

# if a measurefile is not specified,
# then no time logging will take place
MEASUREFILE="rankedsort.log"

TESTSEARCH="aap noot mies"
TESTTEXT="
Dit is een tekstje met een aap,
voor aap noot mies test,
ook mies en noot,
of helemaal niets.
Want het hoeft niet ;-)
Ook kan noot aap mies,
en mies aap noot.
Of alleen mies.
Of alleen noot.
Maar geen aap!
"

function ranklines() {
	timestart=$(date +%s)
	KEYWORDS=${@}
	while read LINE
	do
		RANK=0
		for KEY in $KEYWORDS
		do
			#if [[ $LINE == *"$KEY"* ]]
			if [[ ${LINE^^} == *"${KEY^^}"* ]] # case insensitive matching (Bash only)
			#if [[ $LINE =~ $KEY ]] # regex alternative, slighty slower, see below...
			##if echo "$LINE" | grep -q $KEY # slow as a wounded snail :-(   (see below)
			then
				((RANK++))
			fi
		done
		echo -e "$RANK\t$LINE"
	done
	timeend=$(date +%s)
	if [[ $MEASUREFILE != "" ]]
	then
		# for testing only
		echo "ranklines() took $((timeend-timestart)) seconds" >> "$MEASUREFILE"
	fi
}

function sortrankedlines() {
	echo "$1" | ranklines "${@:2}" | sort -n -r | cut -f2
}

if [[ "$1" == "" ]]
then
	sortrankedlines "$TESTTEXT" "$TESTSEARCH"
else
	if [[ "${@:2}" == "" ]]
	then
		echo "I need search terms."
		exit
	fi
	if [[ $MEASUREFILE != "" ]]
		then
		echo >> "$MEASUREFILE"
		date >> "$MEASUREFILE"
		echo "Starting ranked sort in file $1" >> "$MEASUREFILE"
		echo "with keywords ${@:2}" >> "$MEASUREFILE"
	fi
	sortrankedlines "$(cat "$1")" "${@:2}"
fi

exit

DOCUMENTATION="

SUBSTRING TESTING IN BASH

To test for a substring in a string using Bash, you can use wildcards or regex:

if [[ $LINE == *"$KEY"* ]]
if [[ $LINE =~ $KEY ]]

On a test corpus generated using locate bin usr > bin-usr.test,
and using ranked search keywords python html,
these were the results:
*"wildcard"*  [ case sentivive ]   took 18 seconds
*"wildcard"*  [ case INsentivive   took 20 seconds
~regex        [ case sentivive ]   took 20 seconds
grep -q -i    [ case INsentivive ] took like forever (cancelled after 9+ minutes)

CASE INSENSITIVE

To make the match case insensitive for Bash, use
for   *"wildcard"*   :   [[ "${haystack^^}" = *"${needle^^}"* ]]
for   ~regex         :   shopt -s nocasematch

Note that case insensitive search makes it slower, but the main reason
for the slow grep performance is probably the extensive external calling
of grep vs internal Bash comparison.

For the regex notation: this has changed since bash-3.2.

This is NOT good:

if [[ $LINE =~ "my apple" ]] # quoted string with spaces :-(

Use this instead:

KEY="my apple"
if [[ $LINE =~ $KEY ]]

Reason given in E14 of Bash FAQ:

Since the treatment of quoted string arguments was changed, several issues
have arisen, chief among them the problem of white space in pattern arguments
and the differing treatment of quoted strings between bash-3.1 and bash-3.2.
Both problems may be solved by using a shell variable to hold the pattern.
Since word splitting is not performed when expanding shell variables in all
operands of the [[ command, this allows users to quote patterns as they wish
when assigning the variable, then expand the values to a single string that
may contain whitespace.  The first problem may be solved by using backslashes
or any other quoting mechanism to escape the white space in the patterns.

References:

- E14 in http://tiswww.case.edu/php/chet/bash/FAQ
- https://stackoverflow.com/questions/229551/how-to-check-if-a-string-contains-a-substring-in-bash
- https://unix.stackexchange.com/questions/132480/case-insensitive-substring-search-in-a-shell-script

"
