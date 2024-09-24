#!/bin/bash

show_help() {
    echo "Usage: ./ASN_greper.sh [OPTIONS] domain_name"
    echo
    echo "Fetch ASNs and subnets for a given organization name."
    echo
    echo "Options:"
    echo "  -h, --help          Show this help message and exit"
    echo "  -o, --output FILE   Specify the output file"
    echo "  -org, --organization NAME  Specify the domain name (organization)"
    echo
    echo "Example:"
    echo "  ./ASN_greper.sh -o ~/path/for/output_file -org \"Test org\""
}

output_file=""
domain=""

while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
  -h | --help )
    show_help
    exit 0
    ;;
  -o | --output )
    shift; output_file=$1
    ;;
  -org | --organization )
    shift; domain=$1
    ;;
esac; shift; done
if [[ "$1" == '--' ]]; then shift; fi

if [ -z "$domain" ]; then
    echo "Error: No domain provided."
    show_help
    exit 1
fi

urlencode() {
    local length="${#1}"
    printf '"'
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            ' ') printf '+' ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done
    printf '"'
}

function ver_idf() {
    local_version=v0.1.1

    latest_version=$(curl -s https://api.github.com/repos/Insider-HackZ/AsN_GrApEr/releases/latest | grep '"tag_name":' | cut -d '"' -f 4)

    if [ "$local_version" != "$latest_version" ]; then
        echo "Your version ($local_version) is outdated. The latest version is $latest_version."
        read -p "Do you want to update to the latest version? (y/n): " choice
        if [ "$choice" == "y" ]; then
            echo "Updating to version $latest_version..."
            wget -O "$0" https://raw.githubusercontent.com/Insider-HackZ/AsN_GrApEr/main/AsN_GrApEr.sh
            echo "Update completed || Current Version ($latest_version)."
            echo "Run the tool again...."
            local_version=$latest_version
            exit 0
        else
            echo "Update canceled."
        fi
    else
        echo "You are using the latest version ($local_version)."
        local_version=$latest_version
    fi
}

encoded_domain=$(urlencode "$domain")

function banner() {
    printf "\n${bgreen}"
    printf "    _        _   _     ____       _          _____\n"
    printf "   / \   ___| \ | |   / ___|_ __ / \   _ __ | ____|_ __\n"
    printf "  / _ \ / __|  \| |  | |  _| '__/ _ \ | '_ \|  _| | '__|\n"
    printf " / ___ \ __ \ |\  |  | |_| | | / ___ \| |_) | |___| |\n"
    printf "/_/   \_\___/_| \_|___\____|_|/_/   \_\ .__/|_____|_|\n"
    printf "                 |_____|              |_| developed by:harshj054\n"
    printf "\n                                        \n"
}
banner

ver_idf
mkdir -p ext
curl -o "ext/$encoded_domain-ans_page.txt" -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" "https://bgp.he.net/search?search%5Bsearch%5D=$encoded_domain&commit=Search"
grep -o 'AS[0-9]\+' "ext/$encoded_domain-ans_page.txt" > "ext/$encoded_domain-asn_numbers.txt"
sort -u "ext/$encoded_domain-asn_numbers.txt" > "ext/$encoded_domain-sorted_ans.txt"

while read -r asn; do
    curl -s -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" "https://bgp.he.net/$asn" -o "ext/$encoded_domain-$asn-page.txt"
    grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]+' "ext/$encoded_domain-$asn-page.txt" > "ext/$encoded_domain-$asn-subnets.txt"
    rm "ext/$encoded_domain-$asn-page.txt"
done < "ext/$encoded_domain-sorted_ans.txt"

rm ext/*-ans_page.txt
rm ext/*-asn_numbers.txt
rm ext/*-sorted_ans.txt

awk 'FNR==1 {if (NR!=1) print ""} {print}' ext/* > ext/subnet.txt
sort -u ext/subnet.txt > "ext/$domain.txt"

ip_gen() {
    touch "ext/$domain-ips.txt"

    while read -r subnet; do
        if [[ "$subnet" != "0.0.0.0/0" && -n "$subnet" ]]; then
            if prips "$subnet" &>/dev/null; then
                prips "$subnet" >> "ext/$domain-ips.txt"
            else
                echo "Invalid subnet: $subnet"
            fi
        fi
    done < "ext/$domain.txt"
}


ip_gen

if [ -n "$output_file" ]; then
    mkdir -p "$output_file/AsN_GrApEr-output"
    mv "ext/$domain.txt" "$output_file/AsN_GrApEr-output/"
    mv "ext/$domain-ips.txt" "$output_file/AsN_GrApEr-output/"
else
    mkdir -p AsN_GrApEr-output
    mv "ext/$domain.txt" "AsN_GrApEr-output/"
    mv "ext/$domain-ips.txt" "AsN_GrApEr-output/"
fi

rm -r ext
exit 0
