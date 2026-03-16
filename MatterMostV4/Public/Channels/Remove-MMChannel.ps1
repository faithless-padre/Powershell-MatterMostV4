# Удаление (архивирование) канала MatterMost

function Remove-MMChannel {
    <#
    .SYNOPSIS
        Archives a MatterMost channel.
    .EXAMPLE
        Remove-MMChannel -ChannelId 'abc123'
    .EXAMPLE
        Get-MMChannel -ChannelId 'abc123' | Remove-MMChannel
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId
    )

    process {
        if ($PSCmdlet.ShouldProcess($ChannelId, 'Archive channel')) {
            Invoke-MMRequest -Endpoint "channels/$ChannelId" -Method DELETE
        }
    }
}
