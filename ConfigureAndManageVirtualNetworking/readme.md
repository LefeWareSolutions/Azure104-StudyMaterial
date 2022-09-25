# Configure and manage virtual networking (25–30%)  

## Implement and manage virtual networking  
An Azure Virtual Network (VNet) is the fundamental building block of any private network in Azure. VNet enables many types of Azure resources, such as Azure VMs, to securely communicate with each other, the internet, and on-premises networks.A VNet is similar to a traditional network that would be operated in any data center, but brings with it additional benefits of Azure's infrastructure such as scale, availability, and isolation.


### Create and configure virtual networks, including peering  
VNet peering enables seamlessly connecting two or more VNets in Azure, appearing as one for connectivity purposes. The traffic between virtual machines in peered VNets uses the Microsoft backbone infrastructure. Like traffic between virtual machines in the same network, traffic is routed through Microsoft's private network only, meaning no public Internet, gateways, or encryption is required.

Azure supports the following types of peering:

- Virtual network peering: Connecting virtual networks within the same Azure region.
- Global virtual network peering: Connecting virtual networks across Azure regions.

Other key points for peering:
- Resources in either virtual network can directly connect with resources in the peered virtual network. 
- The network latency between virtual machines in peered virtual networks in the same region is the same as the latency within a single virtual network. 
- Apply network security groups in either virtual network to block access to other virtual networks or subnets

See ./Networking/Peering for examples

### Configure private and public IP addresses  
Private IP addresses allow communicate between resources in an Azure virtual network and connected networks. A private IP address also enables outbound communication to the Internet using an unpredictable IP address. Services that use a private IP addresses in Azure are as follows:
- Virtual Machine Network Interface
- Internal Load Balncers
- Application Gateway

A Public IP address assigned to an Azure resource enables inbound communication to a virtual machine from the Internet and enables outbound communication from the virtual machine to the Internet using a predictable IP address. Some of the resources you can associate a public IP address resource with:
- Virtual machine network interfaces
- Virtual machine scale sets
- Public Load Balancers
- Virtual Network Gateways (VPN/ER)
- NAT gateways
- Application Gateways
- Azure Firewall
- Bastion Host
- Route Server

### Configure user-defined network routes  
Azure routes outbound traffic from a subnet based on the routes in a subnet's route table. 



Below are the two types of routing:

**System Routes:**
Azure automatically creates a route table for each subnet within an Azure virtual network and adds system default routes to the table.

Each route contains an address prefix and next hop type. When traffic leaving a subnet is sent to an IP address within the address prefix (CIDR Range) of a route, the route that contains the prefix is the route Azure uses

 ![SystemRouteTable](./Images/systemroutetable.png "SystemRouteTable")


 **User Defined Routes:**
These Azure's system routes can be overriden with custom routes, and add more custom routes to route tables. To create a route table in azure, it must be associated to a virtual network subnet, thus combinining it with the system routes. It is possible to specify the following next hop types when creating a user-defined route:
- Virtual appliance: A virtual appliance is a virtual machine that typically runs a network application, such as a firewall. When creating a route with the virtual appliance hop type, a next hop IP address must also be specified.
- Virtual network gateway: For traffic destined for specific address prefixes routed to a virtual network gateway. The virtual network gateway must be created with type VPN
- None: Used when wanting to drop traffic to an address prefix, rather than forwarding the traffic to a destination
- Virtual network: Specify when overriding the default routing within a virtual network
- Internet: Specify when wanting to explicitly route traffic destined to an address prefix to the Internet, or for traffic destined for Azure services with public IP addresses kept within the Azure backbone network.
- Service Tag: Specify a service tag as the address prefix for a user-defined route instead of an explicit IP range

**How Azure Determines Routing:**
When outbound traffic is sent from a subnet, Azure selects a route based on the destination IP address, using the longest prefix match algorithm.One route specifies the 10.0.0.0/24 address prefix, while the other route specifies the 10.0.0.0/16 address prefix. Azure routes traffic destined for 10.0.0.5, to the next hop type specified in the route with the 10.0.0.0/24 address prefix, because 10.0.0.0/24 is a longer prefix than 10.0.0.0/16, even though 10.0.0.5 is within both address prefixes. 


**Creating a User Defined Route in Azure:**
See ConfigureAndManageVirtualNetworking/Networking/UserDefinedRoute/UserDefinedRouteTable.ps1
 ![AzureUserDefinedRoute](./Images/AzureUserDefinedRoute.png "AzureUserDefinedRoute")

### Implement subnets  
All Azure resources deployed into a virtual network are deployed into a subnet within a virtual network.

### Configure Service endpoints on subnets  
Service endpoints allow secure and direct connectivity to specific Azure resources over an optimized route over the Azure backbone network, thus traffic never traverses over the public internet. In other words it allow private IP addresses in a specific subnet to reach the endpoint of an Azure service without needing a public IP address on the VNet

