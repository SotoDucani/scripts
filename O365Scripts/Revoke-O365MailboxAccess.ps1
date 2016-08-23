<#
.SYNOPSIS
	Removes Admin full access to all user mailboxes. You do not need to start a O365 session before running this script.
#>

$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

$Name = Read-Host "Input username of person who's full mailbox access is being revoked: "

Get-Mailbox -ResultSize Unlimited -Filter {(RecipientTypeDetails -eq "UserMailbox") -and (Alias -ne $Name)} | Remove-MailboxPermission -User $Name -AccessRights FullAccess -InheritanceType all

Remove-PSSession $Session
