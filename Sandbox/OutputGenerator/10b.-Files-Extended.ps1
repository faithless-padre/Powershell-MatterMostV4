# Генератор реального вывода для wiki-страницы Files (расширенные командлеты)

. (Join-Path $PSScriptRoot 'Common.ps1')

Connect-Sandbox

$sb = [System.Text.StringBuilder]::new()

# Upload a test PNG for thumbnail/preview demos
# Create a minimal valid PNG in /tmp
$pngBytes = [Convert]::FromBase64String(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='
)
$testPng = '/tmp/mm-test-thumb.png'
[System.IO.File]::WriteAllBytes($testPng, $pngBytes)

$channel = Get-MMChannel -Name 'town-square'
$file    = Send-MMFile -FilePath $testPng -ChannelId $channel.Id

# Get-MMFileThumbnail
$thumbOut = '/tmp/mm-thumb-dl.png'
$thumb    = Get-MMFileThumbnail -FileId $file.Id -OutFile $thumbOut
$thumbInfo = $thumb | Select-Object Name, Length, LastWriteTime

$null = $sb.AppendLine('### Download file thumbnail')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> $file = Send-MMFile -FilePath ./image.png -ChannelId $channel.Id')
$null = $sb.AppendLine("PS> Get-MMFileThumbnail -FileId `$file.Id -OutFile '/tmp/thumb.png'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl $thumbInfo))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMFilePreview
$previewOut = '/tmp/mm-preview-dl.png'
$preview    = Get-MMFilePreview -FileId $file.Id -OutFile $previewOut
$previewInfo = $preview | Select-Object Name, Length, LastWriteTime

$null = $sb.AppendLine('### Download file preview')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMFilePreview -FileId `$file.Id -OutFile '/tmp/preview.png'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl $previewInfo))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Search-MMFile — note Elasticsearch requirement, show syntax only
$null = $sb.AppendLine('### Search for files in a team')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('# Requires Elasticsearch to be enabled on the MatterMost server.')
$null = $sb.AppendLine('# Without Elasticsearch the call returns an empty result set.')
$null = $sb.AppendLine('PS> Search-MMFile -Terms report')
$null = $sb.AppendLine('PS> Search-MMFile -Terms "design mockup" -IsOrSearch')
$null = $sb.AppendLine('```')

Update-WikiPage -FileName '10.-Files.md' -ExamplesContent $sb.ToString()
Write-Host 'Done.'
