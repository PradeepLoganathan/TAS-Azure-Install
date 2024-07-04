#!/bin/bash

#====================get the load balancer IP address====================#

# Retrieve the public IP ID associated with the load balancer
PUBLIC_IP_ID=$(az network lb show \
  --resource-group $RESOURCE_GROUP \
  --name $LOAD_BALANCER_NAME \
  --query "frontendIPConfigurations[].publicIPAddress.id" \
  --output tsv)

# Check if PUBLIC_IP_ID was retrieved successfully
if [ -z "$PUBLIC_IP_ID" ]; then
  echo "Error: Could not retrieve Public IP ID."
fi

# Retrieve the public IP address using the public IP ID
LOAD_BALANCER_IP=$(az network public-ip show \
  --ids $PUBLIC_IP_ID \
  --query "ipAddress" \
  --output tsv)

# Check if LOAD_BALANCER_IP was retrieved successfully
if [ -z "$LOAD_BALANCER_IP" ]; then
  echo "Error: Could not retrieve Load Balancer IP address."
  exit 1
fi

# Output the load balancer IP address for verification
echo "Load Balancer IP Address: $LOAD_BALANCER_IP"

#====================configure DNS zones based on the load balancer IP address====================#

# Add DNS records pointing to the load balancer IP address
az network dns record-set a add-record \
  --resource-group $DNS_RESOURCE_GROUP \
  --zone-name $DNS_ZONE \
  --record-set-name "system" \
  --ipv4-address $LOAD_BALANCER_IP

az network dns record-set a add-record \
  --resource-group $DNS_RESOURCE_GROUP \
  --zone-name $DNS_ZONE \
  --record-set-name "apps" \
  --ipv4-address $LOAD_BALANCER_IP

# Verify the DNS records
echo "Verifying DNS records..."
dig system.$DNS_ZONE
dig apps.$DNS_ZONE

#===============should system and apps point to load balancer ?=========================#

echo "DNS records for system and apps should now point to the load balancer IP address."
