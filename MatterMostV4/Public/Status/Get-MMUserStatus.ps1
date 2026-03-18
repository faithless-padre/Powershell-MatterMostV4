# Retrieves user status from MatterMost

function Get-MMUserStatus {
    <#
    .SYNOPSIS
        Gets the status of one or more MatterMost users.
    .EXAMPLE
        Get-MMUserStatus -UserId 'abc123'
    .EXAMPLE
        Get-MMUserStatus -Username 'john'
    .EXAMPLE
        Get-MMUserStatus -UserIds @('abc123', 'def456')
    .EXAMPLE
        Get-MMUser -Username 'john' | Get-MMUserStatus
    #>
    [CmdletBinding(DefaultParameterSetName = 'Single')]
    [OutputType('MMUserStatus')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Single', ValueFromPipelineByPropertyName)]
        [Alias('id', 'user_id')]
        [string]$UserId,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$Username,

        [Parameter(Mandatory, ParameterSetName = 'Batch')]
        [string[]]$UserIds
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Batch') {
            Invoke-MMRequest -Endpoint 'users/status/ids' -Method POST -Body $UserIds |
                ForEach-Object { $_ | ConvertTo-MMUserStatus }
        } elseif ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $resolvedId = (Get-MMUser -Username $Username).id
            Invoke-MMRequest -Endpoint "users/$resolvedId/status" -Method GET | ConvertTo-MMUserStatus
        } else {
            Invoke-MMRequest -Endpoint "users/$UserId/status" -Method GET | ConvertTo-MMUserStatus
        }
    }
}
