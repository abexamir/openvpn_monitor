#!/bin/bash

logfile=""
ovpn_config=""

# Function to log the events
log() {
    echo "$(date) - $1" >> "$logfile"
}

# Check if script is running as root
if [ "$EUID" -ne 0 ]
then
    echo "Error: This script must be run as root"
    exit 1
fi


# Get arguments
while getopts ":f:l:" opt; do
    case $opt in
        f)
            ovpn_config="$OPTARG"
            ;;
        l)
            logfile="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

if [ -z "$ovpn_config" ]; then
    echo "Error: -f option is required and should be the path to the openvpn config file"
    exit 1
fi

if [ -z "$logfile" ]; then
    logfile="/var/log/openvpn_monitor.log"
fi

# Monitoring loop
while true; do
    # Check if openvpn is already running
    if ! pgrep -x "openvpn" > /dev/null
    then
        log "OpenVPN not running, starting it"
        openvpn "$ovpn_config" &
    fi

    sleep 5

    # Store the output of the ping command in a variable
    output=$(ping -c 4 1.1.1.1)

    # Extract the latency value from the output
    latency=$(echo "$output" | grep -oE '[0-9]+\.[0-9]+/[0-9]+\.[0-9]+/[0-9]+\.[0-9]+/[0-9]+\.[0-9]+ ms')

    # Check if any packets were dropped
    if echo "$output" | grep -q " 0% packet loss"; then
        echo "No packets were dropped."
    else
        log "Packets were dropped. Restarting OpenVPN."
        openvpn_pid=$(pgrep -f openvpn)
        if [ -n "$openvpn_pid" ]
        then
            log "Killing OpenVPN process: $openvpn_pid"
            kill $openvpn_pid
        fi
        log "Starting OpenVPN"
        openvpn "$ovpn_config" &
    fi

    # Check if the latency is greater than 700ms
    if [[ $(echo $latency | cut -d / -f2) > 700 ]]; then
        log "Latency is greater than 700ms. Restarting OpenVPN."
        openvpn_pid=$(pgrep openvpn)
        if [ -n "$openvpn_pid" ]
        then
            log "Killing OpenVPN process: $openvpn_pid"
            kill $openvpn_pid
        fi
        log "Starting OpenVPN"
        openvpn "$ovpn_config" &
    else
        echo "Latency is not greater than 700ms"
    fi

    # Wait for two minutes before running the next iteration
    sleep 120

done

