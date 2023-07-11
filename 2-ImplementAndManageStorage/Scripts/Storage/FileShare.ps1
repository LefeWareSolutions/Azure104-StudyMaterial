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
$storageAcct = New-AzStorageAccount `
    -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName `
    -Location $location `
    -Kind StorageV2 `
    -SkuName Standard_LRS `
    -EnableLargeFileShare

#Create an Azure file share
$shareName = "myshare"

New-AzRmStorageShare `
    -StorageAccount $storageAcct `
    -Name $shareName `
    -EnabledProtocol SMB `
    -QuotaGiB 1024 | Out-Null

New-AzStorageDirectory `
    -Context $storageAcct.Context `
    -ShareName $shareName `
    -Path "myDirectory"


# this expression will upload that newly created file to your Azure file share
Set-AzStorageFileContent `
   -Context $storageAcct.Context `
   -ShareName $shareName `
   -Source "SampleUpload.txt" `
   -Path "SampleUpload.txt"