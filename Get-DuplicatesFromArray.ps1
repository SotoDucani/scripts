$Array = @{1,2,3,4,5,12,23,4,3,3,2,1,2,4,45,51,2,4,3,5,62,23,34}
$Array | Group | Where-Object -FilterScript {$_.Count -gt 1}