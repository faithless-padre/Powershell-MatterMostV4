# Удаление пользователя из канала MatterMost

function Remove-MMUserFromChannel {
    <#
    .SYNOPSIS
        Removes a user from a MatterMost channel.
    .EXAMPLE
        Remove-MMUserFromChannel -ChannelId 'chan123' -UserId 'user456'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Remove-MMUserFromChannel -ChannelId 'chan123'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$ChannelId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        if ($PSCmdlet.ShouldProcess("UserId=$UserId", "Remove from channel $ChannelId")) {
            Invoke-MMRequest -Endpoint "channels/$ChannelId/members/$UserId" -Method DELETE | Out-Null
        }
    }
}
