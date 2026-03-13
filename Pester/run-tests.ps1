Import-Module /module/MatterMostV4.psd1 -Force

$config = New-PesterConfiguration
$config.Run.Path                = '/tests/Integration'
$config.Output.Verbosity        = 'Detailed'
$config.TestResult.Enabled      = $true
$config.TestResult.OutputFormat = 'JUnitXml'
$config.TestResult.OutputPath   = '/tests/results.xml'

$config.CodeCoverage.Enabled    = $true
$config.CodeCoverage.Path       = '/module'
$config.CodeCoverage.OutputPath = '/tests/coverage.xml'
$config.CodeCoverage.OutputFormat = 'JaCoCo'

$result = Invoke-Pester -Configuration $config

exit $result.FailedCount
