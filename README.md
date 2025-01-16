# Teams Enterprise License Assignment Script

This PowerShell script automates the process of assigning Teams Enterprise licenses to Microsoft 365 users while preventing automatic notification emails.

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

- Bulk assigns Teams Enterprise licenses
- Disables automatic email notifications for license assignments
- Provides detailed success/failure logging
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

3. Run the script:
   ```powershell
   .\Assign-TeamsEnterpriseLicense.ps1
   ```

4. When prompted, authenticate with your Microsoft 365 administrative credentials.

## Important Notes

- The script uses the Teams Enterprise SKU ID: 6fd2c87f-b296-42f0-b197-1e91e994b900
- Ensure you have sufficient licenses available
- Test the script in a non-production environment first

## License

MIT License