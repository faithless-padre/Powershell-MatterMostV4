# Assigns a MatterMost bot to a new owner

function Set-MMBotOwner {
    <#
    .SYNOPSIS
        Assigns a MatterMost bot to a specified user.
    .DESCRIPTION
        Changes the owner of a bot account via POST /bots/{bot_user_id}/assign/{user_id}.
        Useful when an employee who owns a bot leaves the team. Supports lookup by user ID or username.
    .PARAMETER BotUserId
        The user ID of the bot to reassign. Accepts pipeline input by property name (user_id).
    .PARAMETER OwnerId
        The user ID of the new owner. Used with the ById parameter set.
    .PARAMETER OwnerName
        The username of the new owner. Used with the ByName parameter set.
    .OUTPUTS
        MMBot. The updated bot object reflecting the new owner.
    .EXAMPLE
        Set-MMBotOwner -BotUserId 'abc123' -OwnerId 'user456'
    .EXAMPLE
        Set-MMBotOwner -BotUserId 'abc123' -OwnerName 'john'
    .EXAMPLE
        Get-MMBot -BotUserId 'abc123' | Set-MMBotOwner -OwnerName 'john'
    #>
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    [OutputType('MMBot')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('user_id')]
        [string]$BotUserId,

        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$OwnerId,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$OwnerName
    )

    process {
        $resolvedOwnerId = if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            (Get-MMUser -Username $OwnerName).id
        } else {
            $OwnerId
        }

        Invoke-MMRequest -Endpoint "bots/$BotUserId/assign/$resolvedOwnerId" -Method POST | ConvertTo-MMBot
    }
}
