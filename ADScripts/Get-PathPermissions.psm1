<#
.Synopsis
    Gets the permission list of a specified path,
.DESCRIPTION
    The Get-PathPermissions cmdlet gets the permissions list for the root of a specified path, and any non-inherited permission for any child directory. The permission is printed out with an additional Path property that indicates what directory the permission was found on.
.EXAMPLE
    PS C:\> Get-PathPermissions -Path '\\Server\Share'

    This command gets the path, prints the root permissions, then checks the child directories for non-inherited permissions.
.INPUTS
    None
.OUTPUTS
    None
#>

function Get-PathPermissions
{
    Param
    (
    [Parameter(Mandatory=$true)]
    [String]$Path
    )
 
    # Show the root permissions
    begin
    {
        $root = Get-Item $Path
        ($root | get-acl).Access | Add-Member -MemberType NoteProperty -Name "Path" -Value $($root.fullname).ToString() -PassThru
    }

    # Show any permissions in child directories that are not inherited from the root folder
    process
    {
        # Get child directories
        $containers = Get-ChildItem -path $Path -recurse | ? {$_.psIscontainer -eq $true}
        if ($containers -eq $null)
        {
            break
        }

        # Show the path and permission details for every non-inherited permission
        foreach ($container in $containers)
        {
            (Get-ACL $container.fullname).Access | ? { $_.IsInherited -eq $false } | Add-Member -MemberType NoteProperty -Name "Path" -Value $($container.fullname).ToString() -PassThru
        }
    }
}