# Manage storage

## Create and configure storage accounts 
An Azure storage account contains all Azure Storage data objects: blobs, files, queues, tables, and disks. The storage account provides a unique namespace for your Azure Storage data that is accessible from anywhere in the world over HTTP or HTTPS. A storage account name must be: 
-	All lower case, 
-	3-24 chars 
-	Contain only alphanumeric characters
-	Be globally unique

Azure Storage offers several types of storage accounts. Each type supports different features and has its own pricing model. The types of storage accounts are:
-	General-purpose v2 accounts: Basic storage account type for blobs, files, queues, and tables. Recommended for most scenarios using Azure Storage.
-	General-purpose v1 accounts: Legacy account type for blobs, files, queues, and tables.
-	BlockBlobStorage accounts: Storage accounts with premium performance characteristics for block blobs and append blobs. Recommended for scenarios with high transaction rates, or scenarios that use smaller objects or require consistently low storage latency.
-	FileStorage accounts: Files-only storage accounts with premium performance characteristics. Recommended for enterprise or high performance scale applications.
-	BlobStorage accounts: Legacy Blob-only storage accounts. Use general-purpose v2 accounts instead when possible.
For storage accounts, Microsoft charges for both amount of data stored in the account and outbound (egress) data transfer for every REST API transaction.

## Import/Export from Azure job 
Azure Import service is used to securely import large amounts of data to Azure Blob storage and Azure Files by shipping disk drives to an Azure datacenter. 
Azure Export service can also be used to transfer data from Azure Blob storage to disk drives and ship to your on-premises sites. 
Supply your own disk drives and transfer data with the Azure Import/Export service. You can also use disk drives supplied by Microsoft. If you want to transfer data using disk drives supplied by Microsoft, you can use Azure Data Box Disk to import data into Azure. Microsoft ships up to 5 encrypted solid-state disk drives (SSDs) with a 40 TB total capacity.
The import/export processes can be created from within the Azure portal.

Install and use Azure Storage Explorer 
Microsoft Azure Storage Explorer is a standalone app that makes it easy to work with Azure Storage data on Windows, macOS, and Linux.
Storage Explorer provides several ways to connect to Azure resources:
•	Sign in to Azure to access your subscriptions and their resources
•	Attach to an individual Azure Storage resource – Through Account Name and Key or Shared Access Signature (SAS)
Copy data by using AZCopy 
AzCopy is a command-line utility that you can use to copy blobs or files to or from a storage account. This article helps you download AzCopy, connect to your storage account, and then transfer files.
You can provide authorization credentials by using Azure Active Directory (AD), or by using a Shared Access Signature (SAS) token.
Example command:
azcopy copy 'C:\myDirectory\myTextFile.txt' 'https://mystorageaccount.blob.core.windows.net/mycontainer/myTextFile.txt'

Implement Azure Storage replication 
Azure Storage stores multiple copies of data so that it is protected from planned and unplanned events, including transient hardware failures, network/power outages, and massive natural disasters. Redundancy ensures that storage accounts meet the Service-Level Agreement (SLA) for Azure Storage even in the face of failures.
  
Redundancy in the primary region:
Data in an Azure Storage account is always replicated three times in the primary region using one of the following options:
•	Locally redundant storage (LRS) copies your data synchronously three times within a single physical location in the primary region (not recommended for apps requiring HA) otherwise referred to as an Availability Set . LRS protects your data against server rack and drive failures. However, if a disaster such as fire or flooding occurs within the data center, all replicas of a storage account using LRS may be lost or unrecoverable
•	Zone-redundant storage (ZRS) copies your data synchronously across three Azure availability zones in the primary region. For HA use ZRS in the primary region, and also replicate to a secondary region.
Redundancy in a secondary region:
For apps requiring HA, it is possible to copy the data in your storage account to a secondary region. If your storage account is copied to a secondary region, then your data is durable even in the case of a complete regional outage or a disaster in which the primary region isn't recoverable. When you create a storage account, you select the primary region for the account, the paired secondary region is determined based on the primary region, and can't be changed. Azure Storage offers two options for copying your data to a secondary region:

Geo-redundant storage (GRS) copies your data synchronously three times within a single physical location in the primary region using LRS. It then copies your data asynchronously to a single physical location in the secondary region.
Geo-zone-redundant storage (GZRS) copies your data synchronously across three Azure availability zones in the primary region using ZRS. It then copies your data asynchronously to a single physical location in the secondary region.

