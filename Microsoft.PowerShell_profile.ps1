# Import useful Modules
Import-Module ActiveDirectory

# Custom Paintjob
$host.UI.RawUI.ForegroundColor = "green"
if ($host.UI.RawUI.WindowTitle -match "Administrator") {
	$host.UI.RawUI.ForegroundColor = "white"
	$host.UI.RawUI.BackgroundColor = "red"
}

# Custom Prompt
function prompt 
{
    Write-Host ("$(Get-Date) `n") -NoNewline -ForegroundColor Yellow
    Write-Host ("PS $(Get-Location)") -NoNewLine
    return ">"
}

# Custom Starting Location
Set-Location "G:\My Documents\WindowsPowerShell\Scripts"