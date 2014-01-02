#!/bin/bash
function copyright_notice
{
    echo 'alternatives – Simple tool for administrating /etc/alternatives'
    echo
    echo 'Copyright © 2014  Mattias Andrée (maandree@member.fsf.org)'
    echo
    echo 'This program is free software: you can redistribute it and/or modify'
    echo 'it under the terms of the GNU General Public License as published by'
    echo 'the Free Software Foundation, either version 3 of the License, or'
    echo '(at your option) any later version.'
    echo 
    echo 'This program is distributed in the hope that it will be useful,'
    echo 'but WITHOUT ANY WARRANTY; without even the implied warranty of'
    echo 'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the'
    echo 'GNU General Public License for more details.'
    echo 
    echo 'You should have received a copy of the GNU General Public License'
    echo 'along with this program.  If not, see <http://www.gnu.org/licenses/>.'
}


VERSION=1


ev=5
ALTERNATIVES="/etc/alternatives"
PROVIDERS="/etc/alternatives.providers"
REL_PROVIDERS="../alternatives.providers"


if [ ${#} = 1 ]; then
    if [[ "${1}" = @("help"|"--help"|"-help"|"-h") ]]; then
	ev=0
    elif [[ "${1}" = @("version"|"--version"|"-version"|"-v") ]]; then
	echo "alternatives ${VERSION}"
	exit 0
    elif [[ "${1}" = @("copying"|"--copying"|"-copying"|"-c") ]]; then
	echo ; echo
	copyright_notice
	echo ; echo
	exit 0
    elif [ "${1}" = "list" ]; then
	ls -1 "${ALTERNATIVES}" || exit 1
	exit 0
    fi
elif [ ${#} = 2 ]; then
    if [ "${1}" = "list" ]; then
	if [ -d "${PROVIDERS}/${2}" ]; then
	    ev=0
	    ls -1 "${PROVIDERS}/${2}" |
	    while read -r provider; do
		if [ -f "${PROVIDERS}/${2}/${provider}" ]; then
		    echo "${provider} -> $(realpath "${PROVIDERS}/${2}/${provider}")"
		elif [ -L "${PROVIDERS}/${2}/${provider}" ]; then
		    echo "${0}: The symlink ${PROVIDERS}/${2}/${provider} is broken" >&2
		    ev=2
		else
		    echo "${0}: ${PROVIDERS}/${2}/${provider} is not a symlink" >&2
		    if [ $ev = 0 ]; then
			ev=3
		    fi
		fi
	    done
	    exit $ev
	else
	    echo "${0}: ${2} does not exist in ${PROVIDERS}" >&2
	    exit 1
	fi
    elif [ "${1}" = "get" ]; then
	if [ -L "${ALTERNATIVES}/${2}" ]; then
	    if [ -f "${ALTERNATIVES}/${2}" ]; then
		provider="$(readlink "${ALTERNATIVES}/${2}")"
		echo "$(basename "${provider}") -> $(realpath ${provider})"
		exit 0
	    else
		echo "${0}: The symlink ${ALTERNATIVES}/${2} is broken" >&2
		exit 2
	    fi
	elif [ -f "${ALTERNATIVES}/${2}" ]; then
	    echo "${0}: ${ALTERNATIVES}/${2} is not a symlink" >&2
	    exit 3
	else
	    echo "${0}: ${2} does not exist in ${ALTERNATIVES}" >&2
	    exit 1
	fi
    fi
elif [ ${#} = 3 ]; then
    if [ "${1}" = "set" ]; then
	if [ ! -d "${PROVIDERS}/${2}" ]; then
	    echo "${0}: ${2} does not exist in ${PROVIDERS}" >&2
	    exit 1
	elif [ ! -L "${PROVIDERS}/${2}/${3}" ]; then
	    echo "${0}: ${2}/${3} does not exist in ${PROVIDERS}" >&2
	    exit 1
	elif [ ! -f "${PROVIDERS}/${2}/${3}" ]; then
	    echo "${0}: The symlink ${PROVIDERS}/${2}/${3} is broken" >&2
	    exit 2
	elif [ -e "${ALTERNATIVES}/${2}" ] && [ ! -L "${ALTERNATIVES}/${2}" ]; then
	    echo "${0}: ${ALTERNATIVES}/${2} is not a symlink" >&2
	    exit 3
	else
	    ln -sf "${REL_PROVIDERS}/${2}/${3}" "${ALTERNATIVES}/${2}" || exit 4
	    exit 0
	fi
    fi
fi


echo 'USAGE:  alternatives list'
echo '        :: list commands that can be configured'
echo
echo '        alternatives list COMMAND'
echo '        :: list providers for a command'
echo
echo '        alternatives get COMMAND'
echo '        :: get active provider for a command'
echo
echo '        alternatives set COMMAND PROVIDER'
echo '        :: set active provider for a command'
echo
echo 'EXIT VALUES:  0: Successful'
echo '              1: Did not exist'
echo '              2: Broken symlink'
echo '              3: Not a symlink'
echo '              4: Unknown error'
echo '              5: Invalid use'
echo

exit $ev

