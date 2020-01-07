#!/bin/bash
##########################
#
#
# PAN DHCP Interface Address Object Updater
# Configuration Script 
# Version 1.1
#
##########################

# Change Log
# 1.1
# - Updated to include steps to capture firewall details from user for variables in 'panobjectupdate' script
script="panobjectupdate_1.2.sh"

echo ""
printf "      Welcome to the Palo Alto Networks DHCP Interface Address Object Updater configuration tool\n"
echo ""
echo ""
printf "This script requires the following tools installed on order to function...\n"
printf "     'xmllint' - Utilisted for parsing of XML configuration data\n"
printf "     'gnupg' - Utilised for secure storage of API key\n"
echo ""
echo ""
read -p "Press any key to continue..."
echo ""
echo ""
echo "-----------------------------------------------------------------------------------------------------------------------------"
echo "-----------------------------------------------------------------------------------------------------------------------------"
echo ""
echo ""
printf "To securely store your API key, a GNUPG key pair must be generated. Before proceeding, please generate a new key pair \n"
printf "with the with the below paramaters... \n"
echo ""
echo ""
printf "Key-Type: RSA\n"
printf "Key-Length: 4096\n"
printf "Subkey-Type: RSA\n"
printf "Subkey-Length: 4096\n"
printf "Name-Real: Pick any valid name and use when queried for GPG key name...\n"
printf "Expire-Date: 0\n"
echo ""
echo ""
printf "NOTE: This tool is best utilised with crontab. Thus this key pair MUST NOT UTILISE A PASSPHRASE in order to run non-interactivly.\n"
echo ""
echo ""
printf "If you have not created the key-pair, please close this script (cntrl-c) and do so before proceeding. Otherwise please proceed...\n"
echo ""
echo ""
read -p "Press any key to continue..."


###############		Might perform key gen as part of script later
# printf "A new GPG key pair will now be generated for the purpose of surely storing your API key\n"
# echo ""
# echo ""
# read -p "Press any key to continue..."
# export gpghome="$(mktemp -d)"
# cat > gpgpan <<EOF
# Key-Type: RSA
# Key-Length: 4096
# Subkey-Type: RSA
# Subkey-Length: 4096
# Name-Real: panops
# Expire-Date: 0
# %commit
# EOF
# gpg --batch --gen-key gpgpan
# sleep 5s
# printf "A new GPG key pair has been generated. Use the below command to view this key (panops)...\new"
# printf "     gpg --list-keys"

printf "What is your firewalls hostname/IP?\n"
read -p 'Hostname/IP: ' hostname
echo ""
echo ""
printf "Which administrative account owns the API key generated during configuration?\n"
read -p 'Administrator: ' administrator
echo ""
echo ""
printf "Name the DHCP client interface want monitored. (E.g ethernet1/1 or ae1.200)\n"
read -p 'DHCP Interface: ' dhcpinterface
echo ""
echo ""
printf "Name the Address object which is currently defined to be that of "$dhcpinterface"\n"
read -p 'Address Object: ' addressobject
echo ""
echo ""
#Testing
echo ""$hostname""
echo ""$administrator""
echo ""$dhcpinterface""
echo ""$addressobject""
sed -i -e "s%"hostname=.*"%hostname="\"$hostname\""%" $script
sed -i -e "s%"administrator=.*"%administrator="\"$administrator\""%" $script
sed -i -e "s%"dhcpinterface=.*"%dhcpinterface="\"$dhcpinterface\""%" $script
sed -i -e "s%"addressobject=.*"%addressobject="\"$addressobject\""%" $script
echo ""
echo ""
echo "-----------------------------------------------------------------------------------------------------------------------------"
echo "-----------------------------------------------------------------------------------------------------------------------------"
echo ""
echo ""
printf "Please enter the API key for an administrative account of your firewall with limited priviledges to perform the following via the API...\n"
printf "     Operational Commands\n"
printf "     Configuration\n"
printf "     Commit\n"
printf "This account SHOULD NOT have any GUI or CLI access!\n"
read -sp 'API Key: ' apikey
echo ""
printf "Please enter the name of the GPG key you wish to encrypt your API key with...\n"
read -p 'GPG Key Name: ' gpgkey
echo "--------------------------------------------------Encrypting with GPG-------------------------------------------------------"
echo $apikey | gpg --encrypt --armor -r $gpgkey > apikey.gpg
echo "----------------------------------------------------------------------------------------------------------------------------"
echo ""
printf "Assuming no errors with GPG (see above), Your API key has been stored securely... kinda\n"


