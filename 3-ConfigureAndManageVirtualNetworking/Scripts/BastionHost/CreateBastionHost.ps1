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