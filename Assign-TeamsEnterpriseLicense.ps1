# Define the license SKUs
$TeamsEnterpriseSku = "7e31c0d9-9551-471d-836f-32ee72be4a01" # Teams Enterprise
$E3Sku = "05e9a617-0261-4cee-bb44-138d3ef5d965" # E3 License

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All", "Organization.Read.All"

try {
    # Check available Teams Enterprise licenses
    $availableLicenses = Get-MgSubscribedSku | Where-Object { $_.SkuId -eq $TeamsEnterpriseSku }
    if ($null -eq $availableLicenses) {
        throw "Teams Enterprise SKU not found in tenant."
    }

    $availableCount = $availableLicenses.PrepaidUnits.Enabled - $availableLicenses.ConsumedUnits
    Write-Host "Available Teams Enterprise licenses: $availableCount" -ForegroundColor Cyan

    if ($availableCount -lt 1) {
        throw "No available Teams Enterprise licenses."
    }

    # Get all users with E3 license
    Write-Host "Finding users with E3 licenses..." -ForegroundColor Cyan
    $E3Users = Get-MgUser -All -Property Id, UserPrincipalName, AssignedLicenses | 
               Where-Object { $_.AssignedLicenses.SkuId -contains $E3Sku }

    Write-Host "Found $($E3Users.Count) users with E3 licenses" -ForegroundColor Cyan

    foreach ($User in $E3Users) {
        Write-Host "\nProcessing user: $($User.UserPrincipalName)" -ForegroundColor Cyan

        if ($User.AssignedLicenses.SkuId -contains $TeamsEnterpriseSku) {
            Write-Host "User already has Teams Enterprise license." -ForegroundColor Yellow
            continue
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
        
        # Create license assignment parameters
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

        # Verify the license was assigned
        Start-Sleep -Seconds 2
        $updatedUser = Get-MgUser -UserId $User.Id -Property AssignedLicenses
        
        if ($updatedUser.AssignedLicenses.SkuId -contains $TeamsEnterpriseSku) {
            Write-Host "Successfully verified license assignment" -ForegroundColor Green
        } else {
            Write-Host "Warning: License assignment could not be verified" -ForegroundColor Yellow
        }
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Disconnect-MgGraph
    Write-Host "\nDisconnected from Microsoft Graph" -ForegroundColor Cyan
}