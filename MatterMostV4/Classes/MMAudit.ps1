# MatterMost Audit log entry
class MMAudit {
    [string] $id
    [string] $user_id
    [string] $create_at_str
    [long]   $create_at
    [string] $action
    [string] $extra_info
    [string] $ip_address
    [string] $session_id
    [hashtable] $ExtendedFields = @{}
}
