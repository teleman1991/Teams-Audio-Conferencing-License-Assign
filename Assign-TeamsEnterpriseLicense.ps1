<#
.SYNOPSIS
    Assigns Microsoft Teams Enterprise licenses to users without sending notification emails.
.DESCRIPTION
    This script connects to Microsoft 365, assigns Teams Enterprise licenses to specified users,
    and prevents the automatic sending of notification emails.
.NOTES
    Required Modules: Microsoft.Graph.Users, Microsoft.Graph.Users.Actions
#>

# Connect to Microsoft Graph (Make sure you have the necessary permissions)
Connect-MgGraph -Scopes "User.ReadWrite.All", "Organization.Read.All"

# Define the license SKU for Teams Enterprise
$TeamsEnterpriseSku = "6fd2c87f-b296-42f0-b197-1e91e994b900" # Teams Enterprise SKU ID

# Get all users without the Teams Enterprise license
$Users = Get-MgUser -All | Where-Object {
    $_.AssignedLicenses.SkuId -notcontains $TeamsEnterpriseSku
}

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

# Process each user
foreach ($User in $Users) {
    try {
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
        Update-MgUser -UserId $User.Id -BodyParameter $notificationParams

        # Assign the license
        Set-MgUserLicense -UserId $User.Id -BodyParameter $LicenseParams

        Write-Host "Successfully assigned Teams Enterprise license to $($User.UserPrincipalName)" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to assign license to $($User.UserPrincipalName): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph