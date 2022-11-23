$subscriptionName = 'LefeWareSolutions-POC'
$resourceGroupName = "Az105"
$location = "eastus"

# Connect to Azure 
Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context

New-AzResourceGroup -ResourceGroupName $resourceGroupName -Location $location

# Allow inbound RDP Connections to port 3389
$rule1 = New-AzNetworkSecurityRuleConfig -Name rdp-rule `
  -Description "Allow RDP" `
  -Access Allow `
  -Protocol Tcp `
  -Direction Inbound `
  -Priority 100 `
  -SourceAddressPrefix Internet `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 3389

#Allow inbound HTTP connections to port 80
$rule2 = New-AzNetworkSecurityRuleConfig -Name web-rule `
  -Description "Allow HTTP" `
  -Access Allow `
  -Protocol Tcp `
  -Direction Inbound `
  -Priority 101 `
  -SourceAddressPrefix Internet `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 80

$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name `
    "NSG-FrontEnd" -SecurityRules $rule1,$rule2



## Add the NSG to the NIC configuration. ##
$nic = Get-AzNetworkInterface -Name myNIC -ResourceGroupName $resourceGroupName
$nic.NetworkSecurityGroup = $nsg

## Save the configuration to the network interface. ##
$nic | Set-AzNetworkInterface