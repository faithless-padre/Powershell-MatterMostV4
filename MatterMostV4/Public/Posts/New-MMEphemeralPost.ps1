# Создаёт эфемерный (временный) пост, видимый только указанному пользователю

function New-MMEphemeralPost {
    <#
    .SYNOPSIS
        Creates an ephemeral post visible only to the specified user.
    .DESCRIPTION
        Calls POST /posts/ephemeral to create a temporary post that is shown only
        to the target user and is not persisted in channel history. Requires system admin privileges.
    .PARAMETER UserId
        The ID of the user who will see the ephemeral post.
    .PARAMETER ChannelId
        The ID of the channel in which the post will appear.
    .PARAMETER Message
        The message text to display. Supports MatterMost markdown.
    .OUTPUTS
        MMPost. The created ephemeral post object.
    .EXAMPLE
        New-MMEphemeralPost -UserId 'user123' -ChannelId 'chan456' -Message 'Only you can see this'
    #>
    [CmdletBinding()]
    [OutputType('MMPost')]
    param(
        [Parameter(Mandatory)]
        [string]$UserId,

        [Parameter(Mandatory)]
        [string]$ChannelId,

        [Parameter(Mandatory)]
        [string]$Message
    )

    process {
        $body = @{
            user_id = $UserId
            post    = @{
                channel_id = $ChannelId
                message    = $Message
            }
        }

        Invoke-MMRequest -Endpoint 'posts/ephemeral' -Method POST -Body $body | ConvertTo-MMPost
    }
}
