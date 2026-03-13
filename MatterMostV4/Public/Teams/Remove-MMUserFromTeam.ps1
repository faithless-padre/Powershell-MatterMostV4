# Удаление пользователя из команды MatterMost

function Remove-MMUserFromTeam {
    <#
    .SYNOPSIS
        Удаляет пользователя из команды MatterMost.
    .EXAMPLE
        Remove-MMUserFromTeam -TeamId 'team123' -UserId 'user123'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Remove-MMUserFromTeam -TeamId 'team123'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$TeamId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        if ($PSCmdlet.ShouldProcess($UserId, "Remove from team $TeamId")) {
            Invoke-MMRequest -Endpoint "teams/$TeamId/members/$UserId" -Method DELETE
        }
    }
}
