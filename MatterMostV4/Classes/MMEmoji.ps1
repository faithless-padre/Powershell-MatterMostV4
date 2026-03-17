# MatterMost custom Emoji type definition
class MMEmoji {
    [string] $id
    [string] $creator_id
    [string] $name
    [long]   $create_at
    [long]   $update_at
    [long]   $delete_at
    [hashtable] $ExtendedFields = @{}
}
