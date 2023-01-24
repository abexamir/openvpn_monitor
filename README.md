# OpenVPN Monitor

A simple script that monitors the stability of an OpenVPN connection and restarts it if necessary.

## Usage

```bash
sudo ./openvpn_monitor.sh -f <path_to_ovpn_config> [-l <path_to_log_file>]
```

- `-f` is a required option and should be the path to the OpenVPN configuration file (with .ovpn extension)
- `-l` is an optional option and should be the path to the log file. If not provided, the script will log to `/var/log/openvpn_monitor.log`

## Features

- Monitors the stability of the OpenVPN connection by pinging a specified IP address (1.1.1.1 in this script)
- If any packets are dropped, or the latency is greater than 700ms, the script will kill the OpenVPN process and restart it
- Logs all events to a specified log file
- Script should be run as root

## Requirements

- OpenVPN must be installed on the system
- The script uses the `ping` and `pgrep` commands
- The script uses OpenVPN config file and it should be provided with the path for it
- The script uses log file and it should be provided with the path for it

## Installation

- Clone the repository to your local machine
- Make the script executable by running `chmod +x openvpn_monitor.sh`
- Run the script using the usage instructions above
- It's recommended to use systemd to run this script as a service that way it's always running

## Systemd Service

The script can be run as a service using systemd. The provided `openvpn_monitor.service` file can be used to set this up.\
1. Copy the openvpn_monitor.service file to the /etc/systemd/system/ directory
2. Modify the ExecStart and User fields in the unit file to match the location of the script and the user that should run the script.
3. Run the following command to reload the systemd configuration and enable the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable openvpn_monitor.service
```
4. Start the service using sudo systemctl start openvpn_monitor.service.
5. Check the status of the service using sudo systemctl status openvpn_monitor.service.
The service can be stopped, started, and restarted using the standard systemd commands (e.g. sudo systemctl stop openvpn_monitor.service).

## Note

- The IP address and ping count can be modified to suit your specific needs.
- The script exits if OpenVPN is already running.
- Make sure the service unit file is correctly configured and the path and user are correctly set.
- The service will start automatically on boot and will restart if the script exits or crashes.

## Future Work

- Add more checks for stability, such as checking for a successful connection to the OpenVPN server, or monitoring the number of bytes sent/received.
- Add an option to specify the number of retries before restarting OpenVPN, and a delay between retries.
- Add an option to specify the process name for OpenVPN, in case it is not named 'openvpn' on the system.
- Add an option to specify the OpenVPN binary path, in case it is not in the PATH.
- Add an option to specify the user to run the OpenVPN as if running it as root is not desired.
- Add an option to specify the service name to be restarted when the openvpn crashes or when the connection is not stable.