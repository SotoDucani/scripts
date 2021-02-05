function Remove-ItemTailRecursion {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            Position=0
        )]$Path,
        [Parameter(
            Mandatory=$false
        )]$LogPath
    )
    #Recursion is here, continues to go down tree until there are no child directories
    foreach ($childDirectory in Get-ChildItem -Force -LiteralPath $Path -Directory) {
        Remove-ItemTailRecursion -Path $childDirectory.FullName -LogPath $LogPath
    }
    
    #Get any child items that exist, ignoring thumbs
    $currentChildren = Get-ChildItem -Force -LiteralPath $Path | Where-Object -FilterScript {$_.Name -ne "Thumbs.db"}
    
    #Folder removal if there are no child items
    $isEmpty = $currentChildren -eq $null
    if ($isEmpty) {
        #Logging
        Write-Verbose "Removing empty folder at path '${Path}'." -Verbose
        if ($LogPath) {
            Out-File -FilePath $LogPath -Append -InputObject "Removing empty folder at path '${Path}'"
        }

        #Removal Command
        try {
            Remove-Item -Force -LiteralPath $Path -Recurse
        } catch {
            $CurError = $Error[0]
            Out-File -FilePath $LogPath -Append -InputObject "Failed to remove folder at path '${Path}'"
            Out-File -FilePath $LogPath -Append -InputObject "Error: $($CurError)"
        }
    }
}