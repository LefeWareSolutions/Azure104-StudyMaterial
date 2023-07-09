$subscriptionName = 'LefeWareSolutions-Production'
$resourceGroupName = "AZ303"
$scaleSetName = "myScaleSet"
$location = "eastus"

# Connect to Azure 
Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context


New-AzResourceGroup -ResourceGroupName $resourceGroupName -Location "EastUS"
 
New-AzVmss `
  -ResourceGroupName $resourceGroupName `
  -Location $location `
  -VMScaleSetName $scaleSetName `
  -VirtualNetworkName "myVnet" `
  -SubnetName "mySubnet" `
  -PublicIpAddressName "myPublicIPAddress" `
  -LoadBalancerName "myLoadBalancer" `
  -UpgradePolicyMode "Automatic"

  Remove-AzResourceGroup -Name $resourceGroupName -Force -AsJob