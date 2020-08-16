$location="eastus"
$rgName="Azure303"
$clusterName="LWSMyAKSCluster"
$acrName="LWSMyHelmACR"

az login 

az group create --name $rgName --location $location
az acr create --resource-group $rgName --name $acrName --sku Basic

#Configures the appropriate ACRPull role for the service principal
az aks create -g $rgName -n $clusterName --location $location  --attach-acr $acrName --generate-ssh-keys