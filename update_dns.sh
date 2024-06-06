#!/bin/bash

# API Token (Recommended)
auth_token="xxxxxxxxxxxxxxxxxxxxxxx-Token"

# Domain and DNS record for synchronization
zone_identifier="xxxxxxxxxxxxxxxxxxxxx-Identifier" # Can be found in the "Overview" tab of your domain
record_name="ip.domain.com"           # Record to be synchronized

# DO NOT CHANGE BELOW

# Start script
echo "Check Initiated"

# Check for current external network IP
ip=$(curl -s4 https://icanhazip.com/)
if [[ -z "$ip" ]]; then
  ip=$(curl -s4 https://ifconfig.me/)
  if [[ -z "$ip" ]]; then
    echo "Network error, cannot fetch external network IP." >&2
    exit 1
  fi
fi
echo "  > Fetched current external network IP: $ip"

# Authorization header
header_auth_param=( -H "Authorization: Bearer $auth_token" )

# Fetch the DNS record
record=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$record_name&type=A" "${header_auth_param[@]}" -H "Content-Type: application/json")

# Check if fetching the DNS record was successful
if [[ -z "$record" ]] || [[ "$record" == *'"count":0'* ]]; then
  echo "Record does not exist, creating a new record..."
  
  # Create a new record
  create_record=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records" \
    "${header_auth_param[@]}" -H "Content-Type: application/json" \
    --data '{"type":"A","name":"'$record_name'","content":"'$ip'","ttl":3600,"proxied":true}')
  
  # Check the result of creating a new record
  if [[ "$create_record" == *'"success":true'* ]]; then
    echo "Successfully created a new record."
    exit 0
  else
    echo "Failed to create a new record. RESULT:\n$create_record" >&2
    exit 1
  fi
fi

# Extract record identifier and existing IP address from the DNS record
record_identifier=$(echo "$record" | sed -n 's/.*"id":"\([^"]*\).*/\1/p')
old_ip=$(echo "$record" | sed -n 's/.*"content":"\([^"]*\).*/\1/p')
echo "  > Fetched current DNS record value: $old_ip"

# Compare current IP with new IP
if [[ "$ip" == "$old_ip" ]]; then
  echo "Update for A record '$record_name ($record_identifier)' cancelled. IP has not changed."
  exit 0
fi
echo "  > Different IP addresses detected, synchronizing..."

# Update the DNS record
update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" \
  "${header_auth_param[@]}" -H "Content-Type: application/json" \
  --data '{"id":"'$zone_identifier'","type":"A","proxied":true,"name":"'$record_name'","content":"'$ip'","ttl":3600}')

# Check the result of the update
if [[ "$update" == *'"success":true'* ]]; then
  echo -e "Update for A record '$record_name ($record_identifier)' succeeded.\n  - Old value: $old_ip\n  + New value: $ip"
else
  echo "Update for A record '$record_name ($record_identifier)' failed. RESULT:\n$update" >&2
  exit 1
fi
