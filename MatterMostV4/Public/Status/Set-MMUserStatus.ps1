# Sets a user's status in MatterMost

function Set-MMUserStatus {
    <#
    .SYNOPSIS
        Sets a MatterMost user's status to online, away, dnd, or offline.
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
