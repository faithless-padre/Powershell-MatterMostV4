# Редактирует существующий пост MatterMost

function Set-MMPost {
    <#
    .SYNOPSIS
        Updates the message of an existing MatterMost post (PATCH).
    .EXAMPLE
        Set-MMPost -PostId 'abc123' -Message 'Updated message'
    .EXAMPLE
        Get-MMPost -PostId 'abc123' | Set-MMPost -Message 'Updated message'
    #>
    [CmdletBinding()]
    [OutputType('MMPost')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$PostId,

        [Parameter(Mandatory)]
        [string]$Message
    )

    process {
        Invoke-MMRequest -Endpoint "posts/$PostId/patch" -Method PUT -Body @{ message = $Message } |
            ConvertTo-MMPost
    }
}
