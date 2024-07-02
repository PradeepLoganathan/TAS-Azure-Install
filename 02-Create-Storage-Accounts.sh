#Create Storage Accounts
az storage account create --name boshstorageaccount --resource-group tas-resource-group --location australiaeast --sku Standard_LRS
az storage account create --name deploymentstorageaccount --resource-group tas-resource-group --location australiaeast --sku Standard_LRS

#Create Containers in Storage Accounts
az storage container create --account-name boshstorageaccount --name bosh
az storage container create --account-name deploymentstorageaccount --name deployments
