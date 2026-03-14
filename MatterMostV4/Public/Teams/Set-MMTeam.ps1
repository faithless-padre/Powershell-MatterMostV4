# Обновление команды (team) MatterMost

function Set-MMTeam {
    <#
    .SYNOPSIS
        Обновляет параметры команды MatterMost (PUT /teams/{id}/patch).
    .EXAMPLE
        Set-MMTeam -TeamId 'abc123' -DisplayName 'New Name'
    .EXAMPLE
        Get-MMTeam -Name 'myteam' | Set-MMTeam -Description 'Updated description'
    .EXAMPLE
        Set-MMTeam -TeamId 'abc123' -AllowOpenInvite $true
    .EXAMPLE
        Set-MMTeam -TeamId 'abc123' -Properties @{ new_field = 'value' }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TeamId,

        [string]$DisplayName,
        [string]$Description,
        [string]$CompanyName,
        [string]$InviteId,
        [nullable[bool]]$AllowOpenInvite,

        # Произвольные поля — для новых или незадокументированных свойств API
        [hashtable]$Properties
    )

    process {
        $paramMap = @{
            DisplayName     = 'display_name'
            Description     = 'description'
            CompanyName     = 'company_name'
            InviteId        = 'invite_id'
            AllowOpenInvite = 'allow_open_invite'
        }

        $body = @{}
        foreach ($param in $paramMap.Keys) {
            if ($PSBoundParameters.ContainsKey($param)) {
                $body[$paramMap[$param]] = $PSBoundParameters[$param]
            }
        }
        if ($Properties) {
            foreach ($key in $Properties.Keys) { $body[$key] = $Properties[$key] }
        }

        Invoke-MMRequest -Endpoint "teams/$TeamId/patch" -Method PUT -Body $body | Add-MMTypeName -TypeName 'MatterMost.Team'
    }
}
