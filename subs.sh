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

function print_colored {
    echo -e "\n\033[33m-----------$1-----------\033[0m"
}


if [ -z "$1" ]; then
	error_exit "[*] Usage $0 target.com"
fi

dir="subs-$(echo $1 | cut -d '.' -f 1)"
mkdir -p "$dir"
cd "$dir"

print_colored "starting subfinder"
subfinder -d $1 -all > subfind.txt &

print_colored "starting assetfinder"
assetfinder $1 -subs-only | tee asset.txt &

wait

print_colored "starting findomain"
findomain -t $1 -u findomain.txt &

print_colored "starting github-subdomains"
github-subdomains -d $1 -t $GHToken -o github-subs.txt &

wait

cat subfind.txt asset.txt findomain.txt github-subs.txt > subs.txt

nonfiltered_subs=$(cat subs.txt | wc -l)
print_colored "number of subdomains before filtering: $nonfiltered_subs"

cat subs.txt | anew subs.txt 

filtered_subs=$(cat subs.txt | wc -l)
print_colored "number of subdomains after filtering: $filtered_subs"

echo -e "\033[32m\n\n---------------------------getting live subs---------------------------\033[0m"

cat subs.txt | httpx -o httpx.txt 
cat subs.txt | httprobe > httprobe.txt


echo "live domain using httpx: $(cat httpx.txt | wc -l)" 
echo "live domain using httprobe: $(cat httprobe.txt | wc -l)"
