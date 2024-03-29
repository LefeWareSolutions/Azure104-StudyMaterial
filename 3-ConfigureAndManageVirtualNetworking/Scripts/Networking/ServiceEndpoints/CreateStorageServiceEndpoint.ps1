$subscriptionName = 'LefeWareSolutions-Production'
$location = "eastus"
$resourceGroupName = "Az104-RG"

$vnetName = "VNet1"
$subnetName = "subnet1"
$storageAccountName = "stlefewaresolutions"
$sku = "Standard_LRS"

# Connect to Azure 
Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context
New-AzResourceGroup -Name $resourceGroupName -Location $location


#Create VNET
$virtualNetwork1 = New-AzVirtualNetwork `
  -ResourceGroupName $resourceGroupName `
  -Location $location `
  -Name $vnetName `
  -AddressPrefix 10.0.0.0/16

#Enable service endpoint for Azure Storage on specified vnet subnet.
$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
    -Name $subnetName `
    -AddressPrefix 10.0.0.0/24 `
    -VirtualNetwork $virtualNetwork1 `
    -ServiceEndpoint "Microsoft.Storage"

$virtualNetwork1 | Set-AzVirtualNetwork

# Create Storage account
New-AzStorageAccount -ResourceGroupName $resourceGroupName `
  -Name $storageAccountName `
  -Location $location `
  -SkuName $sku `
  -Kind StorageV2 `
  -AccessTier Hot

Update-AzStorageAccountNetworkRuleSet `
  -ResourceGroupName $resourceGroupName `
  -Name $storageAccountName `
  -DefaultAction Deny

#Grant access from a virtual network
$subnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName | Get-AzVirtualNetworkSubnetConfig -Name $subnetName
Add-AzStorageAccountNetworkRule `
    -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName `
    -VirtualNetworkResourceId $subnet.Id

Remove-AzResourceGroup -Name $resourceGroupName -Force