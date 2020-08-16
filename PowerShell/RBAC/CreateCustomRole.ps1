$subscriptionName = 'LefeWare-Learning-Development'
$location = "eastus"
$resourceGroupName = "Azure300"


Connect-AzAccount

# Set Current Subscription Context
$context = Get-AzSubscription -SubscriptionName $subscriptionName
Set-AzContext $context

# When you create custom roles, it is important to know all the possible operations from the resource providers. 
# You can use the Get-AzProviderOperation command to get this information
Get-AzProviderOperation "Microsoft.Compute/virtualMachines/*" | FT OperationName, Operation, Description -AutoSize


# You can use one of the built-in roles as a starting point or you can start from scratch. 
# The following example starts with the Virtual Machine Contributor built-in role to create a custom role named Virtual Machine Operator. 
# The new role grants access to all read operations of Microsoft.Compute, Microsoft.Storage, and Microsoft.Network resource providers and grants access to start, restart, and monitor virtual machines. 
# The custom role can be used in two subscriptions.
$role = Get-AzRoleDefinition "Virtual Machine Contributor"
$role.Id = $null
$role.Name = "LWL Virtual Machine Operator"
$role.Description = "Can monitor and restart virtual machines."
$role.Actions.Clear()
$role.Actions.Add("Microsoft.Storage/*/read")
$role.Actions.Add("Microsoft.Network/*/read")
$role.Actions.Add("Microsoft.Compute/*/read")
$role.Actions.Add("Microsoft.Compute/virtualMachines/start/action")
$role.Actions.Add("Microsoft.Compute/virtualMachines/restart/action")
$role.Actions.Add("Microsoft.Authorization/*/read")
$role.Actions.Add("Microsoft.ResourceHealth/availabilityStatuses/read")
$role.Actions.Add("Microsoft.Resources/subscriptions/resourceGroups/read")
$role.Actions.Add("Microsoft.Insights/alertRules/*")
$role.Actions.Add("Microsoft.Support/*")
$role.AssignableScopes.Clear()
$role.AssignableScopes.Add("/subscriptions/a2282e1d-5b4d-4e61-92e7-c4db90641c71")
New-AzRoleDefinition -Role $role


#Create a custom Role from JSON
New-AzRoleDefinition -InputFile "C:\Users\joshl\Desktop\Az300\PowerShell\RBAC\customrole1.json"

#List custom roles
Get-AzRoleDefinition | FT Name, IsCustom

#Update an existing role
$role = Get-AzRoleDefinition "LWL Virtual Machine Operator"
$role.Actions.Add("Microsoft.Insights/diagnosticSettings/*")
Set-AzRoleDefinition -Role $role

#Delete an existing role
Get-AzRoleDefinition "LWL Virtual Machine Operator" | Remove-AzRoleDefinition