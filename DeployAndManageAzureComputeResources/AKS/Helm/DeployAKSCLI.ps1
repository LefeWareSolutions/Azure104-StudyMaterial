$location="eastus"
$rgName="Azure303"
$clusterName="myAKSCluster"

az login 

#Create resource group
az group create --name $rgName --location $location

#Create cluster
az aks create --resource-group $rgName --name $clusterName --node-count 1 --enable-addons monitoring --generate-ssh-keys

#Connect to cluster
az aks get-credentials --resource-group $rgName --name $clusterName
kubectl get nodes
kubectl apply -f ./azure-vote.yaml


az group delete --name $rgName --yes --no-wait