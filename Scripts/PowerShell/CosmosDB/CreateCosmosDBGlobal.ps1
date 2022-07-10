$subscriptionName = 'LefeWareSolutions-Production'
$resourceGroupName = "AZ303"


# Connect to Azure 
Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context




Function New-RandomString{Param ([Int]$Length = 10) return $(-join ((97..122) + (48..57) | Get-Random -Count $Length | ForEach-Object {[char]$_}))}


$uniqueId = New-RandomString -Length 7 # Random alphanumeric string for unique resource names
$apiKind = "Sql"
$locations = @()
$locations += New-AzCosmosDBLocationObject -LocationName "East Us" -FailoverPriority 0 -IsZoneRedundant 0
$locations += New-AzCosmosDBLocationObject -LocationName "West Us" -FailoverPriority 1 -IsZoneRedundant 0


$accountName = "cosmos-$uniqueId" # Must be all lower case
$consistencyLevel = "Session"
$tags = @{Tag1 = "MyTag1"; Tag2 = "MyTag2"; Tag3 = "MyTag3"}
$databaseName = "myDatabase"
$containerName = "myContainer"
$containerRUs = 400
$partitionKeyPath = "/myPartitionKey"
$indexPathIncluded = "/*"
$compositeIndexPaths1 = @(
    @{ Path = "/myCompositePath1"; Order = "ascending" };
    @{ Path = "/myCompositePath2"; Order = "descending" }
)
$compositeIndexPaths2 = @(
    @{ Path = "/myCompositePath3"; Order = "ascending" };
    @{ Path = "/myCompositePath4"; Order = "descending" }
)
$indexPathExcluded = "/myExcludedPath/*"
$uniqueKeyPath = "/myUniqueKeyPath"
$conflictResolutionPath = "/myResolutionPath"
$ttlInSeconds = 120 # Set this to -1 (or don't use it at all) to never expire


#Create RG
New-AzResourceGroup -ResourceGroupName $resourceGroupName -Location "EastUS"


# Create CosmosDB Account
Write-Host "Creating account $accountName"
$account = New-AzCosmosDBAccount -ResourceGroupName $resourceGroupName `
    -LocationObject $locations `
    -Name $accountName `
    -ApiKind $apiKind `
    -Tag $tags `
    -DefaultConsistencyLevel $consistencyLevel `
    -EnableAutomaticFailover:$true


#Create CosmosDB Database
Write-Host "Creating database $databaseName"
$database = New-AzCosmosDBSqlDatabase -ParentObject $account -Name $databaseName


#Create CosmosDB Container    
$uniqueKey = New-AzCosmosDBSqlUniqueKey -Path $uniqueKeyPath
$uniqueKeyPolicy = New-AzCosmosDBSqlUniqueKeyPolicy -UniqueKey $uniqueKey

$compositePath1 = @()
ForEach ($compositeIndexPath in $compositeIndexPaths1) {
    $compositePath1 += New-AzCosmosDBSqlCompositePath `
        -Path $compositeIndexPath.Path `
        -Order $compositeIndexPath.Order
}

$compositePath2 = @()
ForEach ($compositeIndexPath in $compositeIndexPaths2) {
    $compositePath2 += New-AzCosmosDBSqlCompositePath `
        -Path $compositeIndexPath.Path `
        -Order $compositeIndexPath.Order
}

$includedPathIndex = New-AzCosmosDBSqlIncludedPathIndex -DataType String -Kind Range
$includedPath = New-AzCosmosDBSqlIncludedPath -Path $indexPathIncluded -Index $includedPathIndex

$indexingPolicy = New-AzCosmosDBSqlIndexingPolicy `
    -IncludedPath $includedPath `
    -CompositePath @($compositePath1, $compositePath2) `
    -ExcludedPath $indexPathExcluded `
    -IndexingMode Consistent -Automatic $true

# Conflict resolution policies only apply in multi-master accounts.
# Included here to show custom resolution path.
$conflictResolutionPolicy = New-AzCosmosDBSqlConflictResolutionPolicy `
    -Type LastWriterWins -Path $conflictResolutionPath


Write-Host "Creating container $containerName"
$container = New-AzCosmosDBSqlContainer `
    -ParentObject $database `
    -Name $containerName `
    -Throughput $containerRUs `
    -IndexingPolicy $indexingPolicy `
    -PartitionKeyKind Hash `
    -PartitionKeyPath $partitionKeyPath `
    -UniqueKeyPolicy $uniqueKeyPolicy `
    -ConflictResolutionPolicy $conflictResolutionPolicy `
    -TtlInSeconds $ttlInSeconds