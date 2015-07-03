#!/bin/bash
# Description: simple command Script for starting, stopping and resetting pia-tools script
# Version: 0.1
# Author: millerdw06@gmail.com

args=$@

SERVER='CA_Toronto'


_checkconn(){
    if [[ -n $(systemctl status pia@$SERVER | grep "running")  ]]; then
		echo 1
    else
        echo 0
    fi
}  
_startconn() {
    if !( systemctl start pia@$SERVER ); then
        exit 1
    fi
    sleep 4
}
_stopconn(){
    if !( systemctl stop pia@$SERVER ); then
        exit 1
    fi
    sleep 3
}
_resetconn(){
    if !( systemctl restart pia@$SERVER ); then
        exit 1
    fi
    sleep 4
}
#----------------------------------
_conn(){
	if [ `_checkconn` == '0' ]; then
		echo "Connecting to $SERVER"
		_startconn
    fi
    _status
}
_disconn(){
	if [ `_checkconn` == '1' ]; then
		echo "Disconnecting from $SERVER"
		_stopconn
    fi
	_status
	
	
}
_reset(){
	_resetconn
	_status
}
_status() {
	
	if [ `_checkconn` == '1' ]; then
		echo "VPN - $SERVER: Up"
	else
		echo "VPN - $SERVER: Down"
	fi
}
_help(){
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
		_conn 
		;;

	-d )      
		_disconn	
		;;
     
	-r )      
		_reset	
		;;
	-s )
		_status 
		;;
	-h )
		_help
		;;
	 * )
		_status 
		;;
esac


exit 0




