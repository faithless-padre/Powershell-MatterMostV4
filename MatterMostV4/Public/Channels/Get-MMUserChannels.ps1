# Получение списка каналов пользователя в команде MatterMost

function Get-MMUserChannels {
    <#
    .SYNOPSIS
        Возвращает список каналов пользователя в указанной команде MatterMost.
    .EXAMPLE
        Get-MMUserChannels -UserId 'user123' -TeamId 'team456'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Get-MMUserChannels -TeamId 'team456'
    #>
    [OutputType('MMChannel')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId,

        [Parameter(Mandatory)]
        [string]$TeamId
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/teams/$TeamId/channels" | ConvertTo-MMChannel
    }
}
