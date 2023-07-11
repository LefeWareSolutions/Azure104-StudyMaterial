az login 

#Set Subscription
az account list
az account set --subscription "LefeWareSolutions-POC"

#List resize option
az vm list-vm-resize-options --resource-group DEV-LefeWareLearning-WebApp --name DEV-LefeWareLearning-VM --output table

#Resize VM
az vm resize --resource-group DEV-LefeWareLearning-WebApp --name myVM --size Standard_DS3_v2