# Загружает файл на MatterMost сервер и возвращает метаданные

function Send-MMFile {
    <#
    .SYNOPSIS
        Uploads a file to a MatterMost channel. Returns an MMFile object with the file ID.
    .EXAMPLE
        Send-MMFile -FilePath 'C:\report.pdf' -ChannelId 'abc123'
    .EXAMPLE
        Get-MMChannel -Name 'general' | Send-MMFile -FilePath 'C:\report.pdf'
    #>
    [CmdletBinding()]
    [OutputType('MMFile')]
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId
    )

    process {
        Invoke-MMFileUpload -FilePath $FilePath -ChannelId $ChannelId | ConvertTo-MMFile
    }
}
