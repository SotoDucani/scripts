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
Set-Location "C:\WindowsPowerShell"

#Finally; Start a transcript
$date = get-date -UFormat "%h_%d_%Y AT %H_%M_%S"
$logfile = "C:\WindowsPowerShell\Transcripts\$date.txt"
Start-Transcript -Path $logfile
