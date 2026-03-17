# Deletes a custom emoji from MatterMost

function Remove-MMEmoji {
    <#
    .SYNOPSIS
        Deletes a MatterMost custom emoji by ID.
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
