$location = "eastus"
$resourceGroupName = "Azure303"
$containerInstanceName = "mycontainer"


Connect-AzAccount
New-AzResourceGroup -Name $resourceGroupName -Location $location

New-AzContainerGroup -ResourceGroupName $resourceGroupName `
  -Name $containerInstanceName `
  -Image mcr.microsoft.com/azuredocs/aci-helloworld `
  -OsType Linux `
  -DnsNameLabel lws-aci-demo-win `
  -location "westus"

Get-AzContainerGroup -ResourceGroupName $resourceGroupName -Name $containerInstanceName