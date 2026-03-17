# Assigns a MatterMost bot to a new owner

function Set-MMBotOwner {
    <#
    .SYNOPSIS
        Assigns a MatterMost bot to a specified user.
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
