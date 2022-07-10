$subscriptionName = 'LefeWareSolutions-Production'
$location = "eastus"
$resourceGroupName = "Az303Test"

$storageAccountName = "stlefewaresolutions001"
$sku = "Standard_LRS"

# Connect to Azure 
Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context
New-AzResourceGroup -Name $resourceGroupName -Location $location

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

#Create an Account SAS Token for Storage Account
$storageAccount=Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName      
$context=$storageAccount.Context

$sasToken = New-AzStorageAccountSASToken `
  -Context $context `
  -Service Blob,File,Table,Queue `
  -ResourceType Service,Container,Object `
  -Permission "racwdlup" `
  -Protocol HttpsOnly `
  -IPAddressOrRange 168.1.5.60-168.1.5.70


 
#Delete Storage account
Remove-AzStorageAccount `
    -Name $storageAccountName `
    -ResourceGroupName $resourceGroupName

