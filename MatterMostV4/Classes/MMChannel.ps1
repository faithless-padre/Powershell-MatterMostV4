# MatterMost Channel type definition

class MMChannel {
    [string] $id
    [string] $team_id
    [string] $type
    [string] $display_name
    [string] $name
    [string] $header
    [string] $purpose
    [string] $creator_id
    [long]   $create_at
    [long]   $update_at
    [long]   $delete_at
    [long]   $last_post_at
    [long]   $extra_update_at
    [int]    $total_msg_count
    [hashtable] $ExtendedFields = @{}
}
