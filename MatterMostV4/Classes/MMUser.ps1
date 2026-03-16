# MatterMost User type definition

class MMUser {
    [string]   $id
    [string]   $username
    [string]   $email
    [string]   $first_name
    [string]   $last_name
    [string]   $nickname
    [string]   $roles
    [string]   $locale
    [string]   $auth_service
    [string]   $position
    [string]   $terms_of_service_id
    [bool]     $email_verified
    [bool]     $mfa_active
    [long]     $create_at
    [long]     $update_at
    [long]     $delete_at
    [long]     $last_password_update
    [long]     $last_picture_update
    [long]     $terms_of_service_create_at
    [int]      $failed_attempts
    [object]   $notify_props
    [object]   $props
    [object]   $timezone
    [hashtable] $ExtendedFields = @{}
}
