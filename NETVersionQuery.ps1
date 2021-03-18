# REF https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
$Cred = Get-Credential

$members = New-Object -Type System.Collections.Generic.List[PSObject]
$members.add("Target1")
$members.add("Target2")

$ScriptBlock = {
    try {
	    $Release = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -ErrorAction Stop).Release
    } catch {
	    Write-Error ".NET Registry Path not found" -ErrorAction Stop
    }
    Switch($Release) {
        "378389" { return ".NET Framework 4.5" }
        "378675" { return ".NET Framework 4.5.1" }
        "378758" { return ".NET Framework 4.5.1" }
        "379893" { return ".NET Framework 4.5.2" }
        "393295" { return ".NET Framework 4.6" }
        "393297" { return ".NET Framework 4.6" }
        "394254" { return ".NET Framework 4.6.1" }
        "394271" { return ".NET Framework 4.6.1" }
        "394802" { return ".NET Framework 4.6.2" }
        "394806" { return ".NET Framework 4.6.2" }
        "460798" { return ".NET Framework 4.7" }
        "460805" { return ".NET Framework 4.7" }
        "461308" { return ".NET Framework 4.7.1" }
        "461310" { return ".NET Framework 4.7.1" }
        "461808" { return ".NET Framework 4.7.2" }
        "461814" { return ".NET Framework 4.7.2" }
        "528040" { return ".NET Framework 4.8" }
        "528049" { return ".NET Framework 4.8" }
        "528372" { return ".NET Framework 4.8" }
        default { Write-Error "Unmatched .NET version found: $($Release)" -ErrorAction Stop}
    }
}

foreach ($list in $members) {
	foreach ($target in $list) {
		Write-Host "Target: $($target) --> Result: " -nonewline
		Invoke-Command -ComputerName $target -Credential $cred -ScriptBlock $ScriptBlock
	}
}
