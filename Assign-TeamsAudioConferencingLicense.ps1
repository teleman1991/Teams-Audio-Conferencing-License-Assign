<#
.SYNOPSIS
    Assigns Teams Audio Conferencing licenses to users without sending notification emails.
.DESCRIPTION
    This script connects to Microsoft 365, assigns Teams Audio Conferencing licenses to specified users,
    and prevents the automatic sending of notification emails.
.NOTES
    Required Modules: Microsoft.Graph.Users, Microsoft.Graph.Users.Actions
#>

# Connect to Microsoft Graph (Make sure you have the necessary permissions)
Connect-MgGraph -Scopes "User.ReadWrite.All", "Organization.Read.All"

# Define the license SKU for Teams Audio Conferencing
$TeamsAudioConferencingSkuId = "c7df2760-2c81-4ef7-b578-5b5392b571df" # Update this with your actual SKU ID

# Get all users without the Teams Audio Conferencing license
$Users = Get-MgUser -All | Where-Object {
    $_.AssignedLicenses.SkuId -notcontains $TeamsAudioConferencingSkuId
}

# Create license assignment parameters
$LicenseParams = @{
    addLicenses = @(
        @{
            skuId = $TeamsAudioConferencingSkuId
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

        Write-Host "Successfully assigned license to $($User.UserPrincipalName)" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to assign license to $($User.UserPrincipalName): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph
