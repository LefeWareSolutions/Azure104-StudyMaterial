# Secure storage 
The Azure Storage platform is Microsoft's cloud storage solution for modern data storage scenarios. Core storage services offer a massively scalable object store for data objects (Blob Storage), disk storage for Azure virtual machines (VMs), a file system service for the cloud (File storage), a messaging store for reliable messaging (queue storage), and a NoSQL store (table storage)

## Configure Azure Storage firewalls and virtual networks
Azure storage accounts need to be globally unique because each account is bound to an Azure Resource Manager API endpoint:
- http://<storage account name>.<service type name>.core.windows.net/<service container>
Access to any Azure storage account is prohibited by default. Access is given by role-based access control (RBAC) in Azure.

For additional control over storage accounts, we can also limit access to storage account to requests originating from specified IP addresses, IP ranges or from a list of subnets in an Azure VNet. An application that accesses a storage account when network rules are in effect still requires proper authorization for the request.

### Service Endpoint
When a service endpoint for Azure Storage is enabled  in the context of a subnet virtual network, traffic from that subnet to the Azure storage service always traverses over the Microsoft Azure backbone network, irrespective of the source or destination. This eliminates the need to expose the Azure service to the public internet.

 ![ServiceEndpointStorage](./Images/SecureStorage/ServiceEndpointStorage.png "ServiceEndpointStorage")  

To set up an Azure Storage account inside a VNet:
1.	Navigate to the storage account and select “Firewalls and Virtual Network Settings” blade.
2.	To secure the storage account, configure the rule to deny access to traffic from all networks (including internet traffic) on the public endpoint, by default. This can be done by selecting “Selected Networks” radio button
3.	Click “Add existing virtual network” and chose the VNet and Subnet for which you wish to limit access to the storage account.
4.	This will automatically create a “Service Endpoint” on the VNet
5.	It is also possible to add Ip Address/Ranges from other clients outside the VNet.
*In the firewalls and virtual network tab there is also an option called “Allow trusted Microsoft services to access this storage account” which is turned on by default. This allows connectivity to Azure Monitor Backups and Event Hubs.

 ![StorageNetwork](./Images/SecureStorage/StorageNetwork.png "StorageNetwork")  
 ![SubnetServiceEndpoint](./Images/SecureStorage/SubnetServiceEndpoint.png "SubnetServiceEndpoint")  


### Private Endpoint
Even if using firewall rules, storage accounts will still have a **public endpoint that is accessible through the internet**. You can instead create Private Endpoints for your storage account, which assigns a private IP address from your VNet to the storage account, and secures all traffic between your VNet and the storage account over a private link.
 ![StoragePrivateEndpoint](./Images/SecureStorage/StoragePrivateEndpoint.jpg "StoragePrivateEndpoint")  


## Generate shared access signature (SAS) tokens
A Shared Access Signature (SAS) represents a way to grant limited, time bound access to individual storage account objects. Azure Storage supports three types of shared access signatures:
- User Delegation SAS: Secured with Azure AD credentials instead of the master key and also by the permissions specified for the SAS. A user delegation SAS applies to Blob storage only.
- Account SAS: An account SAS is secured with the storage account key. An account SAS delegates access to resources in one or more of the storage services
- Service SAS: Secured with the storage account key. A service SAS delegates access to a resource in only one of the Azure Storage services: Blob storage, Queue storage, Table storage, or Azure Files.
A SAS is essentially a URL that consists of the following components:
- Protocol: HTTP or HTTPS
- Address: Fully qualified address to the storage account
- Permissions: CRUD operations 
- Time Interval: As long as the time interval has not expired, anyone on earth can use the SAS URI.
- Digital Signature

To Create a SAS:
1.	In storage explorer, browse to the assets container and locate the container or file you with to create the SAS for
2.	Right click an object and select “Get Shared Access Signature” from the menu: 
3.	Complete all SAS dialog boxes; add start & end times and permissions (CRUD): 
The resulting URL will look like the following where sig represents a digital signature:
https://lwcmedia.blob.core.windows.net/insights-logs-applicationgatewayaccesslog?sv=2019-10-10&st=2020-10-13T00%3A29%3A07Z&se=2020-10-13T00%3A30%3A00Z&sr=c&sp=rl&sig=QxC20mJ425bF2kV4UTz2fIu7PbMnjj1GAysUygtj3Jg%3D

# Manage access keys
Azure generates two 512-bit storage account access keys to authorize access to data in a storage account via Shared Key authorization. It is recommended to use Azure Key Vault to manage and rotate access keys and also so that application can securely access keys in Key Vault, thus avoiding storing them within application code. 

 
You can view and copy your account access keys with the Azure portal, PowerShell, or Azure CLI: 
 


Configure Azure AD authentication for a storage account 
Each time data is accessed in a storage account, the client application makes a request over HTTP/HTTPS to Azure Storage that must be authorized to ensure appropriate permissions to access data in the account.
Azure Storage supports using Azure Active Directory (Azure AD) to authorize requests to blob data. With Azure AD, Azure RBAC can be used to grant permissions to a security principal, which may be a user, group, or application service principal. The security principal is authenticated by Azure AD to return an OAuth 2.0 token. The token can then be used to authorize a request against the Blob service. Authorizing requests against Azure Storage with Azure AD provides superior security and ease of use over Shared Key authorization
Azure RBAC provides a number of built-in roles for authorizing access to blob data using Azure AD and OAuth:
•	Storage Blob Data Owner: Use to set ownership and manage POSIX access control for Azure Data Lake Storage Gen2.
•	Storage Blob Data Contributor: Use to grant read/write/delete permissions to Blob storage resources.
•	Storage Blob Data Reader: Use to grant read-only permissions to Blob storage resources.
•	Storage Blob Delegator: Get a user delegation key to use to create a shared access signature that is signed with Azure AD credentials for a container or blob.
Built-in roles such as Owner, Contributor, and Storage Account Contributor permit a security principal to manage a storage account, but do not provide access to the blob or queue data within that account via Azure AD. However, if a role includes the Microsoft.Storage/storageAccounts/listKeys/action, then a user to whom that role is assigned can access data in the storage account via Shared Key authorization with the account access keys.

Configure access to Azure Files 
Azure Files supports identity-based authentication over Server Message Block (SMB) through two types of Domain Services: on-premises Active Directory Domain Services (AD DS) and Azure Active Directory Domain Services (Azure AD DS).
 
Neither identity-based authentication method is supported with Network File System (NFS) shares

