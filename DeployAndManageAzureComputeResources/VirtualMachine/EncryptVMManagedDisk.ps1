$subscriptionName = 'LefeWareSolutions-Production'
$resourceGroupName = "AZ303"
$keyVaultName = "lwsaz303kv"
$vmName = "myVM"
$location = "eastus"

# Connect to Azure 
Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context


New-AzResourceGroup -ResourceGroupName $resourceGroupName -Location $location

#Create a virtual machine
$cred = Get-Credential
New-AzVM -Name $vmName `
  -Credential $cred `
  -ResourceGroupName $resourceGroupName `
  -Image Canonical:UbuntuServer:18.04-LTS:latest `
  -Size Standard_D2S_V3

#Create a Key Vault configured for encryption keys
New-AzKeyvault -name $keyVaultName `
  -ResourceGroupName $resourceGroupName `
  -Location $location `
  -EnabledForDiskEncryption

#Encrypt the virtual machine
$KeyVault = Get-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName
Set-AzVMDiskEncryptionExtension -ResourceGroupName $resourceGroupName `
  -VMName $vmName `
  -DiskEncryptionKeyVaultUrl $KeyVault.VaultUri `
  -DiskEncryptionKeyVaultId $KeyVault.ResourceId `
  -SkipVmBackup 
  -VolumeType All

#Check Encryption Status
Get-AzVmDiskEncryptionStatus -VMName $vmName `
  -ResourceGroupName $resourceGroupName