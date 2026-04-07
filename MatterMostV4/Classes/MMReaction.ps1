# MatterMost Reaction type definition

class MMReaction {
    [string] $user_id
    [string] $post_id
    [string] $emoji_name
    [long]   $create_at
    [hashtable] $ExtendedFields = @{}
}
