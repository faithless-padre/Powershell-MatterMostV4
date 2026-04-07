# Удаление отложенного поста MatterMost

function Remove-MMScheduledPost {
    <#
    .SYNOPSIS
        Deletes a scheduled post.
    .DESCRIPTION
        Permanently deletes a scheduled post. The message will not be sent.
        Requires MatterMost server 10.3+.
    .PARAMETER ScheduledPostId
        The ID of the scheduled post to delete. Accepts pipeline input by property name (id).
    .OUTPUTS
        None. Returns status OK on success.
    .EXAMPLE
        Remove-MMScheduledPost -ScheduledPostId 'abc123'
    .EXAMPLE
        Get-MMScheduledPost | Remove-MMScheduledPost
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ScheduledPostId
    )

    process {
        if ($PSCmdlet.ShouldProcess($ScheduledPostId, 'Delete scheduled post')) {
            Invoke-MMRequest -Endpoint "posts/schedule/$ScheduledPostId" -Method DELETE
        }
    }
}
