# Удаление группы MatterMost

function Remove-MMGroup {
    <#
    .SYNOPSIS
        Удаляет группу MatterMost по ID.
    .EXAMPLE
        Remove-MMGroup -GroupId 'abc123'
    .EXAMPLE
        Get-MMGroup -GroupId 'abc123' | Remove-MMGroup
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$GroupId
    )

    process {
        if ($PSCmdlet.ShouldProcess($GroupId, 'Delete group')) {
            Invoke-MMRequest -Endpoint "groups/$GroupId" -Method DELETE | Out-Null
        }
    }
}
