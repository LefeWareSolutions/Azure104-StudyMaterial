$subscriptionName = 'LefeWare-Learning-Development'
$location = "eastus"
$resourceGroupName = "Test123"

$vnetName = "VNet1"
$subnetName = "subnet1"
$storageAccountName = "stlefewarelearningcms004"
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

#Enable service endpoint for Azure Storage on an existing virtual network and subnet.
$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
    -Name Subnet1 `
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

#Grant access from a virtual network
$subnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName | Get-AzVirtualNetworkSubnetConfig -Name "Subnet1"
Add-AzStorageAccountNetworkRule `
    -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName `
    -VirtualNetworkResourceId $subnet.Id

Remove-AzResourceGroup -Name $resourceGroupName -Force