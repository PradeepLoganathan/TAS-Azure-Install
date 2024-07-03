#!/bin/bash

# Ops Manager Image URL (get from Broadcom Support Portal based on your region)
OPS_MAN_IMAGE_URL="https://opsmanagersoutheastasia.blob.core.windows.net/images/ops-manager-3.0.30-build.1377.vhd"
OPS_MAN_IMAGE_NAME="ops-manager-3.0.30-build.1377.vhd"  # Use a version-specific name for easier upgrades

# Upload Ops Manager image to storage account (assuming managed disks)
az storage blob copy start --source-uri $OPS_MAN_IMAGE_URL \
                          --connection-string $BOSH_CONNECTION_STRING \
                          --destination-container opsmanager \
                          --destination-blob $OPS_MAN_IMAGE_NAME

# Check the copy status and wait for it to complete
az storage blob show --name $OPS_MAN_IMAGE_NAME --container-name opsmanager --connection-string $BOSH_CONNECTION_STRING --query "properties.copy.status"

#you can also check the progress using this
az storage blob show --name $OPS_MAN_IMAGE_NAME --container-name opsmanager --connection-string $BOSH_CONNECTION_STRING --query "properties.copy.progress" --output tsv

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

# create SSH keys
ssh-keygen -t rsa

#Create a Managed Image
az image create --resource-group $RESOURCE_GROUP \
                --name opsman-image-3.0.30 \
                --source https://$BOSH_STORAGE_NAME.blob.core.windows.net/opsmanager/$OPS_MAN_IMAGE_NAME \
                --location $LOCATION \
                --os-type Linux


# Create the Ops Manager VM (assuming managed disks)
az vm create --name opsman-3.0.30 \
             --resource-group $RESOURCE_GROUP \
             --location $LOCATION \
             --nics opsman-nic \
             --image opsman-image-3.0.30 \
             --os-disk-size-gb 128 \
             --os-disk-name opsman-3.0.30-osdisk \
             --admin-username ubuntu \
             --size Standard_DS2_v2 \
             --storage-sku Standard_LRS \
             --ssh-key-value ~/.ssh/opsmgr.pub 


az vm show --name opsman-3.0.30 --resource-group $RESOURCE_GROUP

az vm get-instance-view --name opsman-3.0.30 --resource-group $RESOURCE_GROUP


az network dns record-set a show -g pradeep-tas-domain-rg -z mytasplatform.com -n opsmanager