$resourseGroup = "Azure104-RG"

az group create --name $resourseGroup --location eastus


#Using ARM Tempalte Deployment
az deployment group create --resource-group $resourseGroup --template-file containergroup.json

#Using YAML Deployment
az container create --resource-group $resourseGroup --file containergroup.yaml


az group delete --name $resourceGroup --yes --no-wait