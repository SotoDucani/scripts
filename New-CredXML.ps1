<#
.SYNOPSIS
  Creates a new clixml file of a credential provided and saves it to a specified path
.NOTES
  File NameL New-CredXML.ps1
  Author: Joshua Herrmann
  Written for: Powershell 3.0
  Version: 1.0
#>

# Get the Credential Object
$Cred = Get-Credential

# Export the Credential as a clixml to the specified path
Export-Clixml -InputObject $Cred -Path '\\XXXXXXXXXX\IT Admin\Credential XMLs\NEWCRED.clixml'
