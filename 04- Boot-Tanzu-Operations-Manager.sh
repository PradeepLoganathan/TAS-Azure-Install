#!/bin/bash

# Variables from previous steps
RESOURCE_GROUP="YOUR-RESOURCE-GROUP-NAME"
LOCATION="westus"
STORAGE_NAME="your-bosh-storage-account-name"
BOSH_CONNECTION_STRING="YOUR-ACCOUNT-KEY-STRING"  # Connection string for BOSH storage account

# Ops Manager Image URL (get from Broadcom Support Portal based on your region)
OPS_MAN_IMAGE_URL="YOUR-OPS-MAN-IMAGE-URL"
OPS_MAN_IMAGE_NAME="opsman-image-3.0.0.vhd"  # Use a version-specific name for easier upgrades

# Upload Ops Manager image to storage account (assuming managed disks)
az storage blob copy start --source-uri $OPS_MAN_IMAGE_URL \
                          --connection-string $BOSH_CONNECTION_STRING \
                          --destination-container opsmanager \
                          --destination-blob $OPS_MAN_IMAGE_NAME

# Check the copy status (optional)
# az storage blob show --name $OPS_MAN_IMAGE_NAME --container-name opsmanager --connection-string $BOSH_CONNECTION_STRING

# Create public IP for Ops Manager
az network public-ip create --name ops-manager-ip \
                           --resource-group $RESOURCE_GROUP \
                           --location $LOCATION \
                           --allocation-method Static

# Get the public IP address
OPS_MANAGER_PUBLIC_IP=$(az network public-ip show --name ops-manager-ip --resource-group $RESOURCE_GROUP --query ipAddress -o tsv)
echo "Ops Manager Public IP: $OPS_MANAGER_PUBLIC_IP"

# Create network interface for Ops Manager
az network nic create --vnet-name pcf-virtual-network \
                     --subnet pcf-infrastructure-subnet \
                     --network-security-group opsmgr-nsg \
                     --private-ip-address 10.0.4.4 \
                     --public-ip-address ops-manager-ip \
                     --resource-group $RESOURCE_GROUP \
                     --name opsman-nic \
                     --location $LOCATION

# Create the Ops Manager VM (assuming managed disks)
az vm create --name opsman-2.6.x \
             --resource-group $RESOURCE_GROUP \
             --location $LOCATION \
             --nics opsman-nic \
             --image $OPS_MAN_IMAGE_NAME \
             --os-disk-size-gb 128 \
             --os-disk-name opsman-2.6.x-osdisk \
             --admin-username ubuntu \
             --size Standard_DS2_v2 \
             --storage-sku Standard_LRS \
             --ssh-key-value PATH-TO-PUBLIC-KEY  # Replace with your actual SSH public key path
