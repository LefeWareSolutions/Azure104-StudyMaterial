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
  -VirtualNetwork $vnet
$vnet | Set-AzVirtualNetwork

# Create Storage account
New-AzStorageAccount -ResourceGroupName $resourceGroupName `
  -Name $storageAccountName `
  -Location $location `
  -SkuName Standard_LRS `
  -Kind StorageV2 `
  -AccessTier Hot

# Set the storage account to use the service endpoint
Set-AzStorageAccount -ResourceGroupName $resourceGroupName `
  -Name $storageAccountName `
  -EnableServiceEndpoint $true
  
$serviceEndpoint = New-AzDelegation -Name $endpointName -ServiceName "Microsoft.Storage"
$subnetConfig.ServiceEndpointPolicies.Add($serviceEndpoint)

# Set the updated subnet configuration back to the virtual network
$vnet | Set-AzVirtualNetwork
 
#Delete Storage account
Remove-AzStorageAccount `
    -Name $storageAccountName `
    -ResourceGroupName $resourceGroupName