When allowing a subnet to access service endpoints for a service, the subnet must enable those specifc type(s) of services in order to allow egress traffic.

 ![subnetserviceendpoint](./Images/ServiceEndpoints/subnetserviceendpoint.png "subnetserviceendpoint")

On the other end, for the service that has incoming traffic, we must enable only selected networks and add a "Virtual Network Rule" for the VNet which should be allowing traffic from. In other words we are **restricting** traffic from that VNet.

 ![StorageAccountNetworking](./Images/ServiceEndpoints/StorageAccountNetworking.png "StorageAccountNetworking")

For example, on Subnet A, we allow the "Microsoft.Storage" Service Endpoints, allowing the private resources inside the subnet to communicate with storage accounts that reside outside of the private network. For the storage account, we create a network rule, saying only allow traffic from that specific network.

 ![serviceendpoint](./Images/ServiceEndpoints/serviceendpoint.png "serviceendpoint")

Service Endpoints are available for the following services along with the name of the service type to be enabled
- Azure Storage (Microsoft.Storage)
- Azure SQL Database, Azure Synapse Analytics, Azure Database for PostgreSQL, Azure Database for MySQL server, Azure Database for MariaDB(Microsoft.Sql)
- Azure Cosmos DB (Microsoft.AzureCosmosDB)
- Azure Key Vault (Microsoft.KeyVault)
- Azure Service Bus (Microsoft.ServiceBus)
- Azure Event Hubs (Microsoft.EventHub)
- Azure Data Lake Store Gen 1 (Microsoft.AzureActiveDirectory)
- Azure App Service (Microsoft.Web)
- Azure Cognitive Services (Microsoft.CognitiveServices)

### Configure private endpoints  
A private endpoint is a network interface that uses a private IP address from the actual virtual network. This network interface connects privately and securely to a service that's connected by 'Azure Private Link'. By enabling a private endpoint, it is essentially bringing the service into the virtual network.Traffic between the virtual network and the service travels the Microsoft backbone network with exposing the service to the public internet. 

 ![PrivateEndpoint](./Images/PrivateEndpoints/PrivateEndpoint.png "PrivateEndpoint")

Private endpoints provide a privately accessible IP address for the Azure service, but do not necessarily restrict public network access to it. Azure App Service and Azure Functions become inaccessible publicly when they are associated with a private endpoint. **All other Azure services require additional access controls**. 

 ![PrivateEndpointResources](./Images/PrivateEndpoints/PrivateEndpointResources.png "PrivateEndpointResources")

 To connect to an Azure service over private endpoint, separate DNS settings, often configured via private DNS zones, are required. The settings must resolve to the private IP address of the private endpoint. The network interface associated with the private endpoint contains the information that's required to configure your DNS including the private IP address for a private-link resource.

**DNS Group:**
If integrating a private endpoint with a private DNS zone, a private DNS zone group is also created. The DNS zone group is a strong association between the private DNS zone and the private endpoint that helps auto-updating the private DNS zone when there is an update on the private endpoint


### Configure Azure DNS, including custom DNS settings and private or public DNS zones  
The Domain Name System, or DNS, is responsible for translating (or resolving) a service name to an IP address. Azure DNS is a hosting service for domains and provides naming resolution using the Microsoft Azure infrastructure.

**Public DNS:**
Azure DNS provides a globally distributed and high-availability name server infrastructure that you can be used to host, but not purchase a domain. By hosting domains in Azure DNS,  DNS records can be managed with the same credentials, APIs, tools, billing, and support as your other Azure services

**Private DNS:**
Azure Private DNS provides a reliable and secure DNS service for virtual networks. Azure Private DNS manages and resolves domain names in the virtual network without the need to configure a custom DNS solution. By using private DNS zones, custom domain names can be used instead of the Azure-provided names during deployment. Using a custom domain name you tailor your virtual network architecture to best suit your organization's needs and provides easy to remember naming resolution for resources within a virtual network and connected virtual networks. 

**DNS Zones:**
A DNS zone is used to host the DNS records for a particular domain. To host a domain in Azure DNS, a DNS zone for that domain name must be created where each DNS record for that domain is then created inside this DNS zone. For example, the domain 'contoso.com' may contain several DNS records, such as 'mail.contoso.com' (for a mail server) and 'www.contoso.com' (for a web site).
 ![PrivateDNS](./Images/DNS/PrivateDNS.png "PrivateDNS")


- When creating a DNS zone in Azure DNS, the name of the zone must be unique within the resource group, and the zone must not exist already. Otherwise, the operation fails. The same zone name can be reused in a different resource group or a different Azure subscription. 
- To resolve the records of a private DNS zone from your virtual network, the vnet must be linked with the zone. Linked virtual networks have full access and can resolve all DNS records published in the private zone. 
- Enabling autoregistration on a virtual network link allows for  DNS records for VMs in that network to auto register in the private zone
 ![PrivateDNSZone](./Images/DNS/PrivateDNSZone.png "PrivateDNSZone")
 ---
## Secure access to virtual networks  

