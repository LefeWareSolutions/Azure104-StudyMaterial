$location = "eastus"
$resourceGroupName = "Azure303"


Connect-AzAccount
New-AzResourceGroup -Name $resourceGroupName -Location $location

New-AzTemplateSpec -Name storageSpec `
  -Version 1.0a `
  -ResourceGroupName $resourceGroupName `
  -Location $location `
  -TemplateFile ./Storage/azuredeploy.json


Get-AzTemplateSpec