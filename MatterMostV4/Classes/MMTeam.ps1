# MatterMost Team type definition

class MMTeam {
    [string] $id
    [string] $display_name
    [string] $name
    [string] $description
    [string] $email
    [string] $type
    [string] $company_name
    [string] $allowed_domains
    [string] $invite_id
    [string] $policy_id
    [bool]   $allow_open_invite
    [long]   $create_at
    [long]   $update_at
    [long]   $delete_at
    [hashtable] $ExtendedFields = @{}
}
