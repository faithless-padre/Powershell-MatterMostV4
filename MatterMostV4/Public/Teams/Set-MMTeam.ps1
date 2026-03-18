# Обновление команды (team) MatterMost

function Set-MMTeam {
    <#
    .SYNOPSIS
        Updates MatterMost team settings (PUT /teams/{id}/patch).
    .DESCRIPTION
        Sends PUT /teams/{team_id}/patch to partially update one or more team fields.
        Only the parameters you provide are sent — unspecified fields remain unchanged.
        Use -Properties to set arbitrary API fields not covered by named parameters.
    .PARAMETER TeamId
        The ID of the team to update. Accepts pipeline input by property name (id).
    .PARAMETER DisplayName
        The human-readable display name shown in the UI.
    .PARAMETER Description
        The team description shown in team settings.
    .PARAMETER CompanyName
        The company name associated with the team.
    .PARAMETER InviteId
        The invite ID used in invite links. Regenerating this invalidates existing invite links.
    .PARAMETER AllowOpenInvite
        Whether to allow open invitations. Set to $true or $false explicitly.
    .PARAMETER Properties
        A hashtable of arbitrary API fields to include in the PATCH body. Useful for new or undocumented fields.
    .OUTPUTS
        MMTeam. The updated team object.
    .EXAMPLE
        Set-MMTeam -TeamId 'abc123' -DisplayName 'New Name'
    .EXAMPLE
        Get-MMTeam -Name 'myteam' | Set-MMTeam -Description 'Updated description'
    .EXAMPLE
        Set-MMTeam -TeamId 'abc123' -AllowOpenInvite $true
    .EXAMPLE
        Set-MMTeam -TeamId 'abc123' -Properties @{ new_field = 'value' }
    #>
    [OutputType('MMTeam')]
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

        Invoke-MMRequest -Endpoint "teams/$TeamId/patch" -Method PUT -Body $body | ConvertTo-MMTeam
    }
}
