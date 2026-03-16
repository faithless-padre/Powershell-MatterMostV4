# MatterMost Session type definition

class MMSession {
    [string] $id
    [string] $user_id
    [string] $device_id
    [string] $roles
    [bool]   $is_oauth
    [long]   $create_at
    [long]   $expires_at
    [long]   $last_activity_at
    [hashtable] $ExtendedFields = @{}
}
