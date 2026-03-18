# Загружает файл на MatterMost сервер и возвращает метаданные

function Send-MMFile {
    <#
    .SYNOPSIS
        Uploads a file to a MatterMost channel. Returns an MMFile object with the file ID.
    .EXAMPLE
        Send-MMFile -FilePath 'C:\report.pdf' -ChannelId 'abc123'
    .EXAMPLE
        Send-MMFile -FilePath 'C:\report.pdf' -ChannelName 'general'
    .EXAMPLE
        Get-MMChannel -Name 'general' | Send-MMFile -FilePath 'C:\report.pdf'
    #>
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    [OutputType('MMFile')]
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,

        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$ChannelName,

        [Parameter(ParameterSetName = 'ByName')]
        [string]$TeamId
    )

    process {
        $resolvedId = if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            (Get-MMChannel -Name $ChannelName -TeamId $TeamId).id
        } else {
            $ChannelId
        }

        Invoke-MMFileUpload -FilePath $FilePath -ChannelId $resolvedId | ConvertTo-MMFile
    }
}
