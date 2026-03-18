# Удаляет пост MatterMost

function Remove-MMPost {
    <#
    .SYNOPSIS
        Deletes a MatterMost post.
    .DESCRIPTION
        Sends DELETE /posts/{post_id} to soft-delete a post. The post content is replaced with
        a deletion notice in the UI. Only the post author or a system admin can delete a post.
        Supports ShouldProcess (-WhatIf / -Confirm).
    .PARAMETER PostId
        The ID of the post to delete. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Remove-MMPost -PostId 'abc123'
    .EXAMPLE
        Get-MMPost -PostId 'abc123' | Remove-MMPost
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$PostId
    )

    process {
        if ($PSCmdlet.ShouldProcess($PostId, 'Delete post')) {
            Invoke-MMRequest -Endpoint "posts/$PostId" -Method DELETE
        }
    }
}
