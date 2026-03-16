# Закрепляет пост в канале MatterMost

function Add-MMPostPin {
    <#
    .SYNOPSIS
        Pins a post to its MatterMost channel.
    .EXAMPLE
        Add-MMPostPin -PostId 'abc123'
    .EXAMPLE
        Get-MMPost -PostId 'abc123' | Add-MMPostPin
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$PostId
    )

    process {
        Invoke-MMRequest -Endpoint "posts/$PostId/pin" -Method POST
    }
}
