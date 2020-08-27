#!/bin/bash

# MIT License
# 
# Copyright (c) 2020 jasongitaccount
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# For more information visit https://github.com/jasongitaccount/ezconfig.sh
#
# Usage example: ./thisscript.sh /var/file.conf set configkey1 = ON
# The resulf of the example above would be setting "configkey1 = ON" in the file /var/file.conf

version=0.1.4

firstargument=$1 # e.g. /var/file.conf
operation=$2 # set|reset|autoset|autoreset
key=$3 # e.g. configkey1
connector=$4 # e.g. =
value=$5 # e.g. ON


if [[ "${operation}" =~ ^('set'|'reset'|'autoset'|'autoreset')$ ]]; then
	
	filepath="${firstargument}"
	
	# Escape "/" in value
	value=$(echo "${value}" | sed 's/\//\\\//')
	
	# Too few arguments or not separated (e.g. key=value).
	if [ ! $connector ]; then
		echo 'Error: too few arguments are provided! This may be because the key and value are not spaced out.'
		echo 'Examples:'
		echo 'Incorrect -> key=value'
		echo 'Correct -> key = value'
		echo 'For more information visit https://github.com/jasongitaccount/ezconfig.sh'
		exit
	fi

	# Fix for the unexplicit space connector
	if [ ! $value ]; then
		value=$connector
		connector=' '
	fi

	# Colored grep matches for output
	matches_pretty=$(grep -n --color=always "^[#[:space:]]*${key}[^\.[:alnum:]_-]" "${filepath}")
	# Grep matches without colors for processing
	matches_raw=$(echo "${matches_pretty}" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
	# Number of matching lines
	matches_count=$(echo -n "${matches_raw}" | grep -c '^')
	# Matches that are not commented out
	uncommented_matches=$(echo "${matches_raw}" | grep "^[[:digit:]]*\:[[:space:]]*${key}[^\.[:alnum:]_-]")
	# Number of matches that are not commented out
	uncommented_matches_count=$(echo -n "${uncommented_matches}" | grep -c '^')
	
	# If there is any uncommented matches, try to update one of them instead of appending to the file
	if [[ "${uncommented_matches_count}" -gt 0 ]]; then
		echo '> Matches before the processing:'
		echo "${matches_pretty}"
		
		# If there are multiple matches (at least one of them uncommented), update the last uncommented match
		if [[ "${matches_count}" -gt 1 ]]; then
			# If this is not an automated operation, prompt for confirmation
			if [[ ! "${operation}" =~ ^(autoset|autoreset)$ ]]; then
				read -p "> There are ${matches_count} matches. I can modify only the last uncommented instance. Would you like to continue? (y/n) " -n 1 -r prompt_reply
			else
				prompt_reply='Y'
			fi
			
			echo
			# If user says no, stop the process
			if [[ ! $prompt_reply =~ ^[Yy]$ ]]; then
				exit
			# User said yes
			else
				# Find the file line number of the last uncommented match and update it
				linenum=$( echo "${uncommented_matches}" | tail -1 | cut -d: -f1 )
				sed -i "${linenum}s/^[[:space:]]*\(${key}\)[^\.[:alnum:]_-].*$/\1${connector}${value}/" "${filepath}"

			fi
		# If there is only one match (must be uncommented), update it
		else
			# Find the file line number of the uncommented match and update it
			linenum=$( echo "${uncommented_matches}" | cut -d: -f1 )
			sed -i "s/^[[:space:]]*\(${key}\)[^\.[:alnum:]_-].*$/\1${connector}${value}/" "${filepath}"
		fi
	# If there is no uncommented match present and the operation is "reset"/"autoreset", update the 
	# last commented out line
	elif [[ ( "${matches_count}" -gt 0 ) && (( "${operation}" == 'reset' ) || ( "${operation}" == 'autoreset' )) ]]; then	
		echo '> Matches before the processing:'
		echo "${matches_pretty}"
		
		# If this is not an automated operation, prompt for confirmation
		if [[ ! "${operation}" =~ ^('autoset'|'autoreset')$ ]]; then
			# If there are multiple matches (must be commented out)
			if [[ "${matches_count}" -gt 1 ]]; then
				# Ask user for confirmation
				read -p "> There are ${matches_count} matches. I can uncomment and modify only the last instance. Would you like to continue? (y/n) " -n 1 -r prompt_reply
			# If there is only one matche (must be commented out)
			else
				read -p "> I can uncomment and modify the matched instance. Would you like to continue? (y/n) " -n 1 -r prompt_reply
			fi
		else
			prompt_reply='Y'
		fi
		
		echo
		# If user says no, stop the process
		if [[ ! $prompt_reply =~ ^[Yy]$ ]]; then
			exit
		# User said yes
		else
			# Find the file line number of the last uncommented match and update it
			linenum=$( echo "${matches_raw}" | tail -1 | cut -d: -f1 )
			sed -i "${linenum}s/^[[:space:]]*#[[:space:]]*\(${key}\)[^\.[:alnum:]_-].*$/\1${connector}${value}/" "${filepath}"

		fi
	# The operation is "set"/"autoset", so append to the file
	else
		# If the file doesn't have a new line character at the end, we should add one before appending
		lasttwobytes=$(tail --byte 2 "${filepath}" | xxd -p)
		# Check if there is an LF (\n) character at the end of the file
		if [[ ! "${lasttwobytes}" =~ ('0a')$ ]]; then
			# Check if there is an CRLF (\r\n) character in the file
			if [[ $(grep -Uc $'\015' "${filepath}") -gt 0 ]]; then
				echo -e "\r\n" >> "${filepath}"
			else
				echo -e "\n" >> "${filepath}"
			fi
		fi
		
		echo -e "${key}${connector}${value}" >> "${filepath}"
	fi
	
	echo "> Matches after the processing:"
	grep --color=always -n "^[[:space:]]*${key}[^\.[:alnum:]_-]" "${filepath}"
	
	cp /var/test.conf.bkup /var/test.conf

elif [[ "${firstargument}" =~ ^('-v'|'--version'|'v'|'version')$ ]]; then	
	echo "Version: ${version}"
	exit
else
	echo 'Usage example: ezconfig.sh /var/file.conf set configkey1 = ON'
	echo 'The resulf of the example above would be setting "configkey1 = ON" in the file /var/file.conf'
	echo 'For more information visit https://github.com/jasongitaccount/ezconfig.sh'
	exit
fi

