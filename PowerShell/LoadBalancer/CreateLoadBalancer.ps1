$rg = 'MyResourceGroupLB'
$loc = 'eastus'


# Connect to Azure & Create RG 
Connect-AzAccount
New-AzResourceGroup -Name $rg -Location $loc

#---------------------------------------------------------------LOAD BALANCER CONFIG-----------------------------------------------------------#
$pubIP = 'myPublicIP'
$fe = 'myFrontEnd'
$be = 'myBackEndPool'
$hp = 'myHealthProbe'
$lbr = 'myHTTPRule'

#Create a public IP address
$publicIp = New-AzPublicIpAddress `
    -ResourceGroupName $rg `
    -Name $pubIP `
    -Location $loc `
    -AllocationMethod 'static'`
    -SKU 'Standard'

#Create frontend IP
$feip = New-AzLoadBalancerFrontendIpConfig `
    -Name $fe 
    -PublicIpAddress $publicIp

#Configure back-end address pool
$bepool = New-AzLoadBalancerBackendAddressPoolConfig `
    -Name $be

#Create the health probe
$probe = New-AzLoadBalancerProbeConfig `
    -Name $hp `
    -Protocol 'http' `
    -Port '80' `
    -RequestPath / `
    -IntervalInSeconds '360' `
    -ProbeCount '5'

#Create the load balancer rule listening on Port 80 in the frontend pool, sending load-balanced network traffic to the 
#backend address pool using Port 80 and tcp protocol.
$rule = New-AzLoadBalancerRuleConfig `
    -Name $lbr `
    -Protocol 'tcp' `
    -Probe $probe `
    -FrontendPort '80'`
    -BackendPort '80' `
    -FrontendIpConfiguration $feip `
    -BackendAddressPool $bePool `
    -DisableOutboundSNAT

#Create load balancer resource
$lb = New-AzLoadBalancer `
    -ResourceGroupName $rg `
    -Name $lbn `
    -SKU 'standard' `
    -Location $loc `
    -FrontendIpConfiguration $feip `
    -BackendAddressPool $bepool `
    -Probe $probe `
    -LoadBalancingRule $rule


#---------------------------------------------------------------NETWORK CONFIG-----------------------------------------------------------#
$sub = 'myBackendSubnet'
$bsub = 'AzureBastionSubnet'
$spfx = '10.0.0.0/24'
$bpfx = '10.0.1.0/24'
$vnm = 'myVNet'
$vpfx = '10.0.0.0/16'

## Create backend subnet config ##
$subnetConfig = New-AzVirtualNetworkSubnetConfig `
    -Name $sub `
    -AddressPrefix $spfx `

## Create Bastion subnet config ##
$bassubnetConfig = New-AzVirtualNetworkSubnetConfig `
    -name $bsub `
    -AddressPrefix $bpfx

## Create the virtual network ##
$vnet = New-AzVirtualNetwork `
    -ResourceGroupName $rg `
    -Location $loc `
    -Name $vnm `
    -AddressPrefix $vpfx 
    -Subnet $subnetConfig,$bassubnetConfig

## Create public IP address for Bastion host ##
$baspubip = New-AzPublicIPAddress `
    -ResourceGroupName $rg `
    -Name $basip `
    -Location $loc `
    -AllocationMethod $all `
    -Sku $sku
New-AzBastion -ResourceGroupName $rg -Name $bas -PublicIpAddress $baspubip -VirtualNetwork $vnet


#Create network security group to define inbound connections to your virtual network.
$rule1 = New-AzNetworkSecurityRuleConfig `
    -Name $rnm `
    -Description $des `
    -Access $acc `
    -Protocol $pro `
    -Direction $dir `
    -Priority $pri `
    -SourceAddressPrefix $spfx `
    -SourcePortRange $spr `
    -DestinationAddressPrefix $dpfx `
    -DestinationPortRange $dpr 