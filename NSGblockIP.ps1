# Login to Azure
Connect-AzAccount
#, , 
# Define variables
$ipToBlock = "80.66.76.136/32" 
$ruleName = "Block-80.66.76.136"
$priority = 106

# Get all NSGs in the subscription
$nsgs = Get-AzNetworkSecurityGroup

foreach ($nsg in $nsgs) {
    # Check if the rule already exists
    $existingRule = $nsg.SecurityRules | Where-Object { $_.Name -eq $ruleName }
    if ($existingRule) {
        Write-Output "Rule $ruleName already exists in NSG $($nsg.Name) in Resource Group $($nsg.ResourceGroupName)"
        continue
    }
    
    # Add a new security rule
    Add-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg `
        -Name $ruleName `
        -Description "Block IP $ipToBlock" `
        -Access Deny `
        -Protocol * `
        -Direction Inbound `
        -Priority $priority `
        -SourceAddressPrefix $ipToBlock `
        -SourcePortRange * `
        -DestinationAddressPrefix * `
        -DestinationPortRange *

    # Save the updated NSG
    Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg
    Write-Output "Rule $ruleName added to NSG $($nsg.Name) in Resource Group $($nsg.ResourceGroupName)"
}
