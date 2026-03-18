# Возвращает все посты треда MatterMost

function Get-MMPostThread {
    <#
    .SYNOPSIS
        Returns all posts in a MatterMost thread (root post and all replies).
    .DESCRIPTION
        Calls GET /posts/{post_id}/thread to retrieve the entire reply chain.
        The PostId can be the root post ID or the ID of any reply in the thread — the full thread is returned either way.
        Posts are returned in chronological order.
    .PARAMETER PostId
        The ID of any post in the thread. Accepts pipeline input by property name (id).
    .OUTPUTS
        MMPost. All posts in the thread ordered chronologically.
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
