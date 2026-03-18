# Загружает файл на MatterMost сервер и возвращает метаданные

function Send-MMFile {
    <#
    .SYNOPSIS
        Uploads a file to a MatterMost channel. Returns an MMFile object with the file ID.
    .DESCRIPTION
        Uploads a local file to the specified channel via POST /files using multipart form data.
        The returned file ID can be passed to New-MMPost -FilePath or used with Get-MMFileLink.
        Note: uploading a file does not post it — use New-MMPost or Send-MMMessage to attach it to a message.
    .PARAMETER FilePath
        The local filesystem path to the file to upload.
    .PARAMETER ChannelId
        The ID of the destination channel. Used with the ById parameter set. Accepts pipeline input by property name (id).
    .PARAMETER ChannelName
        The name of the destination channel. Used with the ByName parameter set.
    .PARAMETER TeamId
        The team ID to scope the channel name lookup. Used with the ByName parameter set.
        Falls back to the default team if omitted.
    .OUTPUTS
        MMFile. The uploaded file metadata object including the file ID.
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
