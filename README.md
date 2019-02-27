```
					 _______ __  __ _______ 
					|    ___|  |/  |     __|
					|    ___|     <|__     |
					|___|   |__|\__|_______|
```

this tool is intended to be used in a Known Beacons attack, there is a very good explanation of this [here](https://census-labs.com/news/2018/02/01/known-beacons-attack-34c3/), including a comparison to the well known KARMA attack.

you can use this during wireless security testing to identify client devices that have OPEN networks saved in their preferred network list.

the 2 and 5 GHz ranges are hardcoded for use in Australia, so check [your local regulations](https://en.wikipedia.org/wiki/List_of_WLAN_channels) before running the tool with default options.

### USAGE:
* identify the target ssid
* run airmon-ng to collect initial data
* run airparse.sh against the airmon-ng output to create a list of access point and client mac addresses
* run flood-kick-sniff.sh
  - deauth clients from the target access points [wlan1]
  - flood beacons from a dictionary of well known ssids (Guest, Free Public WiFi, Airport Free Wi-Fi, SkyBus-Free-Wifi, etc.) [wlan0]
  - sniff for probe responses [wlan0]
* if a client probes for a ssid in the beacon list, then they have that named network in their preferred network list and are vulnerable to a rogue access point attack.

```
./flood-kick-sniff.sh
usage: ./flood-kick-sniff.sh [-afhsx] [-D interface] [-b file] [-c channel(s)] [-C channel(s)] [-i interface] [-K file] [-m file] [-t number]
	-a		filter output for only clients in the client mac address list
	-f		enable beacon flooding
	-h		enable channel hopping
	-s		enable probe sniffing
	-x		disable initialisation (airmon-ng check kill, ifconfig wlan0 down/up, etc.)
	-i <interface>	specify primary interface for flooding / hopping / sniffing [wlan0]
	-c <channel(s)>	specify primary interface channel(s) (default = 2 GHz spectrum. "5ghz" = 5 GHz spectrum. "all" = all. list channels e.g. "1 3 7")
	-D <interface>	enable deauthentication on specified secondary interface [wlan1]
	-C <channel(s)>	specify secondary interface channel(s)
	-b <file>	specify non-default beacon list (default is ./beacon-list)
	-K <file>	specify non-default kill list (default is ./kill-list)
	-m <file>	specify non-default client list (default is ./mac-list)
	-r <number>	beacon flood rate per second (default = 50)
	-t <number>	time in seconds between channel hopping (default = 15)
example: ./flood-kick-sniff.sh -afhs -b /tmp/beacon.list -c "1 3 5 7 9 11" -i wlan0 -m /tmp/client.list -t 30 -r 25 -D wlan1 -C "1 6 11" -K /tmp/kill.list
```

![](example.png)

###### TROUBLESHOOTING:
* hop channels [wlan0]. if a device saved a connection to a network on a specific channel, it will usually not respond to beacons for that network on different channels.
* use a shorter beacon list created from OPEN networks relevant to the area of testing.
* adjust the flood rate.

###### DEPENDENCIES:

* Aircrack-ng
* mdk3
* tshark

###### ACKNOWLEDGEMENTS:

[wifiphisher](https://github.com/wifiphisher/wifiphisher) for their known beacon list.
