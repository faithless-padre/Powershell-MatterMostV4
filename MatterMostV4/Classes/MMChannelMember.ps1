# MatterMost ChannelMember type definition
class MMChannelMember {
    [string] $channel_id
    [string] $user_id
    [string] $roles
    [long]   $last_viewed_at
    [int]    $msg_count
    [int]    $mention_count
    [int]    $mention_count_root
    [string] $notify_props
    [long]   $last_update_at
    [hashtable] $ExtendedFields = @{}
}
