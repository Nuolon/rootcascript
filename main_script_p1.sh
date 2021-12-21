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
echo -e "${BLINKPURP}###${NC} ${RED}Welcome to${NC} ${LPURPLE}Nick's${NC} ${RED}ROOT-CA roll-out script 1 out 2${NC}${BLINKPURP} ###${NC}"
echo -e "${CYAN}Please make sure you DO NOT run this script as${NC}${RED} privileged user${NC}${CYAN}, are you NOT?${NC}${YEL} [Y/N] ${NC}"
read -p "Input: " -n 1 -r
echo -e "${YEL}"
if [[ $REPLY =~ ^[Nn]$  ]]
then
	echo -e  "${RED}User acknowledged webpage failure; stopping...${NC}"
	exit 1
fi

}

#Function to change hostname
change_hostname() {
sudo hostnamectl set-hostname G05-RootCA01
}

Disable_selinux() {
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
}

Enable_EPEL_RSA() {
sudo dnf install epel-release -y
sudo dnf install easy-rsa
}

mkdir_PKI_and_perms(){
#made by the default user; normal users should be able to manage and interact with CA without elevated privilges
mkdir ~/easy-rsa
ln -s /usr/share/easy-rsa/3/* ~/easy-rsa/
chmod 700 /home/g05-rootca01/easy-rsa
./home/g05-rootca01/easy-rsa/easyrsa init-pki
}

edit_vars() {
cat >~/easy-rsa/vars <<EOL
set_var EASYRSA_REQ_COUNTRY    "NL"
set_var EASYRSA_REQ_PROVINCE   "Overijssel"
set_var EASYRSA_REQ_CITY       "Deventer"
set_var EASYRSA_REQ_ORG        "Ijsselstreek"
set_var EASYRSA_REQ_EMAIL      "admin@groep5.local"
set_var EASYRSA_REQ_OU         "Community"
set_var EASYRSA_ALGO           "ec"
set_var EASYRSA_DIGEST         "sha512"
EOL

}

end() {
clear
roll "Part one of the script is about done; choose a secure password and remember it"
roll "Run part two after selecting the password."
./home/g05-rootca01/easy-rsa/easyrsa build-ca
}


start
change_hostname
Disable_selinux
Enable_EPEL_RSA
mkdir_PKI_and_perms
end
