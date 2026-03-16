# Деактивация пользователя MatterMost

function Disable-MMUser {
    <#
    .SYNOPSIS
        Deactivates a MatterMost user (soft disable via PUT /active).
    .EXAMPLE
        Disable-MMUser -UserId 'abc123'
    .EXAMPLE
        Get-MMUser testuser | Disable-MMUser
    #>
    [OutputType('MMUser')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/active" -Method PUT -Body @{ active = $false } | ConvertTo-MMUser
    }
}
