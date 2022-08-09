$location="eastus"
$rgName="Azure303"

az login
az account set --subscription "LefeWareSolutions"

#Create ACR 
$acrName="pscysfacreuscommon"
$imageName="pythonwebscraper"
az group create --name $rgName --location $location
az acr create --resource-group $rgName --name $acrName --sku Basic --admin-enabled true
az acr build --file Dockerfile --registry $acrName --image pythonwebscraper .

#Create AppService
$appServicePlanName="psc-ysf-asp-dev-webscrapper"
$appName="psc-ysf-as-dev-webscrapper"
$containerUrl=$acrName+".azurecr.io/"+$imageName+":latest"
az appservice plan create --name $appServicePlanName --resource-group $rgName --is-linux
az webapp create --resource-group $rgName --plan $appServicePlanName --name $appName --deployment-container-image-name $containerUrl