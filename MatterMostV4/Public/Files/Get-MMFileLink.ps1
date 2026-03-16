# Возвращает публичную ссылку на файл MatterMost

function Get-MMFileLink {
    <#
    .SYNOPSIS
        Returns a public link to a MatterMost file that can be accessed without authentication.
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
