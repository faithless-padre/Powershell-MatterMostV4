# MatterMost TeamMember type definition
class MMTeamMember {
    [string] $team_id
    [string] $user_id
    [string] $roles
    [long]   $delete_at
    [bool]   $scheme_guest
    [bool]   $scheme_user
    [bool]   $scheme_admin
    [hashtable] $ExtendedFields = @{}
}