With GRS or GZRS, the data in the secondary region isn't available for read or write access unless there is a failover to the secondary region. For read access to the secondary region, configure your storage account to use read-access geo-redundant storage (RA-GRS) or read-access geo-zone-redundant storage (RA-GZRS)
 

Configure blob object replication 
Object replication asynchronously copies block blobs between a source storage account and a destination account. The following diagram shows how object replication replicates block blobs from a source storage account in one region to destination accounts in two different regions.
  
Object replication requires that the following Azure Storage features are also enabled:
1.	 Change feed: Must be enabled on the source account.
2.	Blob versioning: Must be enabled on both the source and destination accounts. 
Configure Azure files and Azure Blob Storage 
Create an Azure file share 
Azure Files offers fully managed file shares in the cloud that are accessible via the industry standard Server Message Block (SMB) protocol or network file sharing (NFS) protocol. Azure Files file shares can be mounted concurrently by cloud or on-premises Windows, Linux or MacOS clients and docker containers
•	Can be hosted on hard disk-based (HDD-based) hardware, or premium file shares, which are hosted on solid-state disk-based (SSD-based) hardware.
•	Standard file shares offer locally-redundant (LRS), zone redundant (ZRS), geo-redundant (GRS), or geo-zone-redundant (GZRS) storage. 
•	Premium file shares are available with locally redundancy and zone redundancy in a subset of regions but not geo-redundancy.
•	In local and zone redundant storage accounts, Azure file shares can span up to 100 TiB, however in geo- and geo-zone redundant storage accounts, Azure file shares can span only up to 5 TiB.
 
 

Create and configure Azure File Sync service 
Azure File Sync enables centralizing your organization's file shares in Azure Files. With cloud tiering enabled, frequently accessed files are cached on the local server and the least frequently accessed files are tiered to the cloud. 
Azure file sync allows control of how much local disk space is used for caching. Tiered files can quickly be recalled on-demand, enabling cutting down on costs as only a fraction of data is stored on-premises.

Configure Azure Blob Storage 
Azure Binary Large OBject  storage is optimized for storing massive amounts of unstructured data. Unstructured data is data that doesn't adhere to a particular data model or definition, such as text(logs) or binary data (images). 

Configure storage tiers 
To manage costs of expanding storage needs, data can be organized based on how frequently it will be accessed and how long it will be retained. Azure storage offers different access tiers:
•	If blob data is accessed frequently, set the blob storage to hot tier as this will give a discount on transaction costs. 
•	If data is accessed infrequently, set the blob storage to cold storage and Microsoft will give a discount on data storage. 
•	Data can also be set to “Archive”. This is for data that is only ever accessed on rare occasions. In order to access the data, you must “rehydrate” the archived blob and are charged to do so.
Storage accounts have a default access tier setting that indicates the online tier in which a new blob is created. The default access tier setting can be set to either Hot or Cool. Users can override the default setting for an individual blob when uploading the blob or changing its tier.
 
The default access tier for a new general-purpose v2 storage account is set to the Hot tier by default.

Configure blob lifecycle management 
Data sets have unique lifecycles in that some people access some data often, some data sets expire days or months after creation, while other data sets are actively read and modified throughout their lifetimes. Azure Storage lifecycle management offers a rule-based policy that can be used to transition blob data to the appropriate access tiers or to expire data at the end of the data lifecycle using a lifecycle management policy:
•	 Transition blobs from cool to hot immediately when they are accessed, to optimize performance.
•	Transition current versions of a blob, previous versions of a blob, or blob snapshots to a cooler storage tier if these objects have not been accessed or modified for a period of time, to optimize cost. 
•	Delete current versions of a blob, previous versions of a blob, or blob snapshots at the end of their lifecycles.
•	Define rules to be run once per day at the storage account level.
•	Apply rules to containers or to a subset of blobs, using name prefixes or blob index tags as filters.
A lifecycle management policy is a collection of rules in a JSON document. The following sample JSON shows a complete rule definition made up actions and filters with the following policies:
•	Tier blob to cool tier 30 days after last modification
•	Tier blob to archive tier 90 days after last modification
•	Delete blob 2,555 days (seven years) after last modification
•	Delete previous versions 90 days after creation
 
A lifecycle management policy can be added, edited, or removed with the Azure portal, PowerShell, Azure CLI.
 
 

