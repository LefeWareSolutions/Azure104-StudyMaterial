$subscriptionName = 'LefeWareSolutions-POC'
$resourceGroupName = "DEV-LefeWareLearning-WebApp"
$VmName = "DEV-LefeWareLearning-VM"

# Connect to Azure 
Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context

# Get VM Sizes 
Get-AzVMSize -ResourceGroupName $resourceGroupName -VMName $vmName

# Resize VM
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -VMName $vmName
$vm.HardwareProfile.VmSize = "<newVMsize>"
Update-AzVM -VM $vm -ResourceGroupName $resourceGroupName