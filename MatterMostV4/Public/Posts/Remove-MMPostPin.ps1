# Открепляет пост в канале MatterMost

function Remove-MMPostPin {
    <#
    .SYNOPSIS
        Unpins a post from its MatterMost channel.
    .DESCRIPTION
        Sends POST /posts/{post_id}/unpin to remove the pin from a previously pinned post.
        Requires channel admin or post author privileges.
    .PARAMETER PostId
        The ID of the post to unpin. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Remove-MMPostPin -PostId 'abc123'
    .EXAMPLE
        Get-MMPost -PostId 'abc123' | Remove-MMPostPin
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$PostId
    )

    process {
        Invoke-MMRequest -Endpoint "posts/$PostId/unpin" -Method POST
    }
}
