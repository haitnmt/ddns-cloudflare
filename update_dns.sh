#!/bin/bash

# API Token (Recommended)
auth_token="Your-Token"

# Domain and DNS record for synchronization
zone_identifier="Your-Zone-Identifier" # Can be found in the "Overview" tab of your domain
record_name="ip.domain.com"           # Which record you want to be synced

# SCRIPT START
echo "Check Initiated"

# Check for current external network IP
ip=$(curl -s4 https://icanhazip.com/)
if [[ -z "$ip" ]]; then
  echo "Network error, cannot fetch external network IP." >&2
  exit 1
fi
echo "  > Fetched current external network IP: $ip"

# Authorization header
header_auth_param=( -H "Authorization: Bearer $auth_token" )

# Fetch the DNS record
record=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$record_name&type=A" "${header_auth_param[@]}" -H "Content-Type: application/json")

# Check if record fetch was successful
if [[ -z "$record" ]] || [[ "$record" == *'"count":0'* ]]; then
  echo "Record does not exist or cannot fetch DNS record. Create one first or check network." >&2
  exit 1
fi

# Extract record identifier and existing IP address
record_identifier=$(echo "$record" | sed -n 's/.*"id":"\([^"]*\).*/\1/p')
old_ip=$(echo "$record" | sed -n 's/.*"content":"\([^"]*\).*/\1/p')
echo "  > Fetched current DNS record value: $old_ip"

# Compare if the IP addresses are the same
if [[ "$ip" == "$old_ip" ]]; then
  echo "Update for A record '$record_name ($record_identifier)' cancelled. IP has not changed."
  exit 0
fi
echo "  > Different IP addresses detected, synchronizing..."

# Update the DNS record
update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
  "${header_auth_param[@]}" -H "Content-Type: application/json" \
  --data "{\"id\":\"$zone_identifier\",\"type\":\"A\",\"proxied\":true,\"name\":\"$record_name\",\"content\":\"$ip\",\"ttl\":120}")

# Check the update result
if [[ "$update" == *'"success":true'* ]]; then
  echo -e "Update for A record '$record_name ($record_identifier)' succeeded.\n  - Old value: $old_ip\n  + New value: $ip"
else
  echo "Update for A record '$record_name ($record_identifier)' failed. DUMPING RESULTS:\n$update" >&2
  exit 1
fi