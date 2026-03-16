# Удаляет пост MatterMost

function Remove-MMPost {
    <#
    .SYNOPSIS
        Deletes a MatterMost post.
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
