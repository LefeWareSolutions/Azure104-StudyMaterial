$subscriptionName = 'LefeWareSolutions-Production'
$location = "eastus"
$resourceGroupName = "Azure303"

Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context


$adminSqlLogin = "SqlAdmin"
$password = "ChangeYourAdminPassword1"
$serverName = "server-$(Get-Random)"
$startIp = "0.0.0.0"
$endIp = "0.0.0.0"


# Create a resource group
$resourceGroup = New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create a server with a system wide unique server name
$server = New-AzSqlServer -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -Location $location `
    -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminSqlLogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force))

# Create a server firewall rule that allows access from the specified IP range
$serverFirewallRule = New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -FirewallRuleName "AllowedIPs" -StartIpAddress $startIp -EndIpAddress $endIp

# Create a blank database with an S0 performance level
$databaseName = "mySampleDatabase"
$database = New-AzSqlDatabase  -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -DatabaseName $databaseName `
    -RequestedServiceObjectiveName "S0" `
    -SampleName "AdventureWorksLT"

#Create an Serverless database on the specified server
$databaseName2 = "mySampleDatabase2"
$database2 = New-AzSqlDatabase  -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -DatabaseName $databaseName2 `
    -Edition "GeneralPurpose" `
    -Vcore 2 `
    -ComputeGeneration "Gen5" `
    -ComputeModel Serverless



# Create a DTU elastic pool
$elasticPool = New-AzSqlElasticPool -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -ElasticPoolName "ElasticPool01" `
    -Edition "Standard" `
    -Dtu 400 `
    -DatabaseDtuMin 10 `
    -DatabaseDtuMax 100 

#Create a vCore elastic pool
New-AzSqlElasticPool -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -ElasticPoolName "ElasticPool02" `
    -Edition "GeneralPurpose" `
    -vCore 2 `
    -ComputeGeneration Gen5`

# Clean up deployment 
# Remove-AzResourceGroup -ResourceGroupName $resourceGroupName