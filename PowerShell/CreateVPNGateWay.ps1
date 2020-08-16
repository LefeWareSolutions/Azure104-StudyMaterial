$RG1         = "VPNGatewayGroup"
$VNet1       = "VNet1"
$Location1   = "East US"
$FESubnet1   = "FrontEnd"
$BESubnet1   = "Backend"
$VNet1Prefix = "10.1.0.0/16"
$FEPrefix1   = "10.1.0.0/24"
$BEPrefix1   = "10.1.1.0/24"
$GwPrefix1   = "10.1.255.0/27"
$VNet1ASN    = 65010
$DNS1        = "8.8.8.8"
$Gw1         = "VNet1GW"
$GwIP1       = "VNet1GWIP"
$GwIPConf1   = "gwipconf1"
$subscriptionName = 'LefeWare-Learning-Development'


# Connect to Azure 
Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context

New-AzResourceGroup -ResourceGroupName $RG1 -Location $Location1


# Create VNET1 with 3 Subnets
$fesub1 = New-AzVirtualNetworkSubnetConfig -Name $FESubnet1 -AddressPrefix $FEPrefix1
$besub1 = New-AzVirtualNetworkSubnetConfig -Name $BESubnet1 -AddressPrefix $BEPrefix1
#You must always specify the name of the gateway subnet as "GatewaySubnet" in order for it to function properly
$gwsub1 = New-AzVirtualNetworkSubnetConfig -Name GatewaySubnet -AddressPrefix $GwPrefix1
$vnet   = New-AzVirtualNetwork `
            -Name $VNet1 `
            -ResourceGroupName $RG1 `
            -Location $Location1 `
            -AddressPrefix $VNet1Prefix `
            -Subnet $fesub1,$besub1,$gwsub1

# Create dynamic PIP Address For VNET1 gatway
$gwpip    = New-AzPublicIpAddress -Name $GwIP1 -ResourceGroupName $RG1 `
            -Location $Location1 -AllocationMethod Dynamic
            
$gwSubnetConig = Get-AzVirtualNetworkSubnetConfig -Name 'GatewaySubnet' `
            -VirtualNetwork $vnet
$gwipconf = New-AzVirtualNetworkGatewayIpConfig -Name $GwIPConf1 `
            -Subnet $gwSubnetConig -PublicIpAddress $gwpip


New-AzVirtualNetworkGateway -Name $Gw1 -ResourceGroupName $RG1 `
    -Location $Location1 -IpConfigurations $gwipconf -GatewayType Vpn `
    -VpnType RouteBased -GatewaySku VpnGw1


Remove-AzResourceGroup -Name $RG1