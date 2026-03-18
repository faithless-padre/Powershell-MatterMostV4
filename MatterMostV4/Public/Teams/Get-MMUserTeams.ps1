# Получение списка команд пользователя MatterMost

function Get-MMUserTeams {
    <#
    .SYNOPSIS
        Returns the list of teams a MatterMost user belongs to.
    .EXAMPLE
        Get-MMUserTeams -UserId 'abc123'
    .EXAMPLE
        Get-MMUserTeams -Username 'jdoe'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Get-MMUserTeams
    #>
    [OutputType('MMTeam')]
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$Username
    )

    process {
        $resolvedId = if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            (Get-MMUser -Username $Username).id
        } else {
            $UserId
        }

        Invoke-MMRequest -Endpoint "users/$resolvedId/teams" | ConvertTo-MMTeam
    }
}
