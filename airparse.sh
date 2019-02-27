#!/bin/bash

file="$1"
ssid="$2"
# ssid1="$2"
# ssid2="$3"
# ssid3="$4"...

if [[ $# = 0 ]]
then
	# airodump-ng --essid "ssid 1" --essid "ssid 2"...
	echo "[*] run airodump-ng"
	echo "# airodump-ng --channel 1-13,32-116,132-165 -w <output file> --output-format csv <interface>"
	echo
	echo "[*] then run airparse.sh"
	echo "# airparse.sh <airodump-ng output csv> <ssid>"
	exit 1
fi

# multiple ssids
# cat "$file" | egrep -e "("$ssid1"|"$ssid2"|"$ssid3")" | cut -d "," -f 1 > ap.list

# format airodump-ng output and collect access point mac addresses
awk '1;/Station MAC, First time seen/{exit}' "$file" > ap.tmp
cat ap.tmp | grep "$ssid" | cut -d "," -f 1 > ./tmp/"$ssid"-ap.list

# format airodump-ng output and collect client mac addresses associated with above access points
awk '/Station MAC, First time seen/{f=1;}f' "$file" > station.tmp
while read line
do
	grep "$line" station.tmp | cut -d "," -f 1
done < ./tmp/"$ssid"-ap.list > ./tmp/"$ssid"-client.list

cat ./tmp/"$ssid"-ap.list > kill-list
cat ./tmp/"$ssid"-client.list > mac-list

rm station.tmp
rm ap.tmp
rm ./tmp/"$ssid"-ap.list
rm ./tmp/"$ssid"-client.list

echo "[*] "$ssid" mac addresses, saved to ./kill-list"
cat kill-list
echo
echo "[*] client mac addresses, saved to ./mac-list"
cat mac-list
