# MatterMost IncomingWebhook type definition
class MMIncomingWebhook {
    [string] $id
    [string] $channel_id
    [string] $display_name
    [string] $description
    [string] $username
    [string] $icon_url
    [bool]   $channel_locked
    [long]   $create_at
    [long]   $update_at
    [long]   $delete_at
    [hashtable] $ExtendedFields = @{}
}
