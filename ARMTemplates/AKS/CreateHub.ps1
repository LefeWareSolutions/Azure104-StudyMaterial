rg="LWSAKS"
location="eastus"
hubVNetName="HubVNet"
jumpboxVMSubnetName="jumpboxVMSubnet"
aksVNet="vnet"
vmName="jumpboxVM"

az login

#Create Hub
az network vnet create \
  -g $rg \
  -n $hubVNetName \
  --address-prefixes 10.0.0.0/22

az network vnet subnet create \
  --vnet-name $hubVNetName \
  --name $jumpboxVMSubnetName \
  -g $rg \
  --address-prefix 10.0.0.0/24


#Create peering
az network vnet peering create \
  -g $rg \
  -n HubToSpoke1 \
  --vnet-name $hubVNetName \
  --remote-vnet $aksVNet \
  --allow-vnet-access

az network vnet peering create \
    -g $rg \
    -n Spoke1ToHub \
    --vnet-name $aksVNet \
    --remote-vnet $hubVNetName \
    --allow-vnet-access


#deploy a Jumpbox Server
az vm create \
  --resource-group $rg \
  --name $vmName \
  --image UbuntuLTS \
  --admin-username azureuser \ 
  --vnet-name $hubNetworkName \
  --subnet $jumpboxVMSubnetName \
  --generate-ssh-keys


#Create a link the DNS zone to the hub net to make sure that your jumpbox is correctly able to resolve the dns name of your private link enabled cluster 
#using kubectl from the jumbox. This will ensure that your jumpbox can resolve the private ip of the api server using azure dns.
dnsZoneName=$(az network private-dns zone list --resource-group MC_LWSAKS_AKSTest_eastus --query "[0].name" -o tsv)
hubVNetId=$(az network vnet show -g $rg -n $hubVNetName --query id -o tsv)

az network private-dns link vnet create \
  --name "hubnetdnsconfig" \
  --registration-enabled false \
  --resource-group MC_LWSAKS_AKSTest_eastus \
  --virtual-network $hubVNetId \
  --zone-name $dnsZoneName

#Disable Network policies in subnet
az network vnet subnet update \
  --name $SUBNET_NAME \
  --vnet-name $hubNetworkName \
  --resource-group $rg \
  --disable-private-endpoint-network-policies

 #Configure Private DNS zone 
 az network private-dns zone create \
  --resource-group $rg \
  --name "privatelink.azurecr.io"
  
 #Create an association link
 az network private-dns link vnet create \
  --resource-group $rg \
  --zone-name "privatelink.azurecr.io" \
  --name MyDNSLink \
  --virtual-network $hubNetworkName \
  --registration-enabled false

az network private-endpoint create 
    --name myPrivateEndpoint 
    --resource-group $rg 
    --vnet-name $hubNetworkName
    --subnet $SUBNET_NAME
    --private-connection-resource-id "/subscriptions/c2483929-bdde-40b3-992e66dd68f52928/resourcegroups/harmonicrg/providers/Microsoft.ContainerService/managedClusters/harmoniccluster" 
    --group-ids management 
    --connection-name myConnection