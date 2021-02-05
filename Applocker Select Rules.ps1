$file = Get-Content -Path C:\support\OldLaptopEXEAPEnforce.xml

$i = 0

while ($i -lt $file.count) {
    if ($file[$i] -like "<FilePublisherRule Id=* Name=*Turbo*") {
        Write-Host $file[$i]
        $start = $i
        while ($file[$i] -notlike "*</FilePublisherRule>*") {
            $i = $i + 1
            Write-Host "    Searching for end"
        }
        $end = $i
        Write-Host $file[$end]
        $Ruletext = $file[$start..$end]
        Out-File -FilePath J:\TurboTaxRules.xml -Append -InputObject $Ruletext
        $i = $start + 1
    } elseif ($file[$i] -like "<FileHashRule Id=* Name=*Turbo*") {
        Write-Host $file[$i]
        $start = $i
        while ($file[$i] -notlike "*</FileHashRule>*") {
            $i = $i + 1
            Write-Host "    Searching for end"
        }
        $end = $i
        Write-Host $file[$end]
        $Ruletext = $file[$start..$end]
        Out-File -FilePath J:\TurboTaxRules.xml -Append -InputObject $Ruletext
        $i = $start + 1
    }
    $i = $i + 1
}