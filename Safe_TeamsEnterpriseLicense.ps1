param([Parameter(Mandatory=$true)][string]$UserPrincipalName)

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All", "Organization.Read.All"

# Define the license SKU for Teams Enterprise
$TeamsEnterpriseSku = "6fd2c87f-b296-42f0-b197-1e91e994b900"
