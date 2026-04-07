# Загрузка аватара пользователя MatterMost

function Set-MMUserProfileImage {
    <#
    .SYNOPSIS
        Uploads a profile image for a MatterMost user.
    .DESCRIPTION
        Uploads an image file as the profile picture for the specified user.
        Uses multipart/form-data upload. Supports ShouldProcess (-WhatIf / -Confirm).
    .PARAMETER UserId
        The ID of the user to update. Accepts pipeline input by property name (id).
    .PARAMETER ImagePath
        The local path to the image file to upload (JPG, PNG, etc.).
    .OUTPUTS
        System.Void
    .EXAMPLE
        Set-MMUserProfileImage -UserId 'abc123' -ImagePath 'C:\photos\avatar.png'
    .EXAMPLE
        Get-MMUser -Me | Set-MMUserProfileImage -ImagePath '/tmp/photo.jpg'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId,

        [Parameter(Mandatory)]
        [string]$ImagePath
    )

    process {
        if ($PSCmdlet.ShouldProcess($UserId, 'Upload profile image')) {
            $uri     = "$($script:MMSession.Url)/api/v4/users/$UserId/image"
            $headers = @{ Authorization = "Bearer $($script:MMSession.Token)" }
            Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Form @{ image = Get-Item $ImagePath } | Out-Null
        }
    }
}
