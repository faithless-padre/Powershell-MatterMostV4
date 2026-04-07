# Retrieves server audit log entries from MatterMost

function Get-MMServerAudits {
    <#
    .SYNOPSIS
        Gets server-wide audit log entries from MatterMost.
    .DESCRIPTION
        Sends a GET request to /audits with optional pagination parameters.
        Returns an array of MMAudit objects. Requires manage_system permission.
    .PARAMETER Page
        Page number to retrieve (zero-based). Default: 0.
    .PARAMETER PerPage
        Number of audit entries per page. Default: 100.
    .OUTPUTS
        MMAudit[]. Array of audit log entries.
    .EXAMPLE
        Get-MMServerAudits -PerPage 50
    #>
    [OutputType('MMAudit')]
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$Page = 0,

        [Parameter()]
        [int]$PerPage = 100
    )

    process {
        Invoke-MMRequest -Endpoint "audits?page=$Page&per_page=$PerPage" |
            ForEach-Object { $_ | ConvertTo-MMAudit }
    }
}
