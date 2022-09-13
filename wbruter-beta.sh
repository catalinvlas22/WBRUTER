#!/bin/bash

# - iNFO -----------------------------------------------------------------------------
#
#        Author: wuseman <wuseman@nr1.nu>
#      FileName: wbruter.sh
#       Version: v4.0
#
#       Created: 2018-16 (23:53:08)
#      Modified: 2022-09-13 (14:08:51)
#
#           iRC: wuseman (Libera/EFnet/LinkNet)
#       Website: https://www.nr1.nu/
#        GitHub: https://github.com/wuseman/
#
# - LiCENSE -------------------------------------------------------------------------
#
#      Copyright (C) 2022, wuseman
#
#      This program is free software; you can redistribute it and/or modify
#      it under the terms of the GNU General Public License as published by
#      the Free Software Foundation; either version 3 of the License, or
#      (at your option) any later version.
#
#      This program is distributed in the hope that it will be useful,
#      but WITHOUT ANY WARRANTY; without even the implied warranty of
#      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#      GNU General Public License for more details.
#
#      You must obey the GNU General Public License. If you will modify
#      the file(s), you may extend this exception to your version
#      of the file(s), but you are not obligated to do so.  If you do not
#      wish to do so, delete this exception statement from your version.
#      If you delete this exception statement from all source files in the
#      program, then also delete it here.
#
#      You should have received a copy of the GNU General Public License
#      along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# - End of Header -------------------------------------------------------------
VERSION=4.0

function wbruter_Author() {
cat << "EOF"

 Copyright (C) 2022, wuseman

 This script was was created 2022 and was released as open source
 on https://github.com/wuseman under:GNU LESSER GENERAL PUBLIC LICENSE GPLv3

   - Author: wuseman <wuseman@nr1.nu>
   - IRC   : wuseman <irc.freenode.com>

 Please report bugs/issues on:

   - https://github.com/wuseman/

EOF
}

function colors() {
		black=$(tput setaf 0)
		red=$(tput setaf 1)
		green=$(tput setaf 2)
		yellow=$(tput setaf 3)
		blue=$(tput setaf 4)
		magenta=$(tput setaf 5)
		cyan=$(tput setaf 6)
		white=$(tput setaf 7)
		bold=$(tput bold)
		reverse=$(tput rev)
		reset="$(tput sgr0)"
}

function okMSG() {
		colors
		printf "%s\n" "[${green}*${reset}] $*"
}

function errMSG() {
		colors
		printf "%s\n" "[${red}*${reset}] $basename$0 -- internal error:  $*"
}

function noticeMSG() {
		colors
		printf "%s" "[${yellow}*${reset}] $*"
}

function infoMSG() {
		colors
		printf "%s\n" "[${yellow}*${reset}] $*"
}

function headerMSG() {
		okMSG "Bruteforce attack will be started within 2 seconds.."
		okMSG "Please use (CTRL+C) to abort the attack at anytime.."
		printf "%56s\n" | tr ' ' '-'
}

function wbruter_checkDebug() {
		case $(adb devices | awk '{print $2}' | sed 1d | sed '$d') in
				"unauthorized") echo "* You must enable usb-debugging in developer settings." ;;
		esac
}

function wbruter_checkStatus() {
		ADBW=$(adb devices | sed -n '2p' \
				|awk '{print $2}' \
				|sed 's/device/normal/g')

		ADBF="$(fastboot devices|grep fastboot|awk '{print $2}')"

		ADBOFF="$(adb devices|sed -n 2p)"

		if [[ $ADBW = "normal" ]]; then
				okMSG "normal" > $(pwd)/.wbruter-status
		elif [[ $ADBW = "unauthorized" ]]; then
				okMSG "please allow this pc to authorize" \
						> $(pwd)/.wbruter-status
								elif [[ $ADBW = "recovery" ]]; then
										okMSG "recovery" > $(pwd)/.wbruter-status
								elif [[ $ADBF = "fastboot" ]]; then
										okMSG "fastboot" > $(pwd)/.wbruter-status
								else
										echo "* No device connected.."
										exit
		fi

		adb devices |sed -n 2p|grep una &> /dev/null
		if [[ $? -eq "0" ]]; then
				echo "* Your device has not been authorized with this pc, aborted."
				exit
		fi
}

function wbruter_Requirements() {
		adb="$(which adb 2> /dev/null)"
		distro="$(cat /etc/os-release | head -n 1 | cut -d'=' -f2 | sed 's/"//g')"

		if [ -z "$adb" ]; then
				printf "+ You must install \e[1;1madb\e[0m package before you can attack by this method.\n"
				read -p "Install adb (Y/n) " adbinstall
		fi

		case $adbinstall in
				"Y")
						echo -e "\nPlease wait..\n"
						sleep 1
						case $distro in
								"Gentoo")
										echo -e "It seems you running \e[1;32m$distro\e[0m wich is supported, installing adb....\n"
										emerge --ask android-tools ;;
								"Sabayon")
										echo -e "It seems you running \e[1;32m$distro\e[0m wich is supported, installing adb....\n"
										emerge --ask android-tools ;;
								"Ubuntu")
										echo -e "It seems you running \e[1;32m$distro\e[0m wich is supported, installing adb....\n"
										apt update -y; apt upgrade -y; apt-get install adb ;;
								"Debian")
										echo -e "It seems you running \e[1;32m$distro\e[0m wich is supported, installing adb....\n"
										apt update -y; apt upgrade -y; apt-get install adb ;;
								"Raspbian")
										echo -e "It seems you running \e[1;32m$distro\e[0m wich is supported, installing adb....\n"
										apt update -y; apt upgrade -y; apt-get install adb ;;
								"Mint")
										echo -e "It seems you running \e[1;32m$distro\e[0m wich is supported, installing adb....\n"
										apt update -y; apt upgrade -y; apt-get install adb ;;
								"no") echo "Aborted." ;
										exit 0 ;;
						esac
						echo -e "This tool is not supported for $distro, please go compile it from source instead...\n"
		esac
}

function wbruter_multiDevices() {
		ADBTOT="$(adb devices | sed 1d|head -2|grep device|wc -l)"

		if [[ $ADBTOT -gt "1" ]]; then
				echo "You have more then one device connected, please choose one of:"
				#    echo $(adb devices| awk '{print NR-1 " - " $0}'|sed "1d;$d"|awk '{print $1 ")", $3}'|sed '$d';)
				exit 1
		fi
}


function wbruter_clearSscreen() {
		adb shell input keyevent KEYCODE_MOVE_END
		adb shell input keyevent --longpress $(printf 'KEYCODE_DEL %.0s' {1..250});
}

