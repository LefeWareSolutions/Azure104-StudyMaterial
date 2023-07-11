az login 

#Set Subscription
az account list
az account set --subscription "LefeWareSolutions-POC"


resourceGroupName="VNET-Peering-Group"
location="eastus"

#Create Resource Group
az group create --name $resourceGroupName --location $location

# Create virtual network 1.
az network vnet create \
  --name Vnet1 \
  --resource-group $resourceGroupName \
  --location $location \
  --address-prefix 10.0.0.0/16

# Create virtual network 2.
az network vnet create \
  --name Vnet2 \
  --resource-group $resourceGroupName \
  --location $location \
  --address-prefix 10.1.0.0/16

# Get the id for VNet1.
VNet1Id=$(az network vnet show \
  --resource-group $resourceGroupName \
  --name Vnet1 \
  --query id --out tsv)

# Get the id for VNet2.
VNet2Id=$(az network vnet show \
  --resource-group $resourceGroupName \
  --name Vnet2 \
  --query id \
  --out tsv)

# Peer VNet1 to VNet2.
az network vnet peering create \
  --name LinkVnet1ToVnet2 \
  --resource-group $resourceGroupName \
  --vnet-name VNet1 \
  --remote-vnet-id $VNet2Id \
  --allow-vnet-access

# Peer VNet2 to VNet1.
az network vnet peering create \
  --name LinkVnet2ToVnet1 \
  --resource-group $resourceGroupName \
  --vnet-name VNet2 \
  --remote-vnet-id $VNet1Id \
  --allow-vnet-access


  az group delete --name $resourceGroupName --yes