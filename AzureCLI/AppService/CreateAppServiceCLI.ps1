az login 

#Set Subscription
az account list
az account set --subscription "LefeWare-Learning-Development"


#Set the default resource group and region for subsequent commands
az group create --name Azure300 --location eastus
az configure --defaults group=Azure300 location=eastus


#Create an app service plan that defines the underlying virtual machine used by the App Service
az appservice plan create --name myPlan --sku F1

#Create the webapp with a name http://<your_app_name>.azurewebsites.net using the previously created plan
az webapp create --name LWLAzure300Test --plan myPlan --runtime "DOTNETCORE|3.1"