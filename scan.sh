#!/bin/bash

SECONDS=0

IP=$1
DEPTH=2

function usage(){
	echo -------------------  
		echo "      USAGE "  
		echo -------------------   
		echo "[+] 'Script name' options/IP"
		echo "Options:"
		echo " -d   Delete created files"
		echo "Examples : " 
		echo "./scan.sh -d"
		echo "./scan.sh 10.0.0.0"
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
				echo " 	                  ||     ||" 
			nmap_format=$(echo $RESULT | tr '[]' ' ')

			nmap -T4 -sV -A -sC -Pn -p$nmap_format $IP	-oN nmap_scan.txt 
			echo ""
			echo "[+] Output also written to file named nmap_scan.txt"
		else
			echo "[-] There are no open ports"  
		fi
}

function web_port_search(){
	for i in $RESULT1;
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
}

function file_search(){
	common=$(find . -type f -name "common_dir_search*.txt" 2>/dev/null)
	big=$(find . -type f -name "big_dir_search*.txt" 2>/dev/null)
	if [ -f "$file" ] | [ -f "$file2" ];
	then   
		echo -e "[-] Warning file already exists , sleeping for 5 seconds you can either abort else it will overwrite the data on the file\n"
		sleep 5
		dir_search
	else
		dir_search
	fi
}

function dir_search(){
	echo "" 
	if [ $var1 == "80" ];
	then
		echo -e "[*] Doing directory search for port 80\n"
		feroxbuster -u http://$IP/ -w /usr/share/seclists/Discovery/Web-Content/common.txt -d $DEPTH --quiet --no-state -o common_dir_search_80.txt 1>/dev/null
		feroxbuster -u http://$IP/ -w /usr/share/seclists/Discovery/Web-Content/big.txt -d $DEPTH --quiet --no-state -o big_dir_search_80.txt 1>/dev/null
		echo -e "[+] Written the result of directory search to files common_dir_search_80 and big_dir_search_80\n"
	elif [ $var2 == "8080" ];
	then
		echo -e "[*] Doing directory search for port 8080\n"
		feroxbuster -u http://$IP:8080/ -w /usr/share/seclists/Discovery/Web-Content/common.txt -$DEPTH --quiet --no-state -o common_dir_search_8080.txt 1>/dev/null
		feroxbuster -u http://$IP:8080/ -w /usr/share/seclists/Discovery/Web-Content/big.txt -d $DEPTH --quiet --no-state -o big_dir_search_8080.txt 1>/dev/null
		echo -e "[+] Written the result of directory search to files common_dir_search_8080 and big_dir_search_8080\n"
	elif [ $var3 == "8000" ];
	then
		echo -e "[*] Doing directory search for port 8000\n"
		feroxbuster -u http://$IP:8000/ -w /usr/share/seclists/Discovery/Web-Content/common.txt -$DEPTH --quiet --no-state -o common_dir_search_8000.txt 1>/dev/null 
		feroxbuster -u http://$IP:8000/ -w /usr/share/seclists/Discovery/Web-Content/big.txt -d $DEPTH --quiet --no-state -o big_dir_search_8000.txt 1>/dev/null
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

if [ $# -eq 1 ];
then
	if [ $1 == -h ]
	then
		usage
elif [[ $1 =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]] | [[ $1 =~ ^((https?|ftp|smtp):\/\/)?(www.)?[a-z0-9]+\.[a-z]+(\/[a-zA-Z0-9#]+\/?)*$ ]]
	then
		port_scan
		web_port_search
		file_search
	elif [ $1 == -d ]
	then 	
		del_files
	else
		echo "[-] IP Address and URL's are only accepted."  
		exit 1
	fi
else
	echo "[-] You can only specify one IP/option after the script."  
	echo "[-] You can check help section for further info." 
	exit 1
fi

