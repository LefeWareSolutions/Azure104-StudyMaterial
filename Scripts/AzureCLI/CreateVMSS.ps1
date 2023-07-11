az login 

#Set Subscription
az account list
az account set --subscription "LefeWareSolutions-POC"

#Create Resource Group
az group create --name myResourceGroup --location eastus

#Create VMSS
az vmss create \
  --resource-group myResourceGroup \
  --name myScaleSet \
  --image UbuntuLTS \
  --upgrade-policy-mode automatic \
  --admin-username azureuser \
  --generate-ssh-keys