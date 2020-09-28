$SUBSCRIPTION_ID=$(az account show --query id -o tsv) # here enter your subscription id
$DEPLOYMENT_NAME="dzpraks1" # short unique name, min 5 max 8 letters 
$LOCATION="westeurope" # here enter the datacenter location
$KUBE_GROUP="${DEPLOYMENT_NAME}_kube" # here enter the resources group name of your aks cluster
$KUBE_NAME="${DEPLOYMENT_NAME}" # here enter the name of your kubernetes resource
$VNET_GROUP="${DEPLOYMENT_NAME}_networks" # here the name of the resource group for the vnet and hub resources
$KUBE_VNET_NAME="spoke1-kubevnet" # here enter the name of your vnet
$KUBE_ING_SUBNET_NAME="ing-1-subnet" # here enter the name of your ingress subnet
$KUBE_AGENT_SUBNET_NAME="aks-2-subnet" # here enter the name of your aks subnet
$HUB_VNET_NAME="hub1-firewalvnet"
$HUB_FW_SUBNET_NAME="AzureFirewallSubnet" # this you cannot change
$HUB_JUMP_SUBNET_NAME="jumpbox-subnet"
$KUBE_VERSION="1.16.10" # here enter the kubernetes version of your aks

# Create the virtual networks, subnets and peerings between them:
az account set --subscription $SUBSCRIPTION_ID
az group create -n $KUBE_GROUP -l $LOCATION
az group create -n $VNET_GROUP -l $LOCATION
az network vnet create -g $VNET_GROUP -n $HUB_VNET_NAME --address-prefixes 10.0.0.0/22
az network vnet create -g $VNET_GROUP -n $KUBE_VNET_NAME --address-prefixes 10.0.4.0/22
az network vnet subnet create -g $VNET_GROUP --vnet-name $HUB_VNET_NAME -n $HUB_FW_SUBNET_NAME --address-prefix 10.0.0.0/24
az network vnet subnet create -g $VNET_GROUP --vnet-name $HUB_VNET_NAME -n $HUB_JUMP_SUBNET_NAME --address-prefix 10.0.1.0/24
az network vnet subnet create -g $VNET_GROUP --vnet-name $KUBE_VNET_NAME -n $KUBE_ING_SUBNET_NAME --address-prefix 10.0.4.0/24
az network vnet subnet create -g $VNET_GROUP --vnet-name $KUBE_VNET_NAME -n $KUBE_AGENT_SUBNET_NAME --address-prefix 10.0.5.0/24
az network vnet peering create -g $VNET_GROUP -n HubToSpoke1 --vnet-name $HUB_VNET_NAME --remote-vnet $KUBE_VNET_NAME --allow-vnet-access
az network vnet peering create -g $VNET_GROUP -n Spoke1ToHub --vnet-name $KUBE_VNET_NAME --remote-vnet $HUB_VNET_NAME --allow-vnet-access

#Create the azure firewall public ip, the azure firewall itself 
az extension add --name azure-firewall
az network public-ip create -g $VNET_GROUP -n $DEPLOYMENT_NAME --sku Standard
az network firewall create --name $DEPLOYMENT_NAME --resource-group $VNET_GROUP --location $LOCATION
az network firewall ip-config create --firewall-name $DEPLOYMENT_NAME --name $DEPLOYMENT_NAME --public-ip-address $DEPLOYMENT_NAME --resource-group $VNET_GROUP --vnet-name $HUB_VNET_NAME
$FW_PRIVATE_IP=$(az network firewall show -g $VNET_GROUP -n $DEPLOYMENT_NAME --query "ipConfigurations[0].privateIpAddress" -o tsv)
az monitor log-analytics workspace create --resource-group $VNET_GROUP --workspace-name $DEPLOYMENT_NAME --location $LOCATION


#Create a user defined route which will force all traffic from the AKS subnet to the internal ip of the azure firewall 
#(which is an ip address that we know to be 10.0.0.4, stored in $FW_PRIVATE_IP).
$ ="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$VNET_GROUP/providers/Microsoft.Network/virtualNetworks/$KUBE_VNET_NAME/subnets/$KUBE_AGENT_SUBNET_NAME"
az network route-table create -g $VNET_GROUP --name $DEPLOYMENT_NAME
az network route-table route create --resource-group $VNET_GROUP --name $DEPLOYMENT_NAME --route-table-name $DEPLOYMENT_NAME --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address $FW_PRIVATE_IP --subscription $SUBSCRIPTION_ID
az network vnet subnet update --route-table $DEPLOYMENT_NAME --ids $KUBE_AGENT_SUBNET_ID
az network route-table route list --resource-group $VNET_GROUP --route-table-name $DEPLOYMENT_NAME


