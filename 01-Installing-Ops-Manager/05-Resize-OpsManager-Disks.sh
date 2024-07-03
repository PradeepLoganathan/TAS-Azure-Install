#!/bin/bash
#this is an optional step
# Variables
RESOURCE_GROUP="YOUR-RESOURCE-GROUP-NAME"
VM_NAME="opsman-3.0.30"       # Update to your Ops Manager VM name
OS_DISK_NAME="opsman-3.0.30-osdisk" # Update to your OS disk name

# Resize VM Disk (Optional - Recommended if installing TAS tile)
echo "Stopping VM to detach the disk..."
az vm deallocate --name $VM_NAME --resource-group $RESOURCE_GROUP

echo "Resizing OS disk to 128 GB..."
az disk update --size-gb 128 --name $OS_DISK_NAME --resource-group $RESOURCE_GROUP

echo "Starting VM..."
az vm start --name $VM_NAME --resource-group $RESOURCE_GROUP
