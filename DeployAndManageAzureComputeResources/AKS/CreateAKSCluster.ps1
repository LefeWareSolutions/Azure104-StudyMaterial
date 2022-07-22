$location = "eastus"
$resourceGroupName = "Azure104"


Connect-AzAccount
New-AzResourceGroup -Name $resourceGroupName -Location $location

New-AzAksCluster -ResourceGroupName $resourceGroupName -Name myAKSCluster -NodeCount 1