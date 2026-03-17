# Creates a new bot account in MatterMost

function New-MMBot {
    <#
    .SYNOPSIS
        Creates a new bot account in MatterMost.
    .EXAMPLE
        New-MMBot -Username 'ci-bot' -DisplayName 'CI Notifier' -Description 'Posts build results'
    #>
    [CmdletBinding()]
    [OutputType('MMBot')]
    param(
        [Parameter(Mandatory)]
        [string]$Username,

        [Parameter()]
        [string]$DisplayName,

        [Parameter()]
        [string]$Description
    )

    process {
        $body = @{ username = $Username }
        if ($DisplayName) { $body['display_name'] = $DisplayName }
        if ($Description) { $body['description']  = $Description }

        Invoke-MMRequest -Endpoint 'bots' -Method POST -Body $body | ConvertTo-MMBot
    }
}
