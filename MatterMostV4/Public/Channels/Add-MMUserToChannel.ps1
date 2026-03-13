# Добавление пользователя в канал MatterMost

function Add-MMUserToChannel {
    <#
    .SYNOPSIS
        Добавляет пользователя в канал MatterMost.
    .EXAMPLE
        Add-MMUserToChannel -ChannelId 'chan123' -UserId 'user456'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Add-MMUserToChannel -ChannelId 'chan123'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ChannelId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        Invoke-MMRequest -Endpoint "channels/$ChannelId/members" -Method POST -Body @{ user_id = $UserId }
    }
}
