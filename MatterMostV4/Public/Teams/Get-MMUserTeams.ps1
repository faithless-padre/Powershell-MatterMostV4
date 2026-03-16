# Получение списка команд пользователя MatterMost

function Get-MMUserTeams {
    <#
    .SYNOPSIS
        Returns the list of teams a MatterMost user belongs to.
    .EXAMPLE
        Get-MMUserTeams -UserId 'abc123'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Get-MMUserTeams
    #>
    [OutputType('MMTeam')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/teams" | ConvertTo-MMTeam
    }
}
