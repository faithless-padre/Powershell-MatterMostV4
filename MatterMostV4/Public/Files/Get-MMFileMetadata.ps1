# Возвращает метаданные файла по его ID

function Get-MMFileMetadata {
    <#
    .SYNOPSIS
        Returns metadata for a previously uploaded MatterMost file.
    .EXAMPLE
        Get-MMFileMetadata -FileId 'abc123'
    .EXAMPLE
        $file = Send-MMFile -FilePath 'C:\doc.pdf' -ChannelId 'xyz'
        Get-MMFileMetadata -FileId $file.id
    #>
    [CmdletBinding()]
    [OutputType('MMFile')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$FileId
    )

    process {
        Invoke-MMRequest -Endpoint "files/$FileId/info" | ConvertTo-MMFile
    }
}
