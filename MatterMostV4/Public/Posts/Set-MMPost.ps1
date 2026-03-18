# Редактирует существующий пост MatterMost

function Set-MMPost {
    <#
    .SYNOPSIS
        Updates the message of an existing MatterMost post (PATCH).
    .DESCRIPTION
        Sends PUT /posts/{post_id}/patch to edit the text of an existing post.
        Only the message author or a system admin can edit a post. Editing is reflected
        in the UI with an "(edited)" indicator.
    .PARAMETER PostId
        The ID of the post to update. Accepts pipeline input by property name (id).
    .PARAMETER Message
        The new message text. Supports MatterMost markdown.
    .OUTPUTS
        MMPost. The updated post object.
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
