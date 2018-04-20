```
 _______ __  __ _______ 
|    ___|  |/  |     __|
|    ___|     <|__     |
|___|   |__|\__|_______|
```

This tool is intended to be used in a [Known Beacons attack](https://census-labs.com/news/2018/02/01/known-beacons-attack-34c3/), however each function can be used in isolation.

Interface 1:
* Hop wireless channels (for better results)
* Flood known beacons
* Sniff client targeted probes

Interface 2:
* Deauthenticate clients

If the client probes for an SSID in your beacon list, use your preferred tool to configure an indistinguishable rogue access point. The flood rate and channel hop delay will need to be modified for optimal results.

### USAGE:

```
./flood-kick-sniff.sh
usage: ./test3 [-afhsx] [-D interface] [-b file] [-c channel(s)] [-C channel(s)] [-i interface] [-K file] [-m file] [-t number]
	-a		enable transmitter mac address filtering
	-f		enable beacon flooding
	-h		enable channel hopping
	-s		enable probe sniffing
	-x		disable initialisation
	-D <interface>	enable deauthentication on secondary interface
	-b <file>	specify non-default known beacon list
	-c <channel(s)>	specify primary interface channel(s), default = 2 GHz spectrum, "5ghz" = 5 GHz spectrum, list channels e.g. "1 3 7", or "all" = all
	-C <channel(s)>	specify secondary interface channel(s)
	-i <interface>	specify primary interface for flooding / hopping / sniffing
	-K <file>	specify non-default deauthentication kill list
	-m <file>	specify non-default mac filter list
	-r <number>	beacon flood rate per second, default = 50
	-t <number>	time in seconds between channel hopping, default = 15
	example: ./test3 -afhs -b /opt/dict/beacon-list -c "1 3 5 7 9 11" -i wlan0 -m aa:aa:aa:aa:aa:aa -t 30 -r 25 -D wlan1 -C "1 6 11" -K /tmp/kill-list
```

### DEPENDENCIES:

* Aircrack-ng
* mdk3
* tshark

### ACKNOWLEDGEMENTS:

[wifiphisher](https://github.com/wifiphisher/wifiphisher) for their known beacon list.
