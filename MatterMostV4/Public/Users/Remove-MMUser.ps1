# Деактивация пользователя MatterMost

function Remove-MMUser {
    <#
    .SYNOPSIS
        Деактивирует пользователя MatterMost (soft delete).
    .EXAMPLE
        Remove-MMUser -UserId 'abc123'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Remove-MMUser
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        if ($PSCmdlet.ShouldProcess($UserId, 'Deactivate user')) {
            Invoke-MMRequest -Endpoint "users/$UserId" -Method DELETE
        }
    }
}
