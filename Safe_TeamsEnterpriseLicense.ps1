param([Parameter(Mandatory=$true)][string]$UserPrincipalName)

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All", "Organization.Read.All"

# Define the license SKU for Teams Enterprise
$TeamsEnterpriseSku = "6fd2c87f-b296-42f0-b197-1e91e994b900"

try {
    Write-Host "Processing user: $UserPrincipalName" -ForegroundColor Cyan
    
    # Get user
    $User = Get-MgUser -Filter "userPrincipalName eq '$UserPrincipalName'"
    
    if ($null -eq $User) {
        throw "User not found: $UserPrincipalName"
    }

    if ($User.AssignedLicenses.SkuId -contains $TeamsEnterpriseSku) {
        Write-Host "User already has Teams Enterprise license." -ForegroundColor Yellow
        exit
    }

    # Disable email notifications
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
    
    Write-Host "Disabling notifications..." -ForegroundColor Gray
    Update-MgUser -UserId $User.Id -BodyParameter $notificationParams

    # Assign license
    $LicenseParams = @{
        addLicenses = @(
            @{
                skuId = $TeamsEnterpriseSku
                disabledPlans = @()
            }
        )
        removeLicenses = @()
    }

    Write-Host "Assigning Teams Enterprise license..." -ForegroundColor Gray
    Set-MgUserLicense -UserId $User.Id -BodyParameter $LicenseParams

    Write-Host "Successfully assigned license to $UserPrincipalName" -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Disconnect-MgGraph
    Write-Host "Disconnected from Microsoft Graph" -ForegroundColor Cyan
}