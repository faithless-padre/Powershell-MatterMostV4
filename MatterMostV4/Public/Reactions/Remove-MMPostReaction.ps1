# Удаление реакции с поста MatterMost

function Remove-MMPostReaction {
    <#
    .SYNOPSIS
        Removes an emoji reaction from a MatterMost post.
    .DESCRIPTION
        Removes the reaction made by the specified user (or the current user if -UserId is omitted)
        from the given post. Requires being the reaction owner or having manage_system permission.
    .PARAMETER PostId
        The ID of the post. Accepts pipeline input by property name (id).
    .PARAMETER EmojiName
        The name of the emoji reaction to remove (e.g. 'thumbsup').
    .PARAMETER UserId
        The ID of the user whose reaction to remove. Defaults to the currently authenticated user.
    .OUTPUTS
        None. Returns status OK on success.
    .EXAMPLE
        Remove-MMPostReaction -PostId 'abc123' -EmojiName 'thumbsup'
    .EXAMPLE
        Get-MMPost -PostId 'abc123' | Remove-MMPostReaction -EmojiName 'heart'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$PostId,

        [Parameter(Mandatory)]
        [string]$EmojiName,

        [Parameter()]
        [string]$UserId
    )

    process {
        if (-not $UserId) {
            $UserId = (Invoke-MMRequest -Endpoint 'users/me').id
        }
        Invoke-MMRequest -Endpoint "users/$UserId/posts/$PostId/reactions/$EmojiName" -Method DELETE
    }
}
