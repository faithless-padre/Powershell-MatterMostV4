# Обновление команды (team) MatterMost

function Set-MMTeam {
    <#
    .SYNOPSIS
        Обновляет параметры команды MatterMost.
    .EXAMPLE
        Set-MMTeam -TeamId 'abc123' -DisplayName 'New Name'
    .EXAMPLE
        Get-MMTeam -Name 'myteam' | Set-MMTeam -Description 'Updated description'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TeamId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$DisplayName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Description,

        [Parameter()]
        [ValidateSet('Open', 'Invite')]
        [string]$Type
    )

    process {
        $current = Invoke-MMRequest -Endpoint "teams/$TeamId"

        $body = @{
            id           = $TeamId
            display_name = if ($PSBoundParameters.ContainsKey('DisplayName')) { $DisplayName } else { $current.display_name }
            description  = if ($PSBoundParameters.ContainsKey('Description')) { $Description } else { $current.description }
            type         = if ($PSBoundParameters.ContainsKey('Type')) { if ($Type -eq 'Open') { 'O' } else { 'I' } } else { $current.type }
        }

        Invoke-MMRequest -Endpoint "teams/$TeamId" -Method PUT -Body $body
    }
}
