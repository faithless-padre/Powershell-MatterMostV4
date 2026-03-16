# Возвращает все посты треда MatterMost

function Get-MMPostThread {
    <#
    .SYNOPSIS
        Returns all posts in a MatterMost thread (root post and all replies).
    .EXAMPLE
        Get-MMPostThread -PostId 'abc123'
    .EXAMPLE
        Get-MMPost -PostId 'abc123' | Get-MMPostThread
    #>
    [CmdletBinding()]
    [OutputType('MMPost')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$PostId
    )

    process {
        $response = Invoke-MMRequest -Endpoint "posts/$PostId/thread"

        if ($response.order -and $response.posts) {
            foreach ($id in $response.order) {
                $response.posts.$id | ConvertTo-MMPost
            }
        }
    }
}
