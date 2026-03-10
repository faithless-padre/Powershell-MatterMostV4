Import-Module /module/MatterMostV4.psd1 -Force

$result = Invoke-Pester /tests/Integration -Output Detailed -PassThru

exit $result.FailedCount
