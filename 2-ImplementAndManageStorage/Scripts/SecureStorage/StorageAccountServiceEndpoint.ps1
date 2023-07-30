$subscriptionName = 'LefeWareSolutions-POC'
$location = "centralus"
$resourceGroupName = "az104-rg"

$storageAccountName = "lwscusstaz104st"

$virtualNetworkName = "myVNet"
$subnetName = "mySubnet"
$endpointName = "myServiceEndpoint"


# Connect to Azure 
Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context
New-AzResourceGroup -Name $resourceGroupName -Location $location


# Create a virtual network
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName `
  -Location $location `
  -Name $virtualNetworkName `
  -AddressPrefix "10.0.0.0/16"

$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name $subnetName `
  -AddressPrefix "10.0.1.0/24" `
  -VirtualNetwork $vnet `
  -ServiceEndpoint "Microsoft.Storage"
$vnet | Set-AzVirtualNetwork

# Create Storage account and enable communication from above subnet
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName `
  -Name $storageAccountName `
  -Location $location `
  -SkuName Standard_LRS `
  -Kind StorageV2 `
  -AccessTier Hot


# Add a virtual network rule to the storage account
$networkRuleSet = $storageAccount.NetworkRuleSet
$networkRuleSet.DefaultAction = "Deny"
$networkRuleSet.VirtualNetworkRules.Add((New-Object -TypeName Microsoft.Azure.Management.Storage.Models.VirtualNetworkRule -ArgumentList $subnetConfig.Id, "true"))
$storageAccount | Update-AzStorageAccountNetworkRuleSet -NetworkRuleSet $networkRuleSet

 
#Delete Resource Group
Remove-AzResourceGroup -Name $resourceGroupName -Force

