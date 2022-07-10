$STORAGE_ACCOUNT_NAME="stlefewarelearningcms003"
$RESOURCE_GROUP="AZ303"
$SUBSCRIPTION_NAME="LefeWareSolutions-Production"

az login 

#Set Subscription
az account list
az account set --subscription $SUBSCRIPTION_NAME
az group create --name $RESOURCE_GROUP --location eastus

#Create Storage Account
az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --location eastus --sku Standard_LRS --kind StorageV2


#Get Access Keys
$azkeys=az storage account keys list --account-name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP

#Update Access Tier
az storage account update \
    --name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --access-tier Cool

#Create an Account SAS Token for Storage Account
az storage blob generate-sas --account-name $STORAGE_ACCOUNT_NAME --account-key $azkeys[0].value --container-name "test" --name "test123.png" --permissions acdrw --expiry 2017-05-31 

#Delete Storage Account
az storage account delete --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP
