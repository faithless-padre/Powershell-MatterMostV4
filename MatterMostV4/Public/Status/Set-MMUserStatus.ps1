# Sets a user's status in MatterMost

function Set-MMUserStatus {
    <#
    .SYNOPSIS
        Sets a MatterMost user's status to online, away, dnd, or offline.
    .DESCRIPTION
        Sends PUT /users/{user_id}/status to change the user's presence status.
        When setting 'dnd', optionally specify -DndEndTime to automatically lift Do Not Disturb at a future time.
    .PARAMETER UserId
        The ID of the user to update. Accepts pipeline input by property name (id, user_id).
    .PARAMETER Status
        The new status value. One of: 'online', 'away', 'dnd', 'offline'.
    .PARAMETER DndEndTime
        The date/time when Do Not Disturb should automatically end. Only applicable when Status is 'dnd'.
    .OUTPUTS
        MMUserStatus. The updated user status object.
    .EXAMPLE
        Set-MMUserStatus -UserId 'abc123' -Status 'dnd'
    .EXAMPLE
        Set-MMUserStatus -UserId 'abc123' -Status 'dnd' -DndEndTime (Get-Date).AddHours(2)
    .EXAMPLE
        Get-MMUser -Username 'john' | Set-MMUserStatus -Status 'away'
    #>
    [CmdletBinding()]
    [OutputType('MMUserStatus')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id', 'user_id')]
        [string]$UserId,

        [Parameter(Mandatory)]
        [ValidateSet('online', 'away', 'dnd', 'offline')]
        [string]$Status,

        # Only applies when Status is 'dnd'. Time at which DND will be automatically lifted.
        [Parameter()]
        [DateTime]$DndEndTime
    )

    process {
        $body = @{
            user_id = $UserId
            status  = $Status
        }
        if ($PSBoundParameters.ContainsKey('DndEndTime')) {
            $body['dnd_end_time'] = [long]($DndEndTime - [DateTime]'1970-01-01').TotalSeconds
        }

        Invoke-MMRequest -Endpoint "users/$UserId/status" -Method PUT -Body $body | ConvertTo-MMUserStatus
    }
}
