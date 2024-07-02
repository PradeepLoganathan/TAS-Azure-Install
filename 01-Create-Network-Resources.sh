#Create Resource Group in Australia East
az group create --name tas-resource-group --location australiaeast

#Create Network Security Groups (NSGs)
az network nsg create --resource-group tas-resource-group --name pcf-nsg --location australiaeast
az network nsg create --resource-group tas-resource-group --name opsmgr-nsg --location australiaeast

#Add NSG Rules
# SSH Rule
az network nsg rule create --resource-group tas-resource-group --nsg-name opsmgr-nsg --name ssh-rule --priority 100 --source-address-prefixes <your-ip-address> --destination-port-ranges 22 --access Allow --protocol Tcp --direction Inbound

# HTTP Rule
az network nsg rule create --resource-group tas-resource-group --nsg-name opsmgr-nsg --name http-rule --priority 200 --source-address-prefixes '*' --destination-port-ranges 80 --access Allow --protocol Tcp --direction Inbound

# HTTPS Rule
az network nsg rule create --resource-group tas-resource-group --nsg-name opsmgr-nsg --name https-rule --priority 300 --source-address-prefixes '*' --destination-port-ranges 443 --access Allow --protocol Tcp --direction Inbound


#Create Virtual Network with Subnets

az network vnet create --name pcf-virtual-network --resource-group tas-resource-group --location australiaeast --address-prefix 10.0.0.0/16 --subnet-name infrastructure-subnet --subnet-prefix 10.0.0.0/24

az network vnet subnet create --resource-group tas-resource-group --vnet-name pcf-virtual-network --name pas-subnet --address-prefix 10.0.1.0/24

az network vnet subnet create --resource-group tas-resource-group --vnet-name pcf-virtual-network --name services-subnet --address-prefix 10.0.2.0/24

#Associate NSG with Subnet:
az network vnet subnet update --resource-group tas-resource-group --vnet-name pcf-virtual-network --name infrastructure-subnet --network-security-group opsmgr-nsg

