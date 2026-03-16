# MatterMost Post type definition

class MMPost {
    [string]   $id
    [string]   $user_id
    [string]   $channel_id
    [string]   $root_id
    [string]   $original_id
    [string]   $message
    [string]   $type
    [string]   $hashtag
    [string]   $pending_post_id
    [long]     $create_at
    [long]     $update_at
    [long]     $delete_at
    [long]     $edit_at
    [string[]] $file_ids
    [object]   $props
    [object]   $metadata
    [hashtable] $ExtendedFields = @{}
}
