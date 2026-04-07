# Добавление реакции (эмодзи) на пост MatterMost

function Add-MMPostReaction {
    <#
    .SYNOPSIS
        Adds an emoji reaction to a MatterMost post.
    .DESCRIPTION
        Adds a reaction (emoji) from the currently authenticated user to the specified post.
        The emoji must be a valid system or custom emoji name (without colons).
        Requires read_channel permission for the channel the post is in.
    .PARAMETER PostId
        The ID of the post to react to. Accepts pipeline input by property name (id).
    .PARAMETER EmojiName
        The name of the emoji to use as a reaction (e.g. 'thumbsup', 'heart', '+1').
    .OUTPUTS
        MMReaction. The created reaction object.
    .EXAMPLE
        Add-MMPostReaction -PostId 'abc123' -EmojiName 'thumbsup'
    .EXAMPLE
        Get-MMPost -PostId 'abc123' | Add-MMPostReaction -EmojiName 'heart'
    #>
    [OutputType('MMReaction')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$PostId,

        [Parameter(Mandatory)]
        [string]$EmojiName
    )

    process {
        $me = Invoke-MMRequest -Endpoint 'users/me'
        $body = @{
            user_id    = $me.id
            post_id    = $PostId
            emoji_name = $EmojiName
        }
        Invoke-MMRequest -Endpoint 'reactions' -Method POST -Body $body | ConvertTo-MMReaction
    }
}
