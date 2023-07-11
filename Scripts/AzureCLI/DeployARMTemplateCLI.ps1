az login 

#Set Subscription
az account list
az account set --subscription "LefeWareSolutions-POC"

az group create --name DEV-LefeWareLearning-ARMCLI --location "eastus"

az deployment group create --name ARMLinux --resource-group DEV-LefeWareLearning-ARMCLI --template-file /home/josh/Desktop/Projects/Az300StudyMaterial/ARMTemplates/azuredeploy.json


#Delete Storage Account
az group delete --name DEV-LefeWareLearning-ARMCLI