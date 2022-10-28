#!/bin/bash

SECONDS=0

IP=$2
DEPTH=2

function usage(){
	echo -------------------  
		echo "      USAGE "  
		echo -------------------   
		echo -e "[+] 'Script name' [arguments] IP/url\n"
		echo "Arguments:"
		echo " -a   Port scan along with directory scan"
		echo " -p   Only port scan"
		echo " -d   Only directory scan, provided you have done port scan before(It does not take any IP/url)"
		echo -e " -r   Deletes/removes all files created during the scan\n"
		echo "Examples : " 
		echo "./scan.sh -a/-p 10.10.10.10"
		echo "./scan.sh -d"
		exit 1

}

function port_scan(){
		echo --------------------------  
		echo "      Scanning......   "  
		echo --------------------------  
		RESULT=$(rustscan -g $IP | cut -d ">"  -f 2 )
		duration=$SECONDS
		RESULT1=$(echo $RESULT | awk '{print substr($0, 2, length($0) - 2)}' | tr ',' ' ')
		count=$(echo $RESULT1 | wc -w )
		echo "[*] Scanning done in $(($duration / 60)) minutes and $(($duration % 60)) seconds. " 
		if [ $count != 0 ];
		then
			echo "[+] No. of open ports are $count " 
			echo "[+] Open ports are $RESULT " 
			echo "    ------------------ " 
			echo "   < Now running nmap > " 
			echo "    ------------------ " 
				echo "		  \   ^__^   " 
				echo "		   \  (@@)\_"______  
				echo "                      (__)\       )\/\ " 
				echo "        	           ||----w |" 
				echo " 	                   ||     ||" 
			nmap_format=$(echo $RESULT | tr '[]' ' ')

			nmap -T4 -sV -A -sC -Pn -p$nmap_format $IP -oN nmap_scan.txt
			echo ""
			echo "[+] Output written to file named nmap_scan.txt"
		else
			echo "[-] There are no open ports"  
		fi
}

function web_port_search(){
	find_port_directory
	for i in $final_out;
	do
		if [ $i == 80 ];
		then
			var1=$i
		elif [ $i == 8080 ];
		then	
			var2=$i
		elif [ $i == 8000 ];
		then	
			var3=$i
		fi
	done
	
	if [[ -z "$var1" ]] && [[ -z "$var2" ]] && [[ -z "$var3" ]];
	then
		echo " "
		echo "[-] No web port open for directory search"
	fi
}

function file_search(){
	common=$(find . -type f -name "common_dir_search*.txt" 2>/dev/null)
	big=$(find . -type f -name "big_dir_search*.txt" 2>/dev/null)
	if [ -f "$common" ] | [ -f "$big" ];
	then   
		echo -e "[-] Warning file already exists , sleeping for 5 seconds you can either abort else it will overwrite the data on the file\n"
		sleep 5
		dir_search
	else
		dir_search
	fi
}

function find_port_directory(){
	nmap=$(find . -type f -name "nmap_scan.txt" 2>/dev/null)
	if [ -f "$nmap" ];
	then
		out=$(cat nmap_scan.txt  | awk '{print substr($0, 84)}')
		final_out=$(echo $out | grep -o '^\S*' | tr ',' ' ')		
		ip=$(echo $out | cut -d " " -f 4)
		final_ip=$(echo $ip | grep -o '^\S*' )
		
	else
		echo "First perform port scan then only directory search will be done"
		exit 1
	fi
}

function dir_search(){
	echo "" 
	if [ "$var1" == 80 ];
	then
		echo -e "[*] Doing directory search for port 80\n"
		feroxbuster -u http://$final_ip/ -w /usr/share/seclists/Discovery/Web-Content/common.txt -d $DEPTH --quiet --no-state -o common_dir_search_80.txt 1>/dev/null
		feroxbuster -u http://$final_ip/ -w /usr/share/seclists/Discovery/Web-Content/big.txt -d $DEPTH --quiet --no-state -o big_dir_search_80.txt 1>/dev/null
		echo -e "[+] Written the result of directory search to files common_dir_search_80 and big_dir_search_80\n"
	elif [ "$var2" == 8080 ];
	then
		echo -e "[*] Doing directory search for port 8080\n"
		feroxbuster -u http://$final_ip:8080/ -w /usr/share/seclists/Discovery/Web-Content/common.txt -d $DEPTH --quiet --no-state -o common_dir_search_8080.txt 1>/dev/null
		feroxbuster -u http://$final_ip:8080/ -w /usr/share/seclists/Discovery/Web-Content/big.txt -d $DEPTH --quiet --no-state -o big_dir_search_8080.txt 1>/dev/null
		echo -e "[+] Written the result of directory search to files common_dir_search_8080 and big_dir_search_8080\n"
	elif [ "$var3" == 8000 ];
	then
		echo -e "[*] Doing directory search for port 8000\n"
		feroxbuster -u http://$final_ip:8000/ -w /usr/share/seclists/Discovery/Web-Content/common.txt -d $DEPTH --quiet --no-state -o common_dir_search_8000.txt 1>/dev/null 
		feroxbuster -u http://$final_ip:8000/ -w /usr/share/seclists/Discovery/Web-Content/big.txt -d $DEPTH --quiet --no-state -o big_dir_search_8000.txt 1>/dev/null
		echo -e "[+] Written the result of directory search to files common_dir_search_8000 and big_dir_search_8000\n"
	fi
}

function del_files(){

common=$(find . -type f -name "common_dir_search*.txt" 2>/dev/null)
big=$(find . -type f -name "big_dir_search*.txt" 2>/dev/null)
nmap_file=$(find . -type f -name "nmap_scan.txt" 2>/dev/null)

if [ -f "$common" ] | [ -f "$big" ] | [ -f "$nmap_file" ]
then
    rm $common 2>/dev/null
    rm $big 2>/dev/null
    rm $nmap_file 2>/dev/null
	echo "[-] Deleted all files"
else
    echo "[+] No files found to delete"
    exit 1
fi

}

if [ $# -le 2 ];
then
	if [[ $1 == -h ]]
	then
		usage
	elif [[ $1 == -p ]] && [[ $2 =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]] || [[ $2 =~ ^((https?|ftp|smtp):\/\/)?(www.)?[a-z0-9]+\.[a-z]+(\/[a-zA-Z0-9#]+\/?)*$ ]]
	then
		port_scan		
	elif [[ $1 == -d ]]
	then	
		web_port_search
		file_search
	elif [[ $1 == -a ]] && [[ $2 =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]] || [[ $2 =~ ^((https?|ftp|smtp):\/\/)?(www.)?[a-z0-9]+\.[a-z]+(\/[a-zA-Z0-9#]+\/?)*$ ]]
	then
		port_scan
		web_port_search
		file_search
	elif [[ $1 == -r ]]
	then
		del_files	
	else
		echo "[-] IP Address and URL needs to be specified after the arguments"  
		echo "[-] You can check help section for further info." 
		exit 1
	fi
else
	echo "[-] Wrong usage"  
	echo "[-] Check help section for proper usage" 
	exit 1
fi