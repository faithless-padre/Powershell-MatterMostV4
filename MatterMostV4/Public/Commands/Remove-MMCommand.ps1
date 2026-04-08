# Удаление slash-команды MatterMost

function Remove-MMCommand {
    <#
    .SYNOPSIS
        Deletes a MatterMost slash command (DELETE /commands/{command_id}).
    .PARAMETER CommandId
        The ID of the command to delete. Accepts pipeline input by property name (id).
    .EXAMPLE
        Remove-MMCommand -CommandId 'cmd456'
    .EXAMPLE
        Get-MMCommand -TeamId 'abc123' | Where-Object trigger -eq 'hello' | Remove-MMCommand
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$CommandId
    )

    process {
        if ($PSCmdlet.ShouldProcess($CommandId, 'Remove slash command')) {
            Invoke-MMRequest -Endpoint "commands/$CommandId" -Method DELETE
        }
    }
}
