# Retrieves user status from MatterMost

function Get-MMUserStatus {
    <#
    .SYNOPSIS
        Gets the status of one or more MatterMost users.
    .DESCRIPTION
        Retrieves online/away/dnd/offline status. Single user lookup uses GET /users/{user_id}/status.
        Batch lookup uses POST /users/status/ids. Username lookup resolves the user first via Get-MMUser.
    .PARAMETER UserId
        The ID of a single user. Used with the Single parameter set. Accepts pipeline input by property name (id, user_id).
    .PARAMETER Username
        The username to look up. Used with the ByName parameter set.
    .PARAMETER UserIds
        An array of user IDs for batch status lookup. Used with the Batch parameter set.
    .OUTPUTS
        MMUserStatus. One or more user status objects.
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
