az login 

#Set Subscription
az account list
az account set --subscription "LefeWare-Learning-Development"

#Create Storage Account
az storage account create \
    --name stlefewarelearningcms003 \
    --resource-group Development \
    --location eastus \
    --sku Standard_LRS \
    --kind StorageV2


#Get Access Keys
az storage account keys list \
    --name stlefewarelearningcms003
    --resource-group Development

#Update Access Tier
az storage account update \
    --name stlefewarelearningcms003 \
    --resource-group Development \
    --access-tier Cool


#Delete Storage Account
az storage account delete \
    --name stlefewarelearningcms003 \
    --resource-group Development
