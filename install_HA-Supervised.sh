#!/bin/bash 

DEBIAN_FRONTEND=noninteractive
MACHINE="qemuarm-64"
APT_LISTCHANGES_FRONTEND=none 

export DEBIAN_FRONTEND MACHINE APT_LISTCHANGES_FRONTEND

echo "Installing Homeassistant Supervised"

# Check for superuser 
if [ $(id -u) -ne 0 ] 
  then echo "Please run as Root"
  exit
fi 

if [[ ! -f /root/.ha_prepared ]]; then

  echo "Updating system"
  apt-get update 
  apt-get upgrade -y
  echo "System updated"

  # Dependencies
  apt-get install -y apparmor jq wget curl udisks2 libglib2.0-bin network-manager dbus lsb-release systemd-timesyncd systemd-journal-remote cifs-utils nfs-common systemd-resolved
  echo "Dependencies installed"

  #echo "Installing docker"
  #curl -fsSl get.docker.com | sh
  #echo "Docker installed"

  # Check for extraargs
  echo "Check for apparmor and cgroups"
  if grep -q "extraargs=apparmor=1" /boot/orangepiEnv.txt; then
    echo "Already configured"
  else 
    echo "Adding extraargs"
    echo "extraargs=apparmor=1 security=apparmor systemd.unified_cgroup_hierarchy=0" >> /boot/orangepiEnv.txt
    update-initramfs -u
  fi
  touch /root/.ha_prepared

  echo "Reboot system and run this script again"
  exit
fi


echo "Installing OS Agent"
wget https://github.com/home-assistant/os-agent/releases/download/1.7.2/os-agent_1.7.2_linux_aarch64.deb
dpkg -i os-agent_*.deb

echo "Installing homeassistant"

wget -O homeassistant-supervised.deb https://github.com/home-assistant/supervised-installer/releases/latest/download/homeassistant-supervised.deb
apt install ./homeassistant-supervised.deb

echo "Homeassistant Supervised installed, cleanup"
rm os-agent*.deb
rm homeassistant*.deb