#Create the necessary exception rules for the AKS-required network dependencies that will ensure the worker nodes can set their system time, pull ubuntu updates and retrieve the AKS kube-system container images from the Microsoft Container Registry
az network firewall network-rule create --firewall-name $DEPLOYMENT_NAME --collection-name "time" --destination-addresses "*"  --destination-ports 123 --name "allow network" --protocols "UDP" --resource-group $VNET_GROUP --source-addresses "*" --action "Allow" --description "aks node time sync rule" --priority 101
az network firewall network-rule create --firewall-name $DEPLOYMENT_NAME --collection-name "dns" --destination-addresses "*"  --destination-ports 53 --name "allow network" --protocols "UDP" --resource-group $VNET_GROUP --source-addresses "*" --action "Allow" --description "aks node dns rule" --priority 102
az network firewall network-rule create --firewall-name $DEPLOYMENT_NAME --collection-name "servicetags" --destination-addresses "AzureContainerRegistry" "MicrosoftContainerRegistry" "AzureActiveDirectory" "AzureMonitor" --destination-ports "*" --name "allow service tags" --protocols "Any" --resource-group $VNET_GROUP --source-addresses "*" --action "Allow" --description "allow service tags" --priority 110

az network firewall application-rule create --firewall-name $DEPLOYMENT_NAME --resource-group $VNET_GROUP --collection-name 'aksfwar' -n 'fqdn' --source-addresses '*' --protocols 'http=80' 'https=443' --fqdn-tags "AzureKubernetesService" --action allow --priority 101
az network firewall application-rule create  --firewall-name $DEPLOYMENT_NAME --collection-name "osupdates" --name "allow network" --protocols http=80 https=443 --source-addresses "*" --resource-group $VNET_GROUP --action "Allow" --target-fqdns "download.opensuse.org" "security.ubuntu.com" "packages.microsoft.com" "azure.archive.ubuntu.com" "changelogs.ubuntu.com" "snapcraft.io" "api.snapcraft.io" "motd.ubuntu.com"  --priority 102

#Create private link enabled cluster in the AKS subnet. If you create a normal cluster, by default it will attach a public ip to the standard load balancer. 
#In our case we want to prevent this by setting the outboundType to userDefinedRouting in our deployment and configure private cluster with a dedicated service principal.
az identity create --name $KUBE_NAME --resource-group $KUBE_GROUP
$MSI_RESOURCE_ID=$(az identity show -n $KUBE_NAME -g $KUBE_GROUP -o json | jq -r ".id")
$MSI_CLIENT_ID=$(az identity show -n $KUBE_NAME -g $KUBE_GROUP -o json | jq -r ".clientId")
$MSI_RESOURCE_ID= "/subscriptions/2dc9c519-7c91-42b6-a530-8a7d765267f6/resourcegroups/dzpraks1_kube/providers/Microsoft.ManagedIdentity/userAssignedIdentities/dzpraks1"
$MSI_CLIENT_ID="dbeffc72-a8da-456c-a74a-6760f096c938"
az role assignment create --role "Virtual Machine Contributor" --assignee $MSI_CLIENT_ID -g $VNET_GROUP
az aks create --resource-group $KUBE_GROUP --name $KUBE_NAME --load-balancer-sku standard --vm-set-type VirtualMachineScaleSets --enable-private-cluster --network-plugin azure --vnet-subnet-id $KUBE_AGENT_SUBNET_ID --docker-bridge-address 172.17.0.1/16 --dns-service-ip 10.2.0.10 --service-cidr 10.2.0.0/24 --enable-managed-identity --kubernetes-version $KUBE_VERSION --outbound-type userDefinedRouting


NODE_GROUP=$(az aks show --resource-group $KUBE_GROUP --name $KUBE_NAME --query nodeResourceGroup -o tsv)
DNS_ZONE_NAME=$(az network private-dns zone list --resource-group $NODE_GROUP --query "[0].name" -o tsv)
HUB_VNET_ID=$(az network vnet show -g $VNET_GROUP -n $HUB_VNET_NAME --query id -o tsv)
az network private-dns link vnet create --name "hubnetdnsconfig" --registration-enabled false --resource-group $NODE_GROUP --virtual-network $HUB_VNET_ID --zone-name $DNS_ZONE_NAME