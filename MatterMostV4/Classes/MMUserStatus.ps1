# MatterMost UserStatus type definition
class MMUserStatus {
    [string] $user_id
    [string] $status
    [bool]   $manual
    [long]   $last_activity_at
    [hashtable] $ExtendedFields = @{}
}
