#! /bin/bash
# Automatically set time zone when connected to the network
iface=$1
action=$2

if [[ $iface != lo && $action == up ]]; then
    tz=$(tzupdate -s 1 -p 2>/dev/null)
    if [[ -n $tz && -r /usr/share/zoneinfo/$tz ]]; then
	timedatectl set-timezone $tz
    fi
fi
