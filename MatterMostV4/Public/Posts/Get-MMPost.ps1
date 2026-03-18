# Возвращает пост MatterMost по ID или списку ID

function Get-MMPost {
    <#
    .SYNOPSIS
        Returns a MatterMost post by ID, or multiple posts by a list of IDs.
    .DESCRIPTION
        Retrieves post objects from /posts/{post_id} (single) or POST /posts/ids (batch).
        For reading channel history use Get-MMChannelPosts or Get-MMMessage.
    .PARAMETER PostId
        The ID of a single post to retrieve. Used with the ById parameter set. Accepts pipeline input by property name (id).
    .PARAMETER PostIds
        An array of post IDs for batch lookup. Used with the ByIds parameter set.
    .OUTPUTS
        MMPost. One or more post objects.
    .EXAMPLE
        Get-MMPost -PostId 'abc123'
    .EXAMPLE
        Get-MMPost -PostIds @('abc123', 'def456')
    #>
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    [OutputType('MMPost')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$PostId,

        [Parameter(Mandatory, ParameterSetName = 'ByIds')]
        [string[]]$PostIds
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            Invoke-MMRequest -Endpoint "posts/$PostId" | ConvertTo-MMPost
        } else {
            Invoke-MMRequest -Endpoint 'posts/ids' -Method POST -Body $PostIds |
                ConvertTo-MMPost
        }
    }
}
