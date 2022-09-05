$subscriptionName = 'LefeWareSolutions-Production'
$location = "eastus"
$resourceGroupName = "Az104-RG"

$vnetName = "VNet1"
$backendSubnetName = "backendSubnet"
$bastionSubnetName = "bastionSubnet"
$storageAccountName = "stlefewaresolutions"
$sku = "Standard_LRS"

# Connect to Azure 
Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Configure the Virtual Network
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $backendSubnetName -AddressPrefix 10.0.0.0/24
$bastsubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $bastionSubnetName -AddressPrefix 10.0.1.0/24
$net = @{
    Name = $vnetName
    ResourceGroupName = $resourceGroupName
    Location = $location
    AddressPrefix = '10.0.0.0/16'
    Subnet = $subnetConfig, $bastsubnetConfig
}
$vnet = New-AzVirtualNetwork @net

## Create the bastion host
$ip = @{
    Name = 'myBastionIP'
    ResourceGroupName = $resourceGroupName
    Location = $location
    Sku = 'Standard'
    AllocationMethod = 'Static'
    Zone = 1,2,3
}
$publicip = New-AzPublicIpAddress @ip
$bastion = @{
    ResourceGroupName = $resourceGroupName
    Name = 'myBastion'
    PublicIpAddress = $publicip
    VirtualNetwork = $vnet
}
New-AzBastion @bastion -AsJob



## Create a WebApp

$webapp = Get-AzWebApp -ResourceGroupName $resourceGroupName -Name myWebApp1979

## Create the private endpoint connection. ## 
$pec = @{
    Name = 'myConnection'
    PrivateLinkServiceId = $webapp.ID
    GroupID = 'sites'
}
$privateEndpointConnection = New-AzPrivateLinkServiceConnection @pec

## Place the virtual network you created previously into a variable. ##
$vnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName

## Create the private endpoint. ##
$pe = @{
    ResourceGroupName = $resourceGroupName
    Name = 'myPrivateEndpoint'
    Location = $location
    Subnet = $vnet.Subnets[0]
    PrivateLinkServiceConnection = $privateEndpointConnection
}
New-AzPrivateEndpoint @pe


## Create the private DNS zone and link it ##
$zn = @{
    ResourceGroupName = $resourceGroupName
    Name = 'privatelink.azurewebsites.net'
}
$zone = New-AzPrivateDnsZone @zn
$lk = @{
    ResourceGroupName = $resourceGroupName
    ZoneName = 'privatelink.azurewebsites.net'
    Name = 'myLink'
    VirtualNetworkId = $vnet.Id
}
$link = New-AzPrivateDnsVirtualNetworkLink @lk
$cg = @{
    Name = 'privatelink.azurewebsites.net'
    PrivateDnsZoneId = $zone.ResourceId
}
$config = New-AzPrivateDnsZoneConfig @cg
$zg = @{
    ResourceGroupName = $resourceGroupName
    PrivateEndpointName = 'myPrivateEndpoint'
    Name = 'myZoneGroup'
    PrivateDnsZoneConfig = $config
}
New-AzPrivateDnsZoneGroup @zg


## Create the credential for the virtual machine. Enter a username and password at the prompt. ##
$cred = Get-Credential

## Place the virtual network into a variable. ##
$vnet = Get-AzVirtualNetwork -Name myVNet -ResourceGroupName CreatePrivateEndpointQS-rg

## Create a network interface for the virtual machine. ##
$nic = @{
    Name = 'myNicVM'
    ResourceGroupName = $resourceGroupName
    Location = 'eastus'
    Subnet = $vnet.Subnets[0]
}
$nicVM = New-AzNetworkInterface @nic

## Create the configuration for the virtual machine. ##
$vm1 = @{
    VMName = 'myVM'
    VMSize = 'Standard_DS1_v2'
}
$vm2 = @{
    ComputerName = 'myVM'
    Credential = $cred
}
$vm3 = @{
    PublisherName = 'MicrosoftWindowsServer'
    Offer = 'WindowsServer'
    Skus = '2019-Datacenter'
    Version = 'latest'
}
$vmConfig = 
New-AzVMConfig @vm1 | Set-AzVMOperatingSystem -Windows @vm2 | Set-AzVMSourceImage @vm3 | Add-AzVMNetworkInterface -Id $nicVM.Id

## Create the virtual machine. ##
New-AzVM -ResourceGroupName $resourceGroupName -Location 'eastus' -VM $vmConfig

