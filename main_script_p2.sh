#!/bin/bash

#Variables for functions default, or given with input.
INSTALL_DIR="${1}"
DATA_DIR="${INSTALL_DIR}"/"Logs_downloads_squid"
LOGFILE="${DATA_DIR}"/"Installation_and_commands.log"

#Variables that makes text appear just a little fancier.

RED='\033[0;31m'
NC='\033[0m'
LPURPLE='\033[1;35m'
YEL='\033[1;33m'
BLINKRED='\033[5;31m'
BLINKPURP='\033[5;35m'
NRML='\033[0;37m'

#Function to let text appear in a rolling-out fashion
roll() {
  msg="${1}"
    if [[ "${msg}" =~ ^=.*+$ ]]; then
      speed=".01"
    else
      speed=".03"
    fi
  let lnmsg=$(expr length "${msg}")-1
  for (( i=0; i <= "${lnmsg}"; i++ )); do
    echo -n "${msg:$i:1}"
    sleep "${speed}"
  done ; echo ""
}


#Function to declare an initial directory for environment.
start() {
echo -e "${BLINKPURP}###${NC} ${RED}Welcome to${NC} ${LPURPLE}Nick's${NC} ${RED}ROOT-CA roll-out script 2 out 2${NC}${BLINKPURP} ###${NC}"
echo -e "${CYAN}Please make sure you DO NOT run this script as${NC}${RED} privileged user${NC}${CYAN}, are you NOT?${NC}${YEL} [Y/N] ${NC}"
echo -e "${CYAN}This script is used for${NC}${RED}Making basic certificate and key combo's${NC}${CYAN}${NC}${YEL}${NC}"
read -p "Input: " -n 1 -r
echo -e "${YEL}"
if [[ $REPLY =~ ^[Nn]$  ]]
then
	echo -e  "${RED}User acknowledged webpage failure; stopping...${NC}"
	exit 1
fi

}

read_input(){
clear
roll "Enter the name of the server i.e: Moodle, DNS01, DNS02, Proxy"
echo ""
read -p 'Enter name: ' name
roll "Enter the type: client, server or ca"
echo ""
read -p 'Enter type: ' type
echo -e "Information entered: $name is a $type"
}

creating_dirs_and_certs() {
mkdir ~/Desktop/$name-csr
cd ~/Desktop/$name-csr
openssl genrsa -out $name-$type.key
openssl req -new -key $name-$type.key -out $name-$type.req
cd ~/easy-rsa
./easyrsa import-req ~/Desktop/$name-csr/$name-$type.req $name-$type
./easyrea sign-req $type $name-$type

}


end() {
clear
roll "Underneath is your distributable certificate from: $name $type."
roll "A workable copy is distributed to the desktop."
cat ~/easy-rsa/pki/issued/$name-$type.crt
cp ~/easy-rsa/pki/issued/$name-$type.crt /home/g05-rootca01/Desktop
clear
roll "Instructions to import certificate on other machines:"
roll "On CentOS, Fedora or other RedHat distro's do the following"
echo -e "${YEL}1. Change /tmp/ca.crt with this new one or any other.${NC}"
echo -e "${YEL}2. sudo cp /tmp/ca.crt /etc/pki/ca-trust/source/anchors/.${NC}"
echo -e "${YEL}3. update-ca-trust${NC}"
roll "Debian and Ubuntu derived distro's."
echo -e "${YEL}1. Change /tmp/ca.rt with this new one or any other.${NC}"
echo -e "${YEL}2. sudo cp /tmp/ca.crt /usr/local/share/ca-certificates/.${NC}"
echo -e "${YEL}3. update-ca-certificates${NC}"
}


start
read_input
creating_dirs_and_certs
end
