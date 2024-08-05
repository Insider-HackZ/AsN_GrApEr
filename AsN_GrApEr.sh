#!/bin/bash

urlencode() {
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            ' ') printf '+' ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done
}

domain=$1
encoded_domain=$(urlencode "$domain")
function banner() {
    tput clear
    printf "\n${bgreen}"
    printf "    _        _   _     ____       _          _____\n"
    printf "   / \   ___| \ | |   / ___|_ __ / \   _ __ | ____|_ __\n"
    printf "  / _ \ / __|  \| |  | |  _| '__/ _ \ | '_ \|  _| | '__|\n"
    printf " / ___ \ __ \ |\  |  | |_| | | / ___ \| |_) | |___| |\n"
    printf "/_/   \_\___/_| \_|___\____|_|/_/   \_\ .__/|_____|_|\n"
    printf "                 |_____|              |_| developed by:H@r&h\n"
    printf "\n${reconftw_version}                                        \n"
}

banner

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
mv "ext/$domain.txt" "ext/../$domain.txt"
rm -r ext
exit 0

