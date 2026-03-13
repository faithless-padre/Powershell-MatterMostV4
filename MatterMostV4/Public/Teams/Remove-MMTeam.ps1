# Удаление (архивирование) команды MatterMost

function Remove-MMTeam {
    <#
    .SYNOPSIS
        Архивирует команду MatterMost.
    .EXAMPLE
        Remove-MMTeam -TeamId 'abc123'
    .EXAMPLE
        Get-MMTeam -Name 'myteam' | Remove-MMTeam
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TeamId
    )

    process {
        if ($PSCmdlet.ShouldProcess($TeamId, 'Archive team')) {
            Invoke-MMRequest -Endpoint "teams/$TeamId" -Method DELETE
        }
    }
}
