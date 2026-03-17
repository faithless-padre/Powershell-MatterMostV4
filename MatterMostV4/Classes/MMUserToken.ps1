# MatterMost User Access Token type definition
class MMUserToken {
    [string] $id
    [string] $token
    [string] $user_id
    [string] $description
    [bool]   $is_active
    [hashtable] $ExtendedFields = @{}
}
