# Возвращает публичную ссылку на файл MatterMost

function Get-MMFileLink {
    <#
    .SYNOPSIS
        Returns a public link to a MatterMost file that can be accessed without authentication.
    .DESCRIPTION
        Calls GET /files/{file_id}/link and returns the publicly accessible URL string.
        Requires the "Allow Public File Links" system setting to be enabled in MatterMost.
        The link is temporary and will expire based on server configuration.
    .PARAMETER FileId
        The ID of the uploaded file. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.String. The public URL of the file.
    .EXAMPLE
        Get-MMFileLink -FileId 'abc123'
    .EXAMPLE
        Send-MMFile -FilePath 'C:\doc.pdf' -ChannelId 'xyz' | Get-MMFileLink
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$FileId
    )

    process {
        $response = Invoke-MMRequest -Endpoint "files/$FileId/link"
        $response.link
    }
}
