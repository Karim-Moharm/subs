#!/usr/bin/bash


echo -e "\033[33m"   # Set text color to yellow

echo "  _"
echo " /_'    /_  __"
echo "._/ /_//_/_/  "

echo -e "\033[0m"

function error_exit {
    echo "$1" >&2
    exit 1
}

if [ -z "$1" ]; then
	error_exit "[*] Usage $0 target.com"
fi

dir="subs-$(echo $1 | cut -d '.' -f 1)"
mkdir -p "$dir"
cd "$dir"

echo -e "\033[33m starting subfinder \033[0m"
subfinder -d $1 -all > subfind.txt &

echo "\033[33m starting assetfinder \033[0m"
assetfinder $1 -subs-only | tee asset.txt &

echo "\033[33m starting findomain \033[0m"
findomain -t $1 -u findomain.txt &

echo "\033[33m starting github-subdomains \033[0m"
read -p "enter the github token: " gh_token
github-subdomains -d target.com -t $gh_token -o github-subs.txt &

cat subfind.txt asset.txt findomain.txt github-subs.txt > subs.txt

nonfiltered_subs=$(cat subs.txt | wc -l)
echo "\033[33m number of subdomains before filtering: $nonfiltered_subs \033[0m"
cat subs.txt | anew subs.txt 

filtered_subs=$(cat subs.txt | wc -l)
echo "\033[33m number of subdomains after filtering: $filtered_subs \033[0m"

echo "\033[32m getting live subs... \033[0m"

cat subs | httpx | tee httpx.txt &
cat subs | httprobe | tee httprobe.httpx &


wait

echo "live domain using httpx: $(cat httpx.txt | wc -l)" 
echo "live domain using httprobe: $(cat httprobe.txt | wc -l)"
