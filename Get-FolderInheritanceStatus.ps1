$InheritanceDisabledArray = @()
$NonInheritedRules = @()

$UserDirs = Get-ChildItem -Directory -Path \\fm-fs02\User -Recurse -Depth 2

foreach($UserDir in $UserDirs) {
    $HasNonInherited = $false

    $DirACL = Get-Acl -Path $UserDir.FullName

    if ($DirACL.AreAccessRulesProtected) {
        Write-Host -ForegroundColor Red -Object "$($UserDir.FullName) has inheritance disabled"
        $InheritanceDisabledArray = $InheritanceDisabledArray + $UserDir.FullName
    } else {
        Write-Verbose -Message "$($UserDir.FullName) has inheritance enabled"
    }

    <#
    foreach($rule in $DirACL.Access) {
        if (!$rule.IsInherited) {
            $HasNonInherited = $true
        }
    }

    if ($HasNonInherited) {
        Write-Host -ForegroundColor Green -Object "$($UserDir.FullName) has Non-Inherited Permissions"
        $NonInheritedRules = $NonInheritedRules + $UserDir.FullName
    }else {
        Write-Verbose -Message "$($UserDir.FullName) is all Inherited Permissions"
    }
    #>
}