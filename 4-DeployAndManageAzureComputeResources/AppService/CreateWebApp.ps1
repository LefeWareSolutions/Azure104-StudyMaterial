$subscriptionName = 'LefeWareSolutions-POC'
$location = "eastus"
$resourceGroupName = "Azure300"


Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context


# Replace the following URL with a public GitHub repo URL
$gitrepo="https://github.com/Azure-Samples/app-service-web-dotnet-get-started.git"
$webappname="mywebapp$(Get-Random)"

# Create a resource group.
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create an App Service plan in Free tier.
New-AzAppServicePlan `
    -Name $webappname `
    -Location $location `
    -ResourceGroupName $resourceGroupName `
    -Tier Free

# Create a web app.
New-AzWebApp `
    -Name $webappname `
    -Location $location `
    -AppServicePlan $webappname `
    -ResourceGroupName $resourceGroupName

# Configure GitHub deployment from your GitHub repo and deploy once.
$PropertiesObject = @{
    repoUrl = "$gitrepo";
    branch = "master";
    isManualIntegration = "true";
}
Set-AzResource -PropertyObject $PropertiesObject `
    -ResourceGroupName $resourceGroupName `
    -ResourceType Microsoft.Web/sites/sourcecontrols `
    -ResourceName $webappname/web `
    -ApiVersion 2015-08-01 -Force

#Delete resource group
Remove-AzResourceGroup -Name $resourceGroupName -Force