subscriptionName="LefeWareSolutions-POC"
location="eastus"
resourceGroupName="Test111"

vnetName="VNet1"
subnetName="subnet1"
storageAccountName="stlefewarelearningcms004"
sku="Standard_LRS"

az login 
az account set --subscription $subscriptionName

az group create --name $subscriptionName --location $location

#Enable service endpoint for Azure Storage on an existing virtual network and subnet.
az network vnet subnet update --resource-group "myresourcegroup" --vnet-name "myvnet" --name "mysubnet" --service-endpoints "Microsoft.Storage"

#Set the default rule to deny network access by default.
az storage account update --resource-group "myresourcegroup" --name "mystorageaccount" --default-action Deny

#Grant access from a virtual network
$subnetid=(az network vnet subnet show --resource-group "myresourcegroup" --vnet-name "myvnet" --name "mysubnet" --query id --output tsv)
az storage account network-rule add --resource-group "myresourcegroup" --account-name "mystorageaccount" --subnet $subnetid