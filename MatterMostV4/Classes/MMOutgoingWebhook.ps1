# MatterMost OutgoingWebhook type definition
class MMOutgoingWebhook {
    [string]   $id
    [string]   $team_id
    [string]   $channel_id
    [string]   $creator_id
    [string]   $display_name
    [string]   $description
    [string[]] $trigger_words
    [int]      $trigger_when
    [string[]] $callback_urls
    [string]   $content_type
    [long]     $create_at
    [long]     $update_at
    [long]     $delete_at
    [hashtable] $ExtendedFields = @{}
}
