#!/bin/bash
# Grab VPN internal IP
str=$(ip addr | grep tun0)
regex="inet ([[:digit:]]{0,3}.[[:digit:]]{0,3}.[[:digit:]]{0,3}.[[:digit:]]{0,3})"
[[ $str =~ $regex ]]
vpn_internal_ip=${BASH_REMATCH[1]}

echo "Found VPN internal IP [${vpn_internal_ip}]"

# Update transmission config to bind to new address
# 	"bind-address-ipv4": "x.x.x.x"
shutdown_daemon=false
if systemctl status transmission-daemon &> /dev/null; then
	shutdown_daemon=true
	echo "Stopping transmission-daemon.service before updating config..."
	systemctl stop transmission-daemon
fi

sed -i -e "/\"bind-address-ipv4\": / s/: .*/: \"${vpn_internal_ip}\",/" /var/lib/transmission-daemon/.config/transmission-daemon/settings.json

if [[ $shutdown_daemon == true ]]; then
	echo "Restarting transmission-daemon.service..."
	systemctl restart transmission-daemon
fi
