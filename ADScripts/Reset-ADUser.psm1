<#
.Synopsis
    Unlock and reset Active Directory accounts and passwords.
.DESCRIPTION
    The Reset-ADUser cmdlet unlocks and resets an AD account password. This is done using the ActiveDirectory PS Module. If this module is not available on the computer running the script, it will fail. 
.EXAMPLE
    PS C:\> Reset-ADUser -Credential Admin -GivenName 'Josh'

    Resets the user with the given name Josh
.EXAMPLE
    PS C:\> Get-ADUser * | Reset-ADUser

    Resets every user that is returned by Get-ADUser.
.INPUTS
    Microsoft.ActiveDirectory.Management.ADUser
    System.Object

    You can pipe a single (ADUser) or multiple ADUser objects (Object) to Reset-ADUser.
.OUTPUTS
    None
#>

function Reset-ADUser
{
	[CmdletBinding()]
	Param
	(
        # AD Management Credentials
        [Parameter(Mandatory=$true)]
        [Credential]$Credential,

		# GivenName search parameter
		[String]$GivenName,
		
		# Name search parameter
		[String]$Name,
		
		# Surname search parameter
		[String]$Surname,
		
		# SamAccountName search parameter
		[String]$SamAccountName,
		
		# ADUser Object
		[Parameter(ValueFromPipeline=$true)]
		[ADUser]$ADUser,
		
		# Set of ADUser Objects
		[Parameter(ValueFromPipeline=$true)]
		[Object]$ADUserSet
	)

    # Check if AD Module is loaded. If not, then load it
    if (-not (Get-Module ActiveDirectory))
    {
	    Try
        {
		    Import-Module ActiveDirectory -ErrorAction Stop
        }
        Catch
        {
            Write-Host $Error
		    Write-Host "There was an error loading the ActiveDirectory Module. Do you have it installed on this workstation?" -ForegroundColor Red
	    }
    }

	# Make sure at least one parameter was passed
	if (!$GivenName -and !$Name -and !$Surname -and !$SamAccountName -and !$ADUser -and !$ADUserSet)
	{
		Write-Host "You did not provide any parameters. What do you expect me to do? Exiting." -ForegroundColor Red
	}
    else
    {
        # Using GivenName to reset
        if ($GivenName)
        {
            Try
            {
                $Target = Get-ADUser -Filter 'GivenName -like $GivenName'
                Unlock-ADAccount -Identity $Target -Credential $Credential
                $NewPass = Read-Host -AsSecureString "Input the new temporary password for the user"
                Set-ADUser -Identity $Target -Credential $Credential -PasswordNeverExpires $false -ChangePasswordAtLogon $true
                Set-ADAccountPassword -Identity $Target -Credential $Credential -Reset -NewPassword $NewPass
            }
            Catch
            {
                Write-Host $Error
                Write-Host "There was an error resetting the target user. Are you sure that the parameter you provided only selected a single user?" -ForegroundColor Red
            }
        }

        # Using Name to reset
        if ($Name)
        {
            Try
            {
                $Target = Get-ADUser -Filter 'Name -like $Name'
                Unlock-ADAccount -Identity $Target -Credential $Credential
                $NewPass = Read-Host -AsSecureString "Input the new temporary password for the user"
                Set-ADUser -Identity $Target -Credential $Credential -PasswordNeverExpires $false -ChangePasswordAtLogon $true
                Set-ADAccountPassword -Identity $Target -Credential $Credential -Reset -NewPassword $NewPass
            }
            Catch
            {
                Write-Host $Error
                Write-Host "There was an error resetting the target user. Are you sure that the parameter you provided only selected a single user?" -ForegroundColor Red
            }
        }

        # Using Surname to reset
        if ($Surname)
        {
            Try
            {
                $Target = Get-ADUser -Filter 'Surname -like $Surname'
                Unlock-ADAccount -Identity $Target -Credential $Credential
                $NewPass = Read-Host -AsSecureString "Input the new temporary password for the user"
                Set-ADUser -Identity $Target -Credential $Credential -PasswordNeverExpires $false -ChangePasswordAtLogon $true
                Set-ADAccountPassword -Identity $Target -Credential $Credential -Reset -NewPassword $NewPass
            }
            Catch
            {
                Write-Host $Error
                Write-Host "There was an error resetting the target user. Are you sure that the parameter you provided only selected a single user?" -ForegroundColor Red
            }
        }

        # Using SamAccountName to reset
        if ($SamAccountName)
        {
            Try
            {
                $Target = Get-ADUser -Filter 'SamAccountName -like $SamAccountName'
                Unlock-ADAccount -Identity $Target -Credential $Credential
                $NewPass = Read-Host -AsSecureString "Input the new temporary password for the user"
                Set-ADUser -Identity $Target -Credential $Credential -PasswordNeverExpires $false -ChangePasswordAtLogon $true
                Set-ADAccountPassword -Identity $Target -Credential $Credential -Reset -NewPassword $NewPass
            }
            Catch
            {
                Write-Host $Error
                Write-Host "There was an error resetting the target user. Are you sure that the parameter you provided only selected a single user?" -ForegroundColor Red
            }
        }

        # Using ADUser Object to reset
        if ($ADUser)
        {
            Try
            {
                Unlock-ADAccount -Identity $ADUser -Credential $Credential
                $NewPass = Read-Host -AsSecureString "Input the new temporary password for the user"
                Set-ADUser -Identity $ADUser -Credential $Credential -PasswordNeverExpires $false -ChangePasswordAtLogon $true
                Set-ADAccountPassword -Identity $ADUser -Credential $Credential -Reset -NewPassword $NewPass
            }
            Catch
            {
                Write-Host $Error
                Write-Host "There was an error resetting the target user." -ForegroundColor Red
            }
        }

        # Using ADUser Object to reset
        if ($ADUserSet)
        {
            Try
            {
                foreach ($Current in $ADUserSet)
                {
                    Write-Host $Current
                    Unlock-ADAccount -Identity $Current -Credential $Credential
                    $NewPass = Read-Host -AsSecureString "Input the new temporary password for this users"
                    Set-ADUser -Identity $Current -Credential $Credential -PasswordNeverExpires $false -ChangePasswordAtLogon $true
                    Set-ADAccountPassword -Identity $Current -Credential $Credential -Reset -NewPassword $NewPass
                }
            }
            Catch
            {
                Write-Host $Error
                Write-Host "There was an error resetting a user in the set. Are you sure that all objects in the set are ADUsers?" -ForegroundColor Red
            }
        }
    }
}