#!/bin/bash
##########################
#
#
# PAN DHCP Interface Address Object Updater 
# Version 1.2
#
#
##########################

# Changelog
# 1.1
# - Added cleanup tasks
# - Altered to read DHCP IP directly from firewall as opposed to using ipinfo.io/ip
# 1.2
# - Semi-secure storage of API key integrated

# Firewall Variables
hostname=""
administrator=""
dhcpinterface=""
addressobject=""

echo ""
echo ""

# Decrypt API Key
apikey=$(gpg --decrypt apikey.gpg)
echo ""
echo ""

# Testing
echo "API Key is "$apikey""

# IPv4 Variables
dhcpip=""
currentobject=""

# Obtain Raw XML from PAN which contains the configuration of the $addressobject object and store it in 'addrobject.xml'
curl -kgs "https://$hostname/api/?type=config&action=get&xpath=/config/devices/entry[@name='localhost.localdomain']/vsys/entry[@name='vsys1']/address/entry[@name='$addressobject']&key=$apikey" > addrobject.xml
# Obtain raw XML from PAN which contains the current IP address allocated by DHCP. Stored in 'intdetails.xml'
curl -kgs "https://$hostname/api/?type=op&cmd=<show><interface>$dhcpinterface</interface></show>&key=$apikey" > intdetails.xml

# Bind IP from Object from ip-netmask Xpath to variable minus the /32 CIDR mask
ipcidr=$(xmllint --xpath '//ip-netmask/text()' addrobject.xml)
currentobject=${ipcidr%/*}
# Bind IP from DHCP interface from 'dyn-addr' Xpath to variable minus any CIDR mask
dhcpipcidr=$(xmllint --xpath '//ifnet/dyn-addr/member/text()' intdetails.xml)
dhcpip=${dhcpipcidr%/*}

# Testing
echo "Live IP is "$dhcpip""
echo "Current object is set to "$currentobject""

# If the IP's do not match, update the address object with the correct IP address and perform a partial commit of the changes
if [ $currentobject != $dhcpip ]; then
	printf "\n$(date) | IP CHANGE DETECTED!\nPushing updated address object configuration\n" >> log.txt
	curl -kgs "https://$hostname/api/?type=config&action=set&key=$apikey&xpath=/config/devices/entry[@name='localhost.localdomain']/vsys/entry[@name='vsys1']/address/entry[@name='$addressobject']&element=<ip-netmask>$dhcpip/32</ip-netmask>" >> log.txt
	sleep 5s
	printf "\n$(date) | Commiting changes\n" >> log.txt
	curl -kgs "https://$hostname/api/?type=commit&cmd=<commit><partial><admin><member>$administrator</member></admin></partial></commit>&key=$apikey" >> log.txt
	printf "\n" >> log.txt
else	
	printf "$(date) | PAN Address Object reflects current IP allocated by DHCP\n" >> log.txt
fi

printf "Finished. Please check log.txt for any API errors\n"

# Cleanup
rm -f addrobject.xml
rm -f intdetails.xml
