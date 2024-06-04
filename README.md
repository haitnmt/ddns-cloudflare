# ddns-cloudflare
A simple script to automatically update Cloudflare DNS records with the current external IP address. Ideal for maintaining up-to-date DNS records for dynamic IP addresses.
Detailed Description:
This repository contains a bash script that checks the current external IP address and updates a specified DNS record on Cloudflare. The script is designed to be run periodically, such as every 5 minutes, using cron jobs. It is especially useful for users with dynamic IP addresses who need to keep their DNS records accurate.

Key Features:

Fetches the current external IP address.
Compares the fetched IP address with the existing DNS record.
Updates the DNS record on Cloudflare if the IP address has changed.
Uses Cloudflare API for secure and efficient updates.
Can be set up to run automatically using cron jobs.
Includes an OpenRC service script for easy setup on Alpine Linux.

Usage Instructions:
Setup Script: Place the update_dns.sh script in a suitable directory, such as /usr/local/bin/, and make it executable.
'''
sudo chmod +x /usr/local/bin/update_dns.sh
'''
