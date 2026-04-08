# Отмена (остановка) задания MatterMost

function Stop-MMJob {
    <#
    .SYNOPSIS
        Отменяет выполняющееся задание MatterMost.
    .EXAMPLE
        Stop-MMJob -JobId 'abc123'
    .EXAMPLE
        Get-MMJob -JobId 'abc123' | Stop-MMJob
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$JobId
    )

    process {
        if ($PSCmdlet.ShouldProcess($JobId, 'Cancel job')) {
            Invoke-MMRequest -Endpoint "jobs/$JobId/cancel" -Method DELETE | Out-Null
        }
    }
}
