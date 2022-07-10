az login 

#Set Subscription
az account list
az account set --subscription "LefeWareSolutions-Development"


# When you create custom roles, it is important to know all the possible operations from the resource providers. 
# The following example lists the Virtual Machine Operator role definition
az role definition list --name "Virtual Machine Operator"

# The following example creates a custom role named Virtual Machine Operator. 
# This custom role assigns access to all read operations of Microsoft.Compute, Microsoft.Storage, and Microsoft.Network resource providers and assigns access to start, restart, and monitor virtual machines. 
az role definition create --role-definition "C:\Users\joshl\Desktop\Az300\AzureCLI\RBAC\customrole2.json"

#list all the custom roles in the current subscription
az role definition list --output json | jq '.[] | if .roleType == "CustomRole" then {"roleName":.roleName, "roleType":.roleType} else empty end'

#Update or Delete a custom role
az role definition update --role-definition "C:\Users\joshl\Desktop\Az300\AzureCLI\RBAC\customrole2.json"
az role definition delete --name "LWL Custom Role 2"