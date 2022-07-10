
$subscriptionName = 'LefeWareSolutions-Development'
$location = "eastus"
$resourceGroupName = "DEV-LefeWareLearning-WebApp"

$subnetName = "Subnet01"
$subnetAddressPrefix = "192.168.1.0/24"
$vnetName = "Dev-LefeWareLearning-VNET"
$vnetAddressPrefix = "192.168.0.0/16"
$ipAddressName = "DEV-LefeWareLearning-PIP"
$networkSecurityGroupName = "DEV-LefeWareLearning-NSG"
$nicName = "DEV-LefeWareLearning-NIC"

$UserName='joshlefebvre1'
$Password=''| ConvertTo-SecureString -Force -AsPlainText
$VmName = "DEV-LefeWareLearning-VM"
$VmSize = "Standard_B2s"


# Connect to Azure 
Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context


# Create Resource Group 
New-AzResourceGroup `
  -Name $resourceGroupName `
  -Location $location

# Create a subnet configuration
$subnetConfig = New-AzVirtualNetworkSubnetConfig `
  -Name $subnetName `
  -AddressPrefix $subnetAddressPrefix

# Create a virtual network
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -Name $vnetName `
  -AddressPrefix  $vnetAddressPrefix `
  -Subnet $subnetConfig

# Create a public IP address and specify a DNS name
$pip = New-AzPublicIpAddress `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -AllocationMethod Static `
  -IdleTimeoutInMinutes 4 `
  -Name $ipAddressName

  # Create an inbound network security group rule for port 3389
$nsgRuleRDP = New-AzNetworkSecurityRuleConfig `
-Name myNetworkSecurityGroupRuleRDP `
-Protocol Tcp `
-Direction Inbound `
-Priority 1000 `
-SourceAddressPrefix * `
-SourcePortRange * `
-DestinationAddressPrefix * `
-DestinationPortRange 3389 `
-Access Allow

# Create an inbound network security group rule for port 80
$nsgRuleWeb = New-AzNetworkSecurityRuleConfig `
-Name myNetworkSecurityGroupRuleWeb `
-Protocol Tcp `
-Direction Inbound `
-Priority 1001 `
-SourceAddressPrefix * `
-SourcePortRange * `
-DestinationAddressPrefix * `
-DestinationPortRange 80 `
-Access Allow

# Create a network security group with RDP and WebAccess Rule
$nsg = New-AzNetworkSecurityGroup `
-ResourceGroupName $ResourceGroupName `
-Location $location `
-Name $networkSecurityGroupName `
-SecurityRules $nsgRuleRDP,$nsgRuleWeb

# Create a virtual network card and associate it with public IP address and NSG
$nic = New-AzNetworkInterface `
  -Name $nicName `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -SubnetId $vnet.Subnets[0].Id `
  -PublicIpAddressId $pip.Id `
  -NetworkSecurityGroupId $nsg.Id

# Define a credential object to store the username and password for the VM
$Credential=New-Object PSCredential($UserName,$Password)

# Create the VM configuration object
$VirtualMachine = New-AzVMConfig `
  -VMName $VmName `
  -VMSize $VmSize

$VirtualMachine = Set-AzVMOperatingSystem `
  -VM $VirtualMachine `
  -Windows `
  -ComputerName "MainComputer" `
  -Credential $Credential -ProvisionVMAgent

$VirtualMachine = Set-AzVMSourceImage `
  -VM $VirtualMachine `
  -PublisherName "MicrosoftWindowsServer" `
  -Offer "WindowsServer" `
  -Skus "2019-Datacenter-smalldisk" `
  -Version "latest"

# Sets the operating system disk properties on a VM.
$VirtualMachine = Set-AzVMOSDisk `
  -VM $VirtualMachine `
  -CreateOption FromImage | `
  Add-AzVMNetworkInterface -Id $nic.Id

  
  # Create the VM.
  New-AzVM `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -VM $VirtualMachine
  
