$subscriptionName = 'LefeWareSolutions-POC'
$location = "eastus"
$resourceGroupName = "Azure104"

# Login to Azure
Connect-AzAccount

# Select your subscription
Select-AzSubscription -Subscription $subscriptionName

# Define a policy
$policy = New-AzPolicyDefinition -Name 'audit-vm-tag' -Policy '{
    "if": {
        "allOf": [
            {
                "field": "type",
                "equals": "Microsoft.Compute/virtualMachines"
            },
            {
                "field": "tags[\'Test\']",
                "exists": "false"
            }
        ]
    },
    "then": {
        "effect": "audit"
    }
}'

# Define a policy set (initiative)
New-AzPolicySetDefinition -Name 'audit-tag-policyset' -PolicyDefinition $policy

