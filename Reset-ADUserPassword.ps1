<#
.SYNOPSIS
	Unlock and reset Active Directory accounts and passwords.
.DESCRIPTION
	This script will unlock and reset an Active Directory account and password. To do this it checks if the PS AD module is loaded and if the script user has proper credentials. If AD is not loaded, then it will load it.
.NOTES
	Filename : Reset-ADUserPassword.ps1
	Author : Joshua Herrmann
	Date : 1/7/2015
	Pre-Reqs : Powershell 3.0
			   AD Module available
			   Valid credentials for AD management
#>

# Check if AD Module is loaded. If not, then load it
if (-not (Get-Module ActiveDirectory)) {
	Try {
		Import-Module ActiveDirectory -ErrorAction Stop
	} Catch {
		Write-Host "There was an error loading the ActiveDirectory Module. Do you have it installed on this workstation?"
	}
}

# Get target username
$TargetUser = Read-Host "What user would you like to reset?"
$NewPass = Read-Host -AsSecureString "Input the new password for the user"

# Get Admin credentials
$AdminCred = Get-Credential -Message "AD Management Credentials"

# Reset and unlock process
Try {
	Unlock-ADAccount -Identity $TargetUser -Credential $AdminCred
	Set-ADUser -Identity $TargetUser -Credential $AdminCred -PasswordNeverExpires $false -ChangePasswordAtLogon $true
	Set-ADAccountPassword -Identity $TargetUser -Credential $AdminCred -Reset -NewPassword $NewPass
	Write-Host "--------------------------------------------"
	Write-Host "The reset is complete. The user will be forced to change their password at next logon."
	Write-Host "Once they change their password, remember to set password never expires."
} Catch {
	$ErrorMessage = $_.Exception.Message
	Write-Host "Something broke during the password reset process. The error message is below:"
	Write-Host $ErrorMessage
}