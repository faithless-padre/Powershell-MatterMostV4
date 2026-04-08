# Удаление участников из группы MatterMost

function Remove-MMGroupMembers {
    <#
    .SYNOPSIS
        Удаляет пользователей из группы MatterMost.
    .EXAMPLE
        Remove-MMGroupMembers -GroupId 'abc123' -UserIds @('uid1','uid2')
    .EXAMPLE
        Get-MMGroup -GroupId 'abc123' | Remove-MMGroupMembers -UserIds @('uid1')
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$GroupId,

        [Parameter(Mandatory)]
        [string[]]$UserIds
    )

    process {
        if ($PSCmdlet.ShouldProcess($GroupId, 'Remove members from group')) {
            $body = @{ user_ids = $UserIds }
            Invoke-MMRequest -Endpoint "groups/$GroupId/members" -Method DELETE -Body $body
        }
    }
}
