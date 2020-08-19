$rg="LWSAKS"
$lo="eastus"

Connect-AzAccount
New-AzResourceGroup -Name $rg -Location $lo

New-AzResourceGroupDeployment `
    -ResourceGroupName $rg `
    -TemplateFile './prereqs/prereq.azuredeploy.json' `
    -TemplateParameterFile './prereqs/prereq.azuredeploy.parameters.dev.json'

New-AzResourceGroupDeployment `
    -ResourceGroupName $rg `
    -TemplateFile './azuredeploy.json' `
    -TemplateParameterFile './azuredeploy.parameters.dev.json'

Remove-AzResourceGroup -Name $resourceGroupName -Force -AsJob