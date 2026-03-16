# MatterMost Role type definition

class MMRole {
    [string]   $id
    [string]   $name
    [string]   $display_name
    [string]   $description
    [string[]] $permissions
    [bool]     $scheme_managed
    [hashtable] $ExtendedFields = @{}
}
