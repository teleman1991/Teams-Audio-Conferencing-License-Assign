# Teams Enterprise License Assignment Script

This PowerShell script automates the process of assigning Teams Enterprise licenses to Microsoft 365 users.

## Prerequisites

- PowerShell 5.1 or higher
- Microsoft Graph PowerShell SDK
- Appropriate Microsoft 365 administrative permissions

### Required PowerShell Modules

```powershell
Install-Module Microsoft.Graph.Users
Install-Module Microsoft.Graph.Users.Actions
```

## Features

- Assigns Teams Enterprise licenses to individual users
- Checks for license availability before assignment
- Verifies successful license assignment
- Provides detailed progress and status information
- Handles errors gracefully

## Usage

1. Clone this repository:
   ```powershell
   git clone https://github.com/teleman1991/Teams-Audio-Conferencing-License-Assign.git
   ```

2. Navigate to the script directory:
   ```powershell
   cd Teams-Audio-Conferencing-License-Assign
   ```

3. Run the script for a single user:
   ```powershell
   .\Assign-TeamsEnterpriseLicense.ps1 -UserPrincipalName "user@yourdomain.com"
   ```

4. When prompted, authenticate with your Microsoft 365 administrative credentials.

## Important Notes

- The script uses the Teams Enterprise SKU ID: 7e31c0d9-9551-471d-836f-32ee72be4a01
- Ensure you have sufficient licenses available
- Test the script in a non-production environment first
- There may be a delay (up to 30 minutes) before the license appears in the Microsoft 365 Admin Portal
- The script verifies the license assignment through PowerShell, which shows real-time data

## Verification

To verify license assignment manually, you can use:
```powershell
Get-MgUser -UserId "user@domain.com" -Property AssignedLicenses | Select-Object -ExpandProperty AssignedLicenses
```

## License

MIT License