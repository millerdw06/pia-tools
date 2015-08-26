#!/bin/bash
# Description: simple command Script for starting, stopping and resetting pia-tools script
# Version: 0.1
# Author: millerdw06@gmail.com

args=$@

#SERVER='CA_Toronto'
SERVER='Netherlands'

_start_transmission(){
    echo -n "Starting Transmission..."
    if [[ -z $(pidof transmission-daemon) ]]; then
        sudo -u dave transmission-daemon -g /home/dave/.config/transmission/ & > /dev/null 2>&1
        while [[ -z $(pidof transmission-daemon)  ]]
            do
                sleep 1
            done
            echo "done"
    fi

    if [[ -z $(pgrep killswitch.sh) ]]; then
        echo -n "Starting Killswitch..."
        killswitch.sh & > /dev/null 2>&1
        echo "done"
    else
        echo "Killswitch is already up."
    fi
}
_stop_transmission(){
    echo -n "Stopping Transmission..."
    if [[ -n $(pidof transmission-daemon) ]]; then
        while [[ -n $(pidof transmission-daemon) ]]
        do
            kill -9 $(pidof transmission-daemon)
        done
    fi
    echo "done"
    if [[ -n $(pgrep killswitch.sh) ]]; then
        echo -n "Stopping Killswitch..."
        kill -9 $(pgrep killswitch.sh)
        while [[ -n $(pgrep killswitch.sh) ]]
        do
            sleep 1
        done
        echo "done"
    fi
}
_start_conn() {
    echo -n "Starting VPN - $SERVER..."
    systemctl start pia@$SERVER
    while [[ -z "$(ip link | grep tun0)" ]]
    do
        sleep 1
    done
    echo "done"
}
_stop_conn(){
    echo -n "Stopping VPN - $SERVER..."
    systemctl stop pia@$SERVER
    while [[ -n $(systemctl status pia@$SERVER | grep "Active: active (running)") ]]
    do
        sleep 1
    done
    echo "done"
}
_reset_conn(){
    _stop_conn
    _start_conn
}
#----------------------------------
conn(){
    _start_conn
    _start_transmission
    pia-tools -r
    status
}
disconn(){
    _stop_conn && systemctl restart iptables > /dev/null 2>&1 && _stop_transmission && status
}

status(){
    echo " "
	echo "PIA Status"
	if [[ -n $(systemctl status pia@$SERVER | grep "Active: active (running)") ]]; then
		echo "VPN...............Up - $SERVER"
	else
		echo "VPN...............Down"
    fi
    if [[ -n $(pgrep killswitch.sh) ]]; then
        echo "Killswitch........Up - $(pgrep killswitch.sh)"
    else
        echo "Killswitch........Down"
    fi
    if [[ -n $(pidof transmission-daemon) ]]; then
        echo "Transmission......Up - $(pidof transmission-daemon)"
        transmission-remote -pt
    else
        echo "Transmission......Down"
    fi
}
help(){
	echo "-c - connect"
	echo "-d - disconnect"
	echo "-r - reset connection"
	echo "-s - connection status"
}

if [ "$EUID" -ne 0 ]
	then echo "Your not root so piss off"
	exit
fi

case $args in
	-c )
		conn
		;;
	-d )
    status
		disconn	
		;;
	-r )
		reset	
		;;
	-s )
		status 
		;;
	-h )
		help
		;;
    --trans-start )
        _start_transmission
        ;;
    --trans-stop )
        _stop_transmission
        ;;
    * )
		status
		;;
esac

exit 0

