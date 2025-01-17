param([Parameter(Mandatory=$true)][string]$UserPrincipalName)

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All", "Organization.Read.All"

# Define the license SKU for Teams Enterprise
$TeamsEnterpriseSku = "7e31c0d9-9551-471d-836f-32ee72be4a01" # Teams Enterprise SKU ID

try {
    Write-Host "Processing user: $UserPrincipalName" -ForegroundColor Cyan
    
    # Get user
    $User = Get-MgUser -Filter "userPrincipalName eq '$UserPrincipalName'" -Property Id, UserPrincipalName, AssignedLicenses
    
    if ($null -eq $User) {
        throw "User not found: $UserPrincipalName"
    }

    # Check available licenses
    $availableLicenses = Get-MgSubscribedSku | Where-Object { $_.SkuId -eq $TeamsEnterpriseSku }
    if ($null -eq $availableLicenses) {
        throw "License SKU not found in tenant. Please verify the SKU ID."
    }

    $availableCount = $availableLicenses.PrepaidUnits.Enabled - $availableLicenses.ConsumedUnits
    Write-Host "Available licenses: $availableCount" -ForegroundColor Cyan

    if ($availableCount -lt 1) {
        throw "No available licenses. Please check your license quota."
    }

    if ($User.AssignedLicenses.SkuId -contains $TeamsEnterpriseSku) {
        Write-Host "User already has Teams Enterprise license." -ForegroundColor Yellow
        exit
    }

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
    Start-Sleep -Seconds 5 # Give time for license to propagate
    $updatedUser = Get-MgUser -UserId $User.Id -Property AssignedLicenses
    
    if ($updatedUser.AssignedLicenses.SkuId -contains $TeamsEnterpriseSku) {
        Write-Host "Successfully verified license assignment to $UserPrincipalName" -ForegroundColor Green
    } else {
        Write-Host "Warning: License assignment could not be verified. Please check manually." -ForegroundColor Yellow
        Write-Host "Current licenses:" -ForegroundColor Yellow
        $updatedUser.AssignedLicenses.SkuId | ForEach-Object {
            Write-Host "  $_" -ForegroundColor Yellow
        }
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Full Error Details: $($_)" -ForegroundColor Red
}
finally {
    Disconnect-MgGraph
    Write-Host "Disconnected from Microsoft Graph" -ForegroundColor Cyan
}