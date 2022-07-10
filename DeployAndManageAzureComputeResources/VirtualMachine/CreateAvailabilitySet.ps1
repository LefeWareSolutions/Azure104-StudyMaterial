$subscriptionName = 'LefeWareSolutions-Production'
$resourceGroupName = "AZ303"
$availabilitySetName = "myAvailabilitySet"
$location = "eastus"

# Connect to Azure 
Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context


New-AzResourceGroup -ResourceGroupName $resourceGroupName -Location "EastUS"

New-AzAvailabilitySet `
   -Location $location `
   -Name $availabilitySetName `
   -ResourceGroupName $resourceGroupName `
   -Sku aligned `
   -PlatformFaultDomainCount 2 `
   -PlatformUpdateDomainCount 2

$cred = Get-Credential
for ($i=1; $i -le 2; $i++)
{
   New-AzVm `
       -ResourceGroupName $resourceGroupName `
       -Name "myVM3" `
       -Location $location `
       -VirtualNetworkName "myVnet" `
       -SubnetName "mySubnet" `
       -SecurityGroupName "myNetworkSecurityGroup" `
       -PublicIpAddressName "myPublicIpAddress3" `
       -AvailabilitySetName $availabilitySetName `
       -Credential $cred
}