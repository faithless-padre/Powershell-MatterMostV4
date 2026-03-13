Import-Module /module/MatterMostV4.psd1 -Force

$config = New-PesterConfiguration
$config.Run.Path                = '/tests/Integration'
$config.Output.Verbosity        = 'Detailed'
$config.TestResult.Enabled      = $true
$config.TestResult.OutputFormat = 'JUnitXml'
$config.TestResult.OutputPath   = '/tests/results.xml'

$result = Invoke-Pester -Configuration $config

exit $result.FailedCount
