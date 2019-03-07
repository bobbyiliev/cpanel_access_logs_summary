#!/bin/bash

##
# Function that lists access logs for every cPanel user separately
# This includes:
# - POST requests
# - GET requests
# - IP logs and their geo location
# First the function loops through all cPanel users and then summarizes their access logs
##

###################
###  Variables  ###
###################
green='\e[32m'
blue='\e[34m'
clear='\e[0m'
orange='\e[33m'
red='\e[31m'
executionTime=`date +%Y-%m-%d:%H:%M:%S`
server=$(hostname)
location=$(pwd)
geoipdomain="https://ckit.tech/ip.php"

#########################
###  Color Functions  ###
#########################

ColorGreen(){
	echo -ne $green$1$clear
}
ColorBlue(){
	echo -ne $blue$1$clear
}
ColorRed(){
	echo -ne $red$1$clear
}
ColorOrange(){
        echo -ne $orange$1$clear
}

function access_logs_per_account() {
	total_cpanel_accounts=$(cat /etc/userdomains | awk -F': ' '{ print $2 }' | sort | uniq  | wc -l)
	echo ""
	echo Total accounts on the server: $(ColorGreen "${total_cpanel_accounts}")
	echo ""
        for cpanel_account in $(ls -lhSr /usr/local/apache/domlogs/ | grep ^d | awk '{ print $9 }'); do 
                echo $(ColorOrange "Current log for $cpanel_account cPanel account:")
                echo ""
		if [[ $(cat /usr/local/apache/domlogs/${cpanel_account}/* 2>/dev/null | grep -v 'ftp.' | grep GET | cut -d\" -f2 | awk '{print $1 " " $2}' | wc -l) -gt 0 ]]; then
	                echo $(ColorGreen "Top 20 GET requests for $cpanel_account: ")
			sleep 1
cat /usr/local/apache/domlogs/${cpanel_account}/* 2>/dev/null | grep -v 'ftp.' | grep GET | cut -d\" -f2 | awk '{print $1 " " $2}' | cut -d? -f1 | sort | uniq -c | sort -n | sed 's/[ ]*//' | tail -20
			sleep 1
			echo ""
			echo $(ColorGreen "Most Recent top 20 GET requests for $cpanel_account: ")
			sleep 1
tail -n 1000 /usr/local/apache/domlogs/${cpanel_account}/* 2>/dev/null | grep -v 'ftp.' | grep GET | cut -d\" -f2 | awk '{print $1 " " $2}' | cut -d? -f1 | sort | uniq -c | sort -n | sed 's/[ ]*//' | tail -20
			sleep 1
                	echo ""
	                echo $(ColorGreen "Top 20 POST requests for $cpanel_account: ")
			sleep 1
cat /usr/local/apache/domlogs/${cpanel_account}/* 2>/dev/null | grep -v 'ftp.' | grep POST | cut -d\" -f2 | awk '{print $1 " " $2}' | cut -d? -f1 | sort | uniq -c | sort -n | sed 's/[ ]*//' | tail -20
			sleep 1
	                echo ""
        		echo $(ColorGreen "Most Recent top 20 POST requests for $cpanel_account: ")
			sleep 1
tail -n 1000 /usr/local/apache/domlogs/${cpanel_account}/* 2>/dev/null | grep -v 'ftp.' | grep POST | cut -d\" -f2 | awk '{print $1 " " $2}' | cut -d? -f1 | sort | uniq -c | sort -n | sed 's/[ ]*//' | tail -20
			sleep 1
			echo ""
		        echo $(ColorGreen "Top 20 IP addresses: ")
			sleep 1
        	        if [[ $enablegeoipcheck == 1 ]] ; then
                	        oIFS="$IFS"
                        	IFS=$'\n'
	                        for ips in $(cat /usr/local/apache/domlogs/${cpanel_account}/* 2>/dev/null | awk  '{print $1}' |sort | uniq -c | sort -rn | head -20); do
        	                           IFS=' '
                	                   array=($ips)
                        	           hits="${array[0]}"
                                	   ip="${array[1]}"
					if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		                                location=$(curl -k ${geoipdomain}?ip=$ip 2>/dev/null)
	        	                        echo $hits - $ip - $location
					fi
                	                unset location
                        	done
	                        IFS="$oIFS"
        	        else
                	        cat /usr/local/apache/domlogs/${cpanel_account}/* 2>/dev/null | awk '{print $1}' |sort | uniq -c | sort -rn | head -20
	                fi
			echo ""
		        echo $(ColorGreen "Most Recent top 20 IP addresses: ")
			if [[ $enablegeoipcheck == 1 ]] ; then
        	                oIFS="$IFS"
	                        IFS=$'\n'
        	                for ips in $(tail -n 1000 /usr/local/apache/domlogs/${cpanel_account}/* 2>/dev/null | awk  '{print $1}' |sort | uniq -c | sort -rn | head -20); do
                	                   IFS=' '
                        	           array=($ips)
                                	   hits="${array[0]}"
	                                   ip="${array[1]}"
					if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        		                        location=$(curl -k ${geoipdomain}?ip=$ip 2>/dev/null)
	                	                echo $hits - $ip - $location
					fi
                        	        unset location
	                        done
        	                IFS="$oIFS"
                	else
	                       	tail -n 1000 /usr/local/apache/domlogs/${cpanel_account}/* 2>/dev/null | awk '{print $1}' |sort | uniq -c | sort -rn | head -20
        	        fi
		else
			echo ""
	                echo $(ColorGreen "No entires for $cpanel_account");
			sleep 1
		fi
                echo $(ColorRed "########## END log for $cpanel_account  ###########");
        done
}

access_logs_per_account
