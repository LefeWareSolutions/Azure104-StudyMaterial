$subscriptionName = 'LefeWareSolutions-POC'
$resourceGroupName = "Az104"
$location = "EastUS"

# Connect to Azure 
Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context


New-AzResourceGroup -ResourceGroupName $resourceGroupName -Location $location

#Create the Network
$Bastionsub = New-AzVirtualNetworkSubnetConfig -Name AzureBastionSubnet -AddressPrefix 10.0.0.0/27
$FWsub = New-AzVirtualNetworkSubnetConfig -Name AzureFirewallSubnet -AddressPrefix 10.0.1.0/26
$Worksub = New-AzVirtualNetworkSubnetConfig -Name Workload-SN -AddressPrefix 10.0.2.0/24

$testVnet = New-AzVirtualNetwork -Name Test-FW-VN -ResourceGroupName $resourceGroupName `
-Location $location -AddressPrefix 10.0.0.0/16 -Subnet $Bastionsub, $FWsub, $Worksub


#Create Bastion
$publicip = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location `
   -Name Bastion-pip -AllocationMethod static -Sku standard
New-AzBastion -ResourceGroupName $resourceGroupName -Name Bastion-01 -PublicIpAddress $publicip -VirtualNetwork $testVnet

#Create the NIC
$wsn = Get-AzVirtualNetworkSubnetConfig -Name  Workload-SN -VirtualNetwork $testvnet
$NIC01 = New-AzNetworkInterface -Name Srv-Work -ResourceGroupName $resourceGroupName -Location $location -Subnet $wsn

#Create the virtual machine
$VirtualMachine = New-AzVMConfig -VMName Srv-Work -VMSize "Standard_DS2"
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName Srv-Work -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC01.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $VirtualMachine -Verbose

# Create the firewall
$FWpip = New-AzPublicIpAddress -Name "fw-pip" -ResourceGroupName $resourceGroupName `
  -Location $location -AllocationMethod Static -Sku Standard
$Azfw = New-AzFirewall -Name Test-FW01 -ResourceGroupName $resourceGroupName -Location $location -VirtualNetwork $testVnet -PublicIpAddress $FWpip
$AzfwPrivateIP = $Azfw.IpConfigurations.privateipaddress
$AzfwPrivateIP


#Create a route and associate to the subnet
$routeTableDG = New-AzRouteTable `
  -Name Firewall-rt-table `
  -ResourceGroupName $resourceGroupName `
  -location $location `
  -DisableBgpRoutePropagation

Add-AzRouteConfig `
  -Name "DG-Route" `
  -RouteTable $routeTableDG `
  -AddressPrefix 0.0.0.0/0 `
  -NextHopType "VirtualAppliance" `
  -NextHopIpAddress $AzfwPrivateIP `
 | Set-AzRouteTable

Set-AzVirtualNetworkSubnetConfig `
  -VirtualNetwork $testVnet `
  -Name Workload-SN `
  -AddressPrefix 10.0.2.0/24 `
  -RouteTable $routeTableDG | Set-AzVirtualNetwork

#Set application rule allowing outbound access to www.google.com.
$AppRule1 = New-AzFirewallApplicationRule -Name Allow-Google `
  -SourceAddress 10.0.2.0/24 `
  -Protocol http, https `
  -TargetFqdn www.google.com

$AppRuleCollection = New-AzFirewallApplicationRuleCollection -Name App-Coll01 `
  -Priority 200 `
  -ActionType Allow `
  -Rule $AppRule1

$Azfw.ApplicationRuleCollections.Add($AppRuleCollection)
Set-AzFirewall -AzureFirewall $Azfw

#Set Network rule allowing outbound access to two IP addresses at port 53 (DNS).
$NetRule1 = New-AzFirewallNetworkRule -Name "Allow-DNS" `
  -Protocol UDP `
  -SourceAddress 10.0.2.0/24 `
  -DestinationAddress 209.244.0.3,209.244.0.4 `
  -DestinationPort 53 `

$NetRuleCollection = New-AzFirewallNetworkRuleCollection -Name RCNet01 `
  -Priority 200 `
  -Rule $NetRule1 `
  -ActionType "Allow"

$Azfw.NetworkRuleCollections.Add($NetRuleCollection)
Set-AzFirewall -AzureFirewall $Azfw

#Set DNAT Rule allowing any external network to RDP to VM (10.2.0.4) via Azure Firewall public IP address.
$dNATRule1 = New-AzFirewallNatRule -Name “DNAT2” `
  -Protocol “TCP” `
  -SourceAddress “*” `
  -DestinationAddress $FWpip.IpAddress`
  -DestinationPort “3389” `
  -TranslatedAddress “10.2.0.4” `
  -TranslatedPort “3389”

$dNATRuleCollection = New-AzFirewallNatRuleCollection -Name RDPAccess2 `
  -Priority 200 `
  -Rule $dNATRule1 

$Azfw.NatRuleCollections = $dNATRuleCollection
Set-AzFirewall -AzureFirewall $Azfw

#Change the primary and secondary DNS address for the Srv-Work network interface
$NIC01.DnsSettings.DnsServers.Add("209.244.0.3")
$NIC01.DnsSettings.DnsServers.Add("209.244.0.4")
$NIC01 | Set-AzNetworkInterface

