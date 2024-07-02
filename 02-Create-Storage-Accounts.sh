#!/bin/bash

# Variables from previous step (assuming you've set them)
RESOURCE_GROUP="YOUR-RESOURCE-GROUP-NAME"
LOCATION="westus"

# Set variables for storage accounts
BOSH_STORAGE_NAME="your-bosh-storage-account-name" # Unique, lowercase, alphanumeric (3-24 chars)
DEPLOYMENT_STORAGE_PREFIX="your-deployment-storage-prefix"  # Unique prefix for deployment accounts
NUM_DEPLOYMENT_ACCOUNTS=5                                # Adjust based on your requirements
STORAGE_TYPE="Standard_LRS"                                 # Or "Premium_LRS"

# Create BOSH storage account (Standard_LRS is required for BOSH Director)
az storage account create --name $BOSH_STORAGE_NAME \
                         --resource-group $RESOURCE_GROUP \
                         --sku Standard_LRS \
                         --location $LOCATION

# Get BOSH storage account connection string
BOSH_CONNECTION_STRING=$(az storage account show-connection-string \
                               --name $BOSH_STORAGE_NAME \
                               --resource-group $RESOURCE_GROUP \
                               --query connectionString \
                               --output tsv)

# Create containers and table in BOSH storage account
az storage container create --name opsmanager --connection-string $BOSH_CONNECTION_STRING
az storage container create --name bosh --connection-string $BOSH_CONNECTION_STRING
az storage container create --name stemcell --connection-string $BOSH_CONNECTION_STRING
az storage table create --name stemcells --connection-string $BOSH_CONNECTION_STRING

# Create deployment storage accounts
for i in $(seq 1 $NUM_DEPLOYMENT_ACCOUNTS); do
  DEPLOYMENT_STORAGE_NAME="${DEPLOYMENT_STORAGE_PREFIX}$i"
  
  # Create storage account
  az storage account create --name $DEPLOYMENT_STORAGE_NAME \
                           --resource-group $RESOURCE_GROUP \
                           --sku $STORAGE_TYPE \
                           --kind Storage \
                           --location $LOCATION

  # Get deployment storage account connection string
  DEPLOYMENT_CONNECTION_STRING=$(az storage account show-connection-string \
                                 --name $DEPLOYMENT_STORAGE_NAME \
                                 --resource-group $RESOURCE_GROUP \
                                 --query connectionString \
                                 --output tsv)

  # Create containers in deployment storage account
  az storage container create --name bosh --connection-string $DEPLOYMENT_CONNECTION_STRING
  az storage container create --name stemcell --connection-string $DEPLOYMENT_CONNECTION_STRING
done
