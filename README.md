# Cloudflare DNS Updater

A simple script to automatically update Cloudflare DNS records with the current IP address. Suitable for maintaining up-to-date DNS records for dynamic IP addresses.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Setting up Cron Job](#setting-up-cron-job)
- [License](#license)

## Introduction

Cloudflare DNS Updater is a bash script that checks the current external IP address and updates a specific DNS record on Cloudflare. This script is designed to run periodically, such as every 5 minutes, using cron jobs. It is especially useful for users with dynamic IP addresses who need to keep their DNS records accurate.

## Features

- Fetches the current external IP address.
- Compares the current IP address with the existing DNS record.
- Updates the DNS record on Cloudflare if the IP address has changed.
- Uses Cloudflare's API for safe and efficient updates.
- Can be set up to run automatically using cron jobs.
- Includes an OpenRC service script for easy setup on Alpine Linux.

## Installation

1. Download the script and place it in a suitable directory, such as `/usr/local/bin/`.
2. Ensure the script is executable:
```sh
   sudo chmod +x /usr/local/bin/update_dns.sh
```
## Usage
1. Configure the script: Open the script and fill in the necessary information such as auth_token, zone_identifier, and record_name.
2. Run the script: Execute the script to check and update the DNS record:
```sh
    /usr/local/bin/update_dns.vn.sh
```
## Configuration
Modify the following values in the script to match your configuration:
```sh
    # Token API của Cloudflare
    auth_token="YOUR_CLOUDFLARE_API_TOKEN"

    # Chi tiết miền và bản ghi DNS
    zone_identifier="YOUR_ZONE_IDENTIFIER"
    record_name="ip.domain.com"
```
## Setting up Cron Job
To run the script every 5 minutes, set up a cron job:
1. Open the crontab editor:
```sh
    export EDITOR=nano
    sudo crontab -e
```
2. Add the following line to the crontab file:
```sh
*/5 * * * * /usr/local/bin/update_dns.sh
```
## License
This project is licensed under the MIT License. See the LICENSE file for details.