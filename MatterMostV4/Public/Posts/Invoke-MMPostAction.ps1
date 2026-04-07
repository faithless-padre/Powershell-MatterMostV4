# Выполняет действие интерактивной кнопки/меню в посте MatterMost

function Invoke-MMPostAction {
    <#
    .SYNOPSIS
        Executes an interactive message button or menu action on a MatterMost post.
    .DESCRIPTION
        Calls POST /posts/{post_id}/actions/{action_id} to trigger a button or
        select-menu action defined in the post's attachments. The integration endpoint
        configured in the action receives the trigger. Returns a status and trigger_id.
    .PARAMETER PostId
        The ID of the post containing the interactive action.
    .PARAMETER ActionId
        The ID of the action to execute (from the post's attachment actions array).
    .OUTPUTS
        System.Management.Automation.PSCustomObject. Response object with status and trigger_id fields.
    .EXAMPLE
        Invoke-MMPostAction -PostId 'abc123' -ActionId 'action456'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$PostId,

        [Parameter(Mandatory)]
        [string]$ActionId
    )

    process {
        Invoke-MMRequest -Endpoint "posts/$PostId/actions/$ActionId" -Method POST -Body @{}
    }
}
