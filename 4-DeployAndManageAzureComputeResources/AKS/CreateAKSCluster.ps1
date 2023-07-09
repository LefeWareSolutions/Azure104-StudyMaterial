$location = "eastus"
$resourceGroupName = "Azure104"
$clusterName = "myAKSCluster"


Connect-AzAccount
New-AzResourceGroup -Name $resourceGroupName -Location $location

New-AzAksCluster -ResourceGroupName $resourceGroupName -Name $clusterName -NodeCount 1 -GenerateSshKey

az aks get-credentials --resource-group $resourceGroupName --name $clusterName

#Check for available versions
Get-AzAksUpgradeProfile -ResourceGroupName $resourceGroupName -ClusterName $clusterName |
 Select-Object -Property Name, ControlPlaneProfileKubernetesVersion -ExpandProperty ControlPlaneProfileUpgrade |
 Format-Table -Property *

# Set max surge for a new node pool
az aks nodepool add -n mynodepool -g $resourceGroupName --cluster-name $clusterName --max-surge 33%

#Upgrade to latest version 
Set-AzAksCluster -ResourceGroupName $resourceGroupName -Name $clusterName -KubernetesVersion 1.23.5