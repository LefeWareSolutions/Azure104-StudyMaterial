$subscriptionName = 'LefeWareSolutions-POC'
$resourceGroupName = "Az104"
$location = "eastus"

# Connect to Azure 
Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context


New-AzResourceGroup -ResourceGroupName $resourceGroupName -Location $location


Install-Module -Name Az.PrivateDns -force

#Create a Vnet
$backendSubnet = New-AzVirtualNetworkSubnetConfig -Name backendSubnet -AddressPrefix "10.2.0.0/24"
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $resourceGroupName `
  -Location eastus `
  -Name myAzureVNet `
  -AddressPrefix 10.2.0.0/16 `
  -Subnet $backendSubnet

#Create a DNS Zone
$zone = New-AzPrivateDnsZone -Name private.contoso.com -ResourceGroupName $resourceGroupName

#Link DNS Zone with Auto registration enabled
$link = New-AzPrivateDnsVirtualNetworkLink -ZoneName private.contoso.com `
  -ResourceGroupName $resourceGroupName -Name "mylink" `
  -VirtualNetworkId $vnet.id -EnableRegistration

#Create VM that should be auto registered
New-AzVm `
  -ResourceGroupName $resourceGroupName `
  -Name "myVM01" `
  -Location "East US" `
  -subnetname backendSubnet `
  -VirtualNetworkName "myAzureVnet" `
  -addressprefix 10.2.0.0/24 `
  -OpenPorts 3389

#Create additional A Record for ab.private.contoso.com
New-AzPrivateDnsRecordSet -Name db -RecordType A -ZoneName private.contoso.com `
  -ResourceGroupName $resourceGroupName -Ttl 3600 `
  -PrivateDnsRecords (New-AzPrivateDnsRecordConfig -IPv4Address "10.2.0.4")