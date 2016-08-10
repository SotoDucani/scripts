<#
.Synopsis
    Takes a PSCredential object and makes a clixml file.
.DESCRIPTION
    The New-CredentialXML cmdlet creates a clixml file for use in scheduled scripts that require credentials to run. The clixml objects are used by Import-Clixml
.EXAMPLE
    PS C:\> New-CredentialXML -Path 'C:\CredentialStore'

    This command gets a credential object, then creates the clixml file in the CredentialStore folder.

    When you enter the command, a dialog box appears requesting a user name and password. When the information is entered, the cmdlet creates a PSCredential object and converts that to a clixml file.
.EXAMPLE
    PS C:\> New-CredentialXML -Path 'C:\CredentialStore' -Credential $Cred

    This command gets a credential object from the parameter, then creates the clixml file in the CredentialStore folder.
.EXAMPLE
    PS C:\> $Cred = Get-Credential
    PS C:\> $Cred | New-CredentialXML -Path 'C:\CredentialStore'

    This command gets the credential object from the pipeline and creates the clixml file in the CredentialStore folder.
.INPUTS
    System.Management.Automation.PSCredential

    You can pipe a PSCredential object to New-CredentialXML.
.OUTPUTS
    None
#>
function New-CredentialXML
{
    [CmdletBinding()]
    Param
    (
        # Filepath that the clixml file is output to
        [Parameter(Mandatory=$false,
                   Position=0)]
        [String]$Path,
        
        # The Credential object that can be passed as a paramater, or via pipeline
        [Parameter(Mandatory=$false,
                   ValueFromPipeline=$true)]
        [PSCredential]$Credential
    )

    if (Test-Path -Path $Path)
    {
        # Give chance to provide credentials if they are not passed via parameter
        if (!$Credential)
        {
            Write-Host "You need to provide credentials" -ForegroundColor Yellow
            $Credential = Get-Credential
        }
        # Check to make sure credentials were actually provided
        if ($Credential)
        {
            $FilePath = $Path + '\' + $Credential.UserName + 'Cred.clixml'
            Export-Clixml -InputObject $Credential -Path $FilePath
        }
        # Credentials were not provided, so no clixml file will be created.
        else
        {
            Write-Host "Credentials were not provided. No clixml file created." -ForegroundColor Red
        }
    }
    else
    {
        Write-Host "The path that was provided is invalid. Please check the path and try again." -ForegroundColor Red
    }
    
}
