# Добавление участников в группу MatterMost

function Add-MMGroupMembers {
    <#
    .SYNOPSIS
        Добавляет пользователей в группу MatterMost.
    .EXAMPLE
        Add-MMGroupMembers -GroupId 'abc123' -UserIds @('uid1','uid2')
    .EXAMPLE
        Get-MMGroup -GroupId 'abc123' | Add-MMGroupMembers -UserIds @('uid1')
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$GroupId,

        [Parameter(Mandatory)]
        [string[]]$UserIds
    )

    process {
        $body = @{ user_ids = $UserIds }
        Invoke-MMRequest -Endpoint "groups/$GroupId/members" -Method POST -Body $body
    }
}
