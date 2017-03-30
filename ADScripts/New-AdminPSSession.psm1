<#
.SYNOPSIS
    Opens a PSSession on the default server after prompting for credentials. Can also accept other connection targets via the '-Server' parameter. Mainly written because I am to lazy to keep writing the domain\username part and server name.
#>

function New-AdminPSSession
{

    [CmdletBinding()]
    Param
    (
        #Alternate Server Target
        [Parameter(Mandatory=$false, Position=0)]
        [String]$Server
    )
    
    $Cred = Get-Credential -Credential domain\username
    $DefaultServer = "server01"
    
    #If the -Server parameter is used
    if ($Server -and $Cred)
    {
        New-PSSession -ComputerName $Server -Credential $Cred | Enter-PSSession
    }
    #If there is no -Server specified
    elseif (!$Server -and $Cred)
    {
        New-PSSession -ComputerName $DefaultServer -Credential $Cred | Enter-PSSession
    }
}

Export-ModuleMember -Function New-AdminPSSession
