<#
.SYNOPSIS
    Assigns Microsoft Teams Enterprise license to a single user without sending notification emails.
.DESCRIPTION
    This script assigns a Teams Enterprise license to a specified user and prevents automatic notification emails.
.PARAMETER UserPrincipalName
    Required. The UserPrincipalName (email) of the user to license.
.EXAMPLE
    .\Safe_TeamsEnterpriseLicense.ps1 -UserPrincipalName "user@contoso.com"
.NOTES
    Required Modules: Microsoft.Graph.Users, Microsoft.Graph.Users.Actions
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$UserPrincipalName
)

# Connect to Microsoft Graph (Make sure you have the necessary permissions)
Connect-MgGraph -Scopes "User.ReadWrite.All", "Organization.Read.All"

# Define the license SKU for Teams Enterprise
$TeamsEnterpriseSku = "6fd2c87f-b296-42f0-b197-1e91e994b900" # Teams Enterprise SKU ID

try {
    Write-Host "Processing user: $UserPrincipalName" -ForegroundColor Cyan
    
    # Get user
    $User = Get-MgUser -Filter "userPrincipalName eq '$UserPrincipalName'"
    
    if ($null -eq $User) {
        throw "User not found: $UserPrincipalName"
    }

    # Check if user already has the license
    if ($User.AssignedLicenses.SkuId -contains $TeamsEnterpriseSku) {
        Write-Host "User already has Teams Enterprise license assigned." -ForegroundColor Yellow
        exit
    }

    # Set user notification settings to disable emails
    $notificationParams = @{
        notificationSettings = @{
            notifications = @(
                @{
                    notificationType = "LicenseAssignment"
                    enabled = $false
                }
            )
        }
    }
    
    # Update user notification settings
    Write-Host "Disabling license assignment notifications..." -ForegroundColor Gray
    Update-MgUser -UserId $User.Id -BodyParameter $notificationParams

    # Create license assignment parameters
    $LicenseParams = @{
        addLicenses = @(
            @{
                skuId = $TeamsEnterpriseSku
                disabledPlans = @() # No disabled plans
            }
        )
        removeLicenses = @()
    }

    # Assign the license
    Write-Host "Assigning Teams Enterprise license..." -ForegroundColor Gray
    Set-MgUserLicense -UserId $User.Id -BodyParameter $LicenseParams

    Write-Host "Successfully assigned Teams Enterprise license to $UserPrincipalName" -ForegroundColor Green
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    # Disconnect from Microsoft Graph
    Disconnect-MgGraph
    Write-Host "Disconnected from Microsoft Graph" -ForegroundColor Cyan
}