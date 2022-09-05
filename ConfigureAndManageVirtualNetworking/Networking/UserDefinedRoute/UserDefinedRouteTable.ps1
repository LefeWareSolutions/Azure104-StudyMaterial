$subscriptionName = 'LefeWareSolutions-Production'
$resourceGroupName = "UDR-Test-RG"
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

#This route forwards packets to the local virtual network
$Route = New-AzRouteConfig -Name "Route07" -AddressPrefix 10.1.0.0/16 -NextHopType "VnetLocal"

New-AzRouteTable -Name "RouteTable01" -ResourceGroupName $resourceGroupName -Location $location -Route $Route