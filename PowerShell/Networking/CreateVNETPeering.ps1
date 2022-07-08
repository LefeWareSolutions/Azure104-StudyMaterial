$subscriptionName = 'LefeWareSolutions-Development'
$resourceGroupName = "VNET-Peering-Group"
$location = "eastus"

# Connect to Azure 
Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context


New-AzResourceGroup -ResourceGroupName $resourceGroupName -Location $location

# Create the virtual network 1.
$virtualNetwork1 = New-AzVirtualNetwork `
  -ResourceGroupName $resourceGroupName `
  -Location $location `
  -Name myVirtualNetwork1 `
  -AddressPrefix 10.0.0.0/16

$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
  -Name Subnet1 `
  -AddressPrefix 10.0.0.0/24 `
  -VirtualNetwork $virtualNetwork1

$virtualNetwork1 | Set-AzVirtualNetwork


# Create the virtual network 2.
$virtualNetwork2 = New-AzVirtualNetwork `
  -ResourceGroupName $resourceGroupName `
  -Location $location `
  -Name myVirtualNetwork2 `
  -AddressPrefix 10.1.0.0/16

$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
  -Name Subnet1 `
  -AddressPrefix 10.1.0.0/24 `
  -VirtualNetwork $virtualNetwork2

$virtualNetwork2 | Set-AzVirtualNetwork


# Peers myVirtualNetwork1 to myVirtualNetwork2.
Add-AzVirtualNetworkPeering `
  -Name myVirtualNetwork1-myVirtualNetwork2 `
  -VirtualNetwork $virtualNetwork1 `
  -RemoteVirtualNetworkId $virtualNetwork2.Id

# Peers myVirtualNetwork2 to myVirtualNetwork1.
Add-AzVirtualNetworkPeering `
  -Name myVirtualNetwork2-myVirtualNetwork1 `
  -VirtualNetwork $virtualNetwork2 `
  -RemoteVirtualNetworkId $virtualNetwork1.Id


# Check Peering State
Get-AzVirtualNetworkPeering `
  -ResourceGroupName $resourceGroupName `
  -VirtualNetworkName myVirtualNetwork1 `
  | Select PeeringState


Remove-AzResourceGroup -Name $resourceGroupName -Force