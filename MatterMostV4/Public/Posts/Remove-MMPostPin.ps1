# Открепляет пост в канале MatterMost

function Remove-MMPostPin {
    <#
    .SYNOPSIS
        Unpins a post from its MatterMost channel.
    .EXAMPLE
        Remove-MMPostPin -PostId 'abc123'
    .EXAMPLE
        Get-MMPost -PostId 'abc123' | Remove-MMPostPin
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$PostId
    )

    process {
        Invoke-MMRequest -Endpoint "posts/$PostId/unpin" -Method POST
    }
}
