# MatterMost File metadata type definition

class MMFile {
    [string] $id
    [string] $user_id
    [string] $post_id
    [string] $name
    [string] $extension
    [string] $mime_type
    [long]   $size
    [long]   $create_at
    [long]   $update_at
    [long]   $delete_at
    [int]    $width
    [int]    $height
    [bool]   $has_preview_image
    [hashtable] $ExtendedFields = @{}
}
