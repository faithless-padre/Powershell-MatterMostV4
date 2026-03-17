# MatterMost Bot type definition
class MMBot {
    [string] $user_id
    [string] $username
    [string] $display_name
    [string] $description
    [string] $owner_id
    [long]   $create_at
    [long]   $update_at
    [long]   $delete_at
    [hashtable] $ExtendedFields = @{}
}
