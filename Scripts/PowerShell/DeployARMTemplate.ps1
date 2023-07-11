$subscriptionName = 'LefeWareSolutions-POC'
$location = "eastus"
$resourceGroupName = "DEV-LefeWareLearning-ARM"


# Connect to Azure 
Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context


# Create Resource Group 
New-AzResourceGroup `
  -Name $resourceGroupName `
  -Location $location

New-AzResourceGroupDeployment `
  -ResourceGroupName $resourceGroupName `
  -TemplateFile /home/josh/Desktop/Projects/Az300StudyMaterial/ARMTemplates/azuredeploy.json


  Remove-AzResourceGroup -Name $resourceGroupName -Force -AsJob