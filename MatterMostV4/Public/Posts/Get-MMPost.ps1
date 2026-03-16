# Возвращает пост MatterMost по ID или списку ID

function Get-MMPost {
    <#
    .SYNOPSIS
        Returns a MatterMost post by ID, or multiple posts by a list of IDs.
    .EXAMPLE
        Get-MMPost -PostId 'abc123'
    .EXAMPLE
        Get-MMPost -PostIds @('abc123', 'def456')
    #>
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    [OutputType('MMPost')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$PostId,

        [Parameter(Mandatory, ParameterSetName = 'ByIds')]
        [string[]]$PostIds
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            Invoke-MMRequest -Endpoint "posts/$PostId" | ConvertTo-MMPost
        } else {
            Invoke-MMRequest -Endpoint 'posts/ids' -Method POST -Body $PostIds |
                ConvertTo-MMPost
        }
    }
}
