# Получение всех реакций на пост MatterMost

function Get-MMPostReactions {
    <#
    .SYNOPSIS
        Returns all reactions made on a MatterMost post.
    .DESCRIPTION
        Retrieves all emoji reactions from all users on the specified post.
        Requires read_channel permission for the channel the post is in.
    .PARAMETER PostId
        The ID of the post. Accepts pipeline input by property name (id).
    .OUTPUTS
        MMReaction. One or more reaction objects.
    .EXAMPLE
        Get-MMPostReactions -PostId 'abc123'
    .EXAMPLE
        Get-MMPost -PostId 'abc123' | Get-MMPostReactions
    .EXAMPLE
        Get-MMChannelPosts -ChannelName 'town-square' | Get-MMPostReactions
    #>
    [OutputType('MMReaction')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$PostId
    )

    process {
        Invoke-MMRequest -Endpoint "posts/$PostId/reactions" | ConvertTo-MMReaction
    }
}
