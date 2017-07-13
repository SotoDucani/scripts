<#
.SYNOPSIS
	Starts an O365 Session. Credential must be an admin and be in the username@comapnydomain.com format
#>

$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
