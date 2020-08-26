
## AKS
LOCATION="canadacentral"
RG_NAME="aks-private-rg"
CLUSTER_NAME="aks-private"
NODE_SIZE="Standard_B2s"
NODE_COUNT="1"
NODE_DISK_SIZE="30"
VERSION="1.16.7"
CNI_PLUGIN="kubenet"

## Networking
AKS_VNET="vnet-private-aks"
AKS_VNET_RG="net-private-rg"
AKS_VNET_CIDR="10.10.0.0/16"
AKS_SNET="aks-subnet"
AKS_SNET_CIDR="10.10.0.0/24"
USERS_VNET="vnet-users"
USERS_RG="users-rg"
USERS_VNET_CIDR="10.100.0.0/16"
USERS_SNET="users-subnet"
USERS_SNET_CIDR="10.100.100.0/24"

##Peering
VNET_SOURCE_RG="net-private-rg"
VNET_SOURCE="vnet-private-aks"
VNET_DEST_RG="users-rg"
VNET_DEST="vnet-users"

## Jumpbox VM
VM_NAME="vm-jumpbox"
VM_IMAGE="UbuntuLTS"
VM_SIZE="Standard_B1s"
VM_OSD_SIZE="32"
VM_RG=$USERS_RG
VM_VNET=$USERS_VNET
VM_SNET="jumpbox-subnet"
VM_SNET_CIDR="10.100.110.0/28"
VM_PUBIP="vm-jumpbox-pip"

echo "configuring Networking"
## create Resource Group for Users VNet
az group create --name $USERS_RG --location $LOCATION

## Create USERS VNet and SubNet
az network vnet create \
    -g $USERS_RG \
    -n $USERS_VNET --address-prefix $USERS_VNET_CIDR \
    --subnet-name $USERS_SNET --subnet-prefix $USERS_SNET_CIDR

## create Resource Group for AKS VNet
az group create --name $AKS_VNET_RG --location $LOCATION

## Create AKS VNet and SubNet
az network vnet create \
    -g $AKS_VNET_RG \
    -n $AKS_VNET --address-prefix $AKS_VNET_CIDR \
    --subnet-name $AKS_SNET --subnet-prefix $AKS_SNET_CIDR

echo ""
echo "configuring Peering"
VNET_SOURCE_ID=$(az network vnet show \
    --resource-group $VNET_SOURCE_RG \
    --name $VNET_SOURCE \
    --query id -o tsv)
VNET_DEST_ID=$(az network vnet show \
    --resource-group $VNET_DEST_RG \
    --name $VNET_DEST \
    --query id -o tsv)

az network vnet peering create \
    --resource-group "net-private-rg" \
    --name "vnet-private-aks-to-vnet-users" \
    --vnet-name "vnet-private-aks" \
    --remote-vnet "/subscriptions/2dc9c519-7c91-42b6-a530-8a7d765267f6/resourceGroups/users-rg/providers/Microsoft.Network/virtualNetworks/vnet-users" \
    --allow-vnet-access

az network vnet peering create \
    --resource-group "users-rg" -n "vnet-users-to-vnet-private-aks" \
    --vnet-name "vnet-users"\
    --remote-vnet "/subscriptions/2dc9c519-7c91-42b6-a530-8a7d765267f6/resourceGroups/net-private-rg/providers/Microsoft.Network/virtualNetworks/vnet-private-aks" \
    --allow-vnet-access

echo ""
echo "configuring Private AKS"
## get subnet info
echo "Getting Subnet ID"
AKS_SNET_ID=$(az network vnet subnet show \
  --resource-group $AKS_VNET_RG \
  --vnet-name $AKS_VNET \
  --name $AKS_SNET \
  --query id -o tsv)

### create private aks cluster
echo "Creating Private AKS Cluster RG"
az group create --name $RG_NAME --location $LOCATION
echo "Creating Private AKS Cluster"
az aks create --resource-group $RG_NAME --name $CLUSTER_NAME \
  --kubernetes-version $VERSION \
  --location $LOCATION \
  --enable-private-cluster \
  --node-vm-size $NODE_SIZE \
  --load-balancer-sku standard \
  --node-count $NODE_COUNT --node-osdisk-size $NODE_DISK_SIZE \
  --network-plugin $CNI_PLUGIN \
  --vnet-subnet-id "/subscriptions/2dc9c519-7c91-42b6-a530-8a7d765267f6/resourceGroups/net-private-rg/providers/Microsoft.Network/virtualNetworks/vnet-private-aks/subnets/aks-subnet" \
  --docker-bridge-address 172.17.0.1/16 \
  --dns-service-ip 10.2.0.10 \
  --service-cidr 10.2.0.0/24 

## Configure Private DNS Link to Jumpbox VM
echo ""
echo "Configuring Private DNS Link to Jumpbox VM"

noderg=$(az aks show --name $CLUSTER_NAME \
    --resource-group $RG_NAME \
    --query 'nodeResourceGroup' -o tsv) 

dnszone=$(az network private-dns zone list \
    --resource-group $noderg \
    --query [0].name -o tsv)

az network private-dns link vnet create \
    --name "${USERS_VNET}-${USERS_RG}" \
    --resource-group $noderg \
    --virtual-network $VNET_DEST_ID \
    --zone-name $dnszone \
    --registration-enabled false

echo ""
echo "configuring Jumbox VM"
## create subnet for vm
echo "Creating Jumpbox subnet"
az network vnet subnet create \
    --name $VM_SNET \
    --resource-group $USERS_RG \
    --vnet-name $VM_VNET \
    --address-prefix $VM_SNET_CIDR

## get subnet info
echo "Getting Subnet ID"
SNET_ID=$(az network vnet subnet show \
  --resource-group $USERS_RG \
  --vnet-name $VM_VNET \
  --name $VM_SNET \
  --query id -o tsv)

## create public ip
echo "Creating VM public IP"
az network public-ip create \
    --resource-group $VM_RG \
    --name $VM_PUBIP \
    --allocation-method dynamic \
    --sku basic

## create vm
echo "Creating the VM"
az vm create \
    --resource-group $VM_RG \
    --name $VM_NAME \
    --image $VM_IMAGE \
    --size $VM_SIZE \
    --os-disk-size-gb $VM_OSD_SIZE \
    --subnet $SNET_ID \
    --public-ip-address $VM_PUBIP \
    --admin-username azureuser \
    --generate-ssh-keys

## connect to vm
PUBLIC_IP=$(az network public-ip show -n $VM_PUBIP -g $VM_RG --query ipAddress -o tsv)
ssh azureuser@$PUBLIC_IP -i ~/.ssh/id_rsa

## install AZ CLI
sudo az aks install-cli