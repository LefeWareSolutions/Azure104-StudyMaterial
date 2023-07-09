$location = "eastus"
$resourceGroupName = "Azure104"
$containerInstanceName = "mycontainer"


Connect-AzAccount
New-AzResourceGroup -Name $resourceGroupName -Location $location

#Create a container group with a container instance and request a public IP address with opening ports
$port1 = New-AzContainerInstancePortObject -Port 8000 -Protocol TCP
$port2 = New-AzContainerInstancePortObject -Port 8001 -Protocol TCP

$container = New-AzContainerInstanceObject -Name test-container `
  -Image nginx `
  -RequestCpu 1 `
  -RequestMemoryInGb 1.5 `
  -Port @($port1, $port2)

$containerGroup = New-AzContainerGroup `
  -ResourceGroupName $resourceGroupName `
  -Name $containerInstanceNAme `
  -Location eastus `
  -Container $container `
  -OsType Linux `
  -RestartPolicy "Never" `
  -IpAddressType Public


Get-AzContainerGroup -ResourceGroupName $resourceGroupName -Name $containerInstanceName


az group delete --name $resourceGroupName --yes --no-wait