# Закрепляет пост в канале MatterMost

function Add-MMPostPin {
    <#
    .SYNOPSIS
        Pins a post to its MatterMost channel.
    .DESCRIPTION
        Sends POST /posts/{post_id}/pin to pin the post in its channel. Pinned posts are visible
        in the channel's "Pinned Messages" sidebar. Requires channel admin or post author privileges.
    .PARAMETER PostId
        The ID of the post to pin. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Add-MMPostPin -PostId 'abc123'
    .EXAMPLE
        Get-MMPost -PostId 'abc123' | Add-MMPostPin
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$PostId
    )

    process {
        Invoke-MMRequest -Endpoint "posts/$PostId/pin" -Method POST
    }
}
