# Подтверждает (acknowledge) пост MatterMost, требующий ознакомления

function Set-MMPostAcknowledged {
    <#
    .SYNOPSIS
        Acknowledges a MatterMost post that requires user acknowledgement.
    .DESCRIPTION
        Calls POST /users/{user_id}/posts/{post_id}/ack to record that the user has
        acknowledged the post. Used with posts that have the acknowledgement feature enabled.
        Returns the acknowledgement object containing the acknowledged_at timestamp.
        Defaults to the current authenticated user.
    .PARAMETER PostId
        The ID of the post to acknowledge. Accepts pipeline input by property name (id).
    .PARAMETER UserId
        The user who acknowledges the post. Defaults to the current authenticated user.
    .OUTPUTS
        System.Management.Automation.PSCustomObject. Acknowledgement object with acknowledged_at field.
    .EXAMPLE
        Set-MMPostAcknowledged -PostId 'abc123'
    .EXAMPLE
        Get-MMPost -PostId 'abc123' | Set-MMPostAcknowledged
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$PostId,

        [Parameter()]
        [string]$UserId
    )

    process {
        if (-not $UserId) {
            $UserId = (Invoke-MMRequest -Endpoint 'users/me').id
        }

        Invoke-MMRequest -Endpoint "users/$UserId/posts/$PostId/ack" -Method POST -Body @{}
    }
}
