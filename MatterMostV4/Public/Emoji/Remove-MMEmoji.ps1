# Deletes a custom emoji from MatterMost

function Remove-MMEmoji {
    <#
    .SYNOPSIS
        Deletes a MatterMost custom emoji by ID.
    .DESCRIPTION
        Sends DELETE /emoji/{emoji_id} to permanently remove a custom emoji.
        Only the emoji creator or a system admin can delete an emoji.
        Supports ShouldProcess (-WhatIf / -Confirm).
    .PARAMETER EmojiId
        The ID of the emoji to delete. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Remove-MMEmoji -EmojiId 'abc123'
    .EXAMPLE
        Get-MMEmoji -Name 'myemoji' | Remove-MMEmoji
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$EmojiId
    )

    process {
        if ($PSCmdlet.ShouldProcess($EmojiId, 'Remove custom emoji')) {
            Invoke-MMRequest -Endpoint "emoji/$EmojiId" -Method DELETE | Out-Null
        }
    }
}
