# MatterMost ScheduledPost type definition

class MMScheduledPost {
    [string]   $id
    [string]   $user_id
    [string]   $channel_id
    [string]   $root_id
    [string]   $message
    [object]   $props
    [string[]] $file_ids
    [long]     $scheduled_at
    [long]     $processed_at
    [long]     $create_at
    [long]     $update_at
    [hashtable] $ExtendedFields = @{}
}
