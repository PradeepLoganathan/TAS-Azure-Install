#!/bin/bash

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Network Security Groups (NSGs)
az network nsg create --name pcf-nsg --resource-group $RESOURCE_GROUP --location $LOCATION

# Add NSG rules for general TAS for VMs traffic
az network nsg rule create --name ssh --nsg-name pcf-nsg --resource-group $RESOURCE_GROUP --protocol Tcp --priority 100 --destination-port-range 22
az network nsg rule create --name http --nsg-name pcf-nsg --resource-group $RESOURCE_GROUP --protocol Tcp --priority 200 --destination-port-range 80
az network nsg rule create --name https --nsg-name pcf-nsg --resource-group $RESOURCE_GROUP --protocol Tcp --priority 300 --destination-port-range 443
az network nsg rule create --name diego-ssh --nsg-name pcf-nsg --resource-group $RESOURCE_GROUP --protocol Tcp --priority 400 --destination-port-range 2222

# Create NSG for Ops Manager traffic
az network nsg create --name opsmgr-nsg --resource-group $RESOURCE_GROUP --location $LOCATION

# Add NSG rules for Ops Manager traffic
az network nsg rule create --name http --nsg-name opsmgr-nsg --resource-group $RESOURCE_GROUP --protocol Tcp --priority 100 --destination-port-range 80
az network nsg rule create --name https --nsg-name opsmgr-nsg --resource-group $RESOURCE_GROUP --protocol Tcp --priority 200 --destination-port-range 443
az network nsg rule create --name ssh --nsg-name opsmgr-nsg --resource-group $RESOURCE_GROUP --protocol Tcp --priority 300 --destination-port-range 22

# Create virtual network
az network vnet create --name pcf-virtual-network --resource-group $RESOURCE_GROUP --location $LOCATION --address-prefixes 10.0.0.0/16

# Create subnets and associate with NSGs
az network vnet subnet create --name pcf-infrastructure-subnet --vnet-name pcf-virtual-network --resource-group $RESOURCE_GROUP --address-prefix 10.0.4.0/26 --network-security-group pcf-nsg
az network vnet subnet create --name pcf-pas-subnet --vnet-name pcf-virtual-network --resource-group $RESOURCE_GROUP --address-prefix 10.0.12.0/22 --network-security-group pcf-nsg
az network vnet subnet create --name pcf-services-subnet --vnet-name pcf-virtual-network --resource-group $RESOURCE_GROUP --address-prefix 10.0.8.0/22 --network-security-group pcf-nsg
