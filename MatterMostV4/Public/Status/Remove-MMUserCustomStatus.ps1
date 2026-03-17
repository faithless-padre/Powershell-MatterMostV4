# Removes a user's custom status in MatterMost

function Remove-MMUserCustomStatus {
    <#
    .SYNOPSIS
        Clears a MatterMost user's custom status.
    .EXAMPLE
        Remove-MMUserCustomStatus -UserId 'abc123'
    .EXAMPLE
        Get-MMUser -Username 'john' | Remove-MMUserCustomStatus
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id', 'user_id')]
        [string]$UserId
    )

    process {
        if ($PSCmdlet.ShouldProcess($UserId, 'Remove custom status')) {
            Invoke-MMRequest -Endpoint "users/$UserId/status/custom" -Method DELETE | Out-Null
        }
    }
}
