$subscriptionName = 'LefeWare-Learning-Development'
$location = "eastus"
$resourceGroupName = "Development"

$storageAccountName = "stlefewarelearningcms001"
$sku = "Standard_LRS"

# Connect to Azure 
Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context

# Create Storage account
New-AzStorageAccount -ResourceGroupName $resourceGroupName `
  -Name $storageAccountName `
  -Location $location `
  -SkuName $sku `
  -Kind StorageV2 `
  -AccessTier Hot


#Get Access Keys
Get-AzStorageAccountKey `
  -Name $storageAccountName `
  -ResourceGroupName $resourceGroupName

#Update Access Tier
Set-AzStorageAccount `
    -ResourceGroupName $resourceGroupName `
    -AccountName $storageAccountName `
    -AccessTier Cool

#Delete Storage account
Remove-AzStorageAccount `
    -Name $storageAccountName `
    -ResourceGroupName $resourceGroupName

