# Получение списка команд пользователя MatterMost

function Get-MMUserTeams {
    <#
    .SYNOPSIS
        Возвращает список команд, в которых состоит пользователь MatterMost.
    .EXAMPLE
        Get-MMUserTeams -UserId 'abc123'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Get-MMUserTeams
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/teams"
    }
}
