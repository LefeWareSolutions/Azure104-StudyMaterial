$location = "eastus"
$resourceGroupName = "Azure303"


Connect-AzAccount
New-AzResourceGroup -Name $resourceGroupName -Location $location

New-AzAksCluster -ResourceGroupName $resourceGroupName -Name myAKSCluster -NodeCount 1