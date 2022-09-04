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
### Implement subnets  

### Configure endpoints on subnets  

### configure private endpoints  

### configure Azure DNS, including custom DNS settings and private or public DNS zones  

 ---
## Secure access to virtual networks  

### create security rules  

### associate a network security group (NSG) to a subnet or network interface  

### evaluate effective security rules  

### implement Azure Firewall 

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