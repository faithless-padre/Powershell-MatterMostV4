# Получение реакций для нескольких постов MatterMost за один запрос

function Get-MMBulkPostReactions {
    <#
    .SYNOPSIS
        Returns reactions for multiple MatterMost posts in a single request.
    .DESCRIPTION
        Retrieves all reactions for a list of post IDs via a single bulk API call.
        Returns a hashtable where keys are post IDs and values are arrays of MMReaction objects.
        Requires read_channel permission for the channels the posts are in.
    .PARAMETER PostIds
        An array of post IDs to retrieve reactions for.
    .OUTPUTS
        Hashtable. Keys are post IDs, values are MMReaction arrays.
    .EXAMPLE
        Get-MMBulkPostReactions -PostIds 'abc123', 'def456'
    .EXAMPLE
        $posts = Get-MMChannelPosts -ChannelName 'general'
        Get-MMBulkPostReactions -PostIds $posts.id
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$PostIds
    )

    process {
        $raw = Invoke-MMRequest -Endpoint 'posts/ids/reactions' -Method POST -Body $PostIds
        $result = @{}
        foreach ($prop in $raw.PSObject.Properties) {
            $result[$prop.Name] = $prop.Value | ForEach-Object { $_ | ConvertTo-MMReaction }
        }
        $result
    }
}
