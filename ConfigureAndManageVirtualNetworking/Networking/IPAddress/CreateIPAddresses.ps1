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