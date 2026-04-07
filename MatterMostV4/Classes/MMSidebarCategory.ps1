# MatterMost SidebarCategory type definition
class MMSidebarCategory {
    [string]    $id
    [string]    $user_id
    [string]    $team_id
    [string]    $display_name
    [string]    $type
    [int]       $sort_order
    [string[]]  $channel_ids
    [hashtable] $ExtendedFields = @{}
}
