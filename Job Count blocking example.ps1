$JobList = @()
$TODO = @("A","B","C","D","E","F","G","H","I","J","K")

foreach ($i in $TODO) {
    Do {
        Write-Host "Sleeping..."
        Start-Sleep -Seconds 1
    } Until (($JobList | Where-Object -FilterScript {$_.State -eq 'Running'}).Count -lt 5)

    $Job = Start-Job -Name $i -ScriptBlock {Start-Sleep -Seconds 10}
    $JobList = $JobList + $Job

    Write-Host "Job started for $($i)"
}

Do {
        $Total = $TODO.count
        $Complete = ($JobList | Where-Object -FilterScript {$_.State -ne 'Running'}).count
        Write-Progress -Id 1 -Activity "Running User Creation" -Status "User Creation in Progress: $Complete of $Total" -PercentComplete (($Complete/$Total)*100)
    }
	Until (($JobList | Where-Object -FilterScript {$_.State -eq 'Running'}).Count -eq 0)
    Write-Verbose -Message "All jobs completed"