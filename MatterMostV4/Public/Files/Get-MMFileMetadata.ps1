# Возвращает метаданные файла по его ID

function Get-MMFileMetadata {
    <#
    .SYNOPSIS
        Returns metadata for a previously uploaded MatterMost file.
    .DESCRIPTION
        Calls GET /files/{file_id}/info to retrieve file metadata without downloading the file content.
        Returns information such as name, size, MIME type, dimensions (for images), and the post it is attached to.
    .PARAMETER FileId
        The ID of the file to retrieve metadata for. Accepts pipeline input by property name (id).
    .OUTPUTS
        MMFile. The file metadata object.
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