### Create security rules  
Azure network security groups (NSGs) can filter network traffic between Azure resources in an Azure virtual network. An NSG contains security rules that allow or deny inbound network traffic to, or outbound network traffic from, several types of Azure resources. Each rule allows specifying source and destination, port, and protocol.

- Name:	A unique name within the network security group.
- Priority:	A number between 100 and 4096. Rules are processed in priority order, with lower numbers processed before higher numbers, because lower numbers have higher priority. Once traffic matches a rule, processing stops. 
- Source or destination:	Any, or an individual IP address, CIDR block (eg. 10.0.0.0/24), service tag, or application security group.
- Protocol	TCP, UDP, ICMP, ESP, AH, or Any.
- Direction:	Whether the rule applies to inbound, or outbound traffic.
- Port range:	Specify an individual or range of ports (eg. 80 or 10000-10005). 
- Action:	Allow or deny

 ![NSGrules](./Images/NSG/NSGrules.png "NSGrules")

### Associate a network security group (NSG) to a subnet or network interface  
It is possible to associate zero, or one, network security group to each **VNet subnet** and **network interface**in a virtual machine. The same network security group can be associated to as many subnets and network interfaces as you choose.

The following picture illustrates different scenarios for how network security groups might be deployed to allow network traffic to and from the internet over TCP port 80:

 ![NSGApply](./Images/NSG/NSGApply.png "NSGApply")

Inbound Rules:
- VM1: The security rules in NSG1 are processed first, since it's associated to Subnet1 and VM1 is in Subnet1. Unless a rule has been created that allows port 80 inbound, the traffic is denied by the default DenyAllInbound default security rule, and never evaluated by NSG2, since NSG2 is associated to the network interface. If NSG1 has a security rule that allows port 80, the traffic is then processed by NSG2 associated to NIC1. To allow port 80 to the virtual machine, both NSG1 and NSG2 must have a rule that allows port 80 from the internet.

- VM2: The rules in NSG1 are processed because VM2 is also in Subnet1. Since VM2 doesn't have a network security group associated to its network interface, it receives all traffic allowed through NSG1 or is denied all traffic denied by NSG1. 

Outbound Rules:
- VM1: The security rules in NSG2 are processed first. Unless a security rule that denies port 80 outbound to the internet was created, the traffic is allowed by the AllowInternetOutbound default security rule in both NSG1 and NSG2. If NSG2 has a security rule that denies port 80, the traffic is denied, and never evaluated by NSG1. To deny port 80 from the virtual machine, either, or both of the network security groups must have a rule that denies port 80 to the internet.

- VM2: All traffic is sent through the network interface to the subnet, since the network interface attached to VM2 doesn't have a network security group associated to it. The rules in NSG1 are processed.

Intra-Subnet Traffic
-  If a rule is added to *NSG1 that denies all inbound and outbound traffic, VM1 and VM2 will no longer be able to communicate with each other.

### Implement Azure Firewall 
Microsoft’s Azure Firewall is a cloud-native security solution for Azure environments. It provides traffic inspection, filtering, and monitoring. Azure Firewall denies all traffic by default, until rules are manually configured to allow traffic.

Unlike an NSG, which is more targeted and is deployed to particular subnets and/or network interfaces, an Azure Firewall monitors traffic more broadly. Applying rules based on IP addresses, port numbers, networks, and subnets is possible with both firewall and NSG. Additionally, NSGs do not offer a threat-intelligence-based filtering option, but Azure Firewall does.

 ![firewall-standard](./Images/Firewall/firewall-standard.png "firewall-standard")

Ountbound Firewall Policies:
- Application rules:  Define fully qualified domain names (FQDNs) that can be outbound accessed from a subnet.
 ![applicationrules](./Images/Firewall/applicationrules.png "applicationrules")

- Network rules: that define source address, protocol, destination port, and destination address.
 ![networkRules](./Images/Firewall/networkRules.png "networkRules")
Network traffic is subjected to the configured firewall rules when network traffic is routed to the firewall as the subnet's default gateway.

All outbound virtual network traffic IP addresses are translated to the Azure Firewall public IP (Source Network Address Translation). 

Inbound Firewall Policies:
- Inbound DNAT: Inbound Internet network traffic to your firewall public IP address is translated (Destination Network Address Translation) and filtered to the private IP addresses on your virtual networks.
![dnatrules](./Images/Firewall/dnatrules.png "dnatrules")

### implement Azure Bastion  

 

## Configure load balancing  

### configure Azure Application Gateway 

### configure an internal or public load balancer  

### troubleshoot load balancing  

 

## Monitor and troubleshoot virtual networking  

### monitor on-premises connectivity  

### configure and use Azure Monitor for Networks  

### use Azure Network Watcher  

### troubleshoot external networking 

### troubleshoot virtual network connectivity  

 

## Integrate an on-premises network with an Azure virtual network  

### create and configure Azure VPN Gateway 

### create and configure Azure ExpressRoute  

### configure Azure Virtual WAN Monitor and back up  