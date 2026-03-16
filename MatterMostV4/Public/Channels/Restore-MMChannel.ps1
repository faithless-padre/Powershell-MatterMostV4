# Восстановление удалённого (архивированного) канала MatterMost

function Restore-MMChannel {
    <#
    .SYNOPSIS
        Восстанавливает удалённый (архивированный) канал MatterMost.
    .EXAMPLE
        Restore-MMChannel -ChannelId 'abc123'
    .EXAMPLE
        Get-MMChannel -ChannelId 'abc123' | Restore-MMChannel
    #>
    [CmdletBinding()]
    [OutputType('MMChannel')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId
    )

    process {
        Invoke-MMRequest -Endpoint "channels/$ChannelId/restore" -Method POST |
            ConvertTo-MMChannel
    }
}
