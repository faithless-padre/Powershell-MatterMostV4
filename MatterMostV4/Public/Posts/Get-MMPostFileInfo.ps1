# Возвращает метаданные файлов, прикреплённых к посту MatterMost

function Get-MMPostFileInfo {
    <#
    .SYNOPSIS
        Returns file metadata for all files attached to a MatterMost post.
    .DESCRIPTION
        Calls GET /posts/{post_id}/files/info to retrieve metadata for each file
        attached to the post. Returns an empty result for posts without attachments.
    .PARAMETER PostId
        The ID of the post whose file attachments to retrieve. Accepts pipeline input by property name (id).
    .OUTPUTS
        MMFile. Zero or more file metadata objects.
    .EXAMPLE
        Get-MMPostFileInfo -PostId 'abc123'
    .EXAMPLE
        Get-MMPost -PostId 'abc123' | Get-MMPostFileInfo
    #>
    [CmdletBinding()]
    [OutputType('MMFile')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$PostId
    )

    process {
        $raw = Invoke-MMRequest -Endpoint "posts/$PostId/files/info"

        foreach ($item in $raw) {
            $item | ConvertTo-MMFile
        }
    }
}
