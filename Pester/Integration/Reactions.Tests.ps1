BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json

    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
        TestUsername  = if ($env:MM_TEST_USERNAME)  { $env:MM_TEST_USERNAME }  else { $fileConfig.TestUsername }
        TestTeamName  = if ($env:MM_TEST_TEAM_NAME) { $env:MM_TEST_TEAM_NAME } else { $fileConfig.TestTeamName }
    }

    $modulePath = if (Test-Path '/module/MatterMostV4.psd1') {
        '/module/MatterMostV4.psd1'
    } else {
        Join-Path $PSScriptRoot '..\..\MatterMostV4\MatterMostV4.psd1'
    }
    Import-Module $modulePath -Force

    Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force) -DefaultTeam $config.TestTeamName

    $script:AdminUser = Get-MMUser -Username $config.AdminUsername
    $script:Channel   = Get-MMChannel -Name 'town-square'
    $script:Post      = Send-MMMessage -ToChannel 'town-square' -Message 'Pester reaction test post'
}

AfterAll {
    if ($script:Post) {
        Remove-MMPost -PostId $script:Post.id
    }
}

Describe 'Add-MMPostReaction' {

    It 'добавляет реакцию и возвращает MMReaction' {
        $result = Add-MMPostReaction -PostId $script:Post.id -EmojiName 'thumbsup'

        $result                | Should -Not -BeNullOrEmpty
        $result.GetType().Name | Should -Be 'MMReaction'
        $result.emoji_name     | Should -Be 'thumbsup'
        $result.post_id        | Should -Be $script:Post.id
        $result.user_id        | Should -Be $script:AdminUser.id
    }

    It 'принимает пост по пайплайну' {
        $result = $script:Post | Add-MMPostReaction -EmojiName 'heart'

        $result.emoji_name | Should -Be 'heart'
        $result.post_id    | Should -Be $script:Post.id
    }
}

Describe 'Get-MMPostReactions' {

    It 'возвращает все реакции на пост' {
        $result = Get-MMPostReactions -PostId $script:Post.id

        $result              | Should -Not -BeNullOrEmpty
        $result.Count        | Should -BeGreaterOrEqual 2
        $result[0].GetType().Name | Should -Be 'MMReaction'
    }

    It 'принимает пост по пайплайну' {
        $result = $script:Post | Get-MMPostReactions

        $result | Should -Not -BeNullOrEmpty
    }

    It 'содержит ожидаемые реакции' {
        $result = Get-MMPostReactions -PostId $script:Post.id
        $emojiNames = $result.emoji_name

        $emojiNames | Should -Contain 'thumbsup'
        $emojiNames | Should -Contain 'heart'
    }
}

Describe 'Get-MMBulkPostReactions' {

    BeforeAll {
        $script:Post2 = Send-MMMessage -ToChannel 'town-square' -Message 'Pester bulk reaction test post'
        Add-MMPostReaction -PostId $script:Post2.id -EmojiName 'rocket' | Out-Null
    }

    AfterAll {
        if ($script:Post2) { Remove-MMPost -PostId $script:Post2.id }
    }

    It 'возвращает реакции для нескольких постов' {
        $result = Get-MMBulkPostReactions -PostIds $script:Post.id, $script:Post2.id

        $result                       | Should -Not -BeNullOrEmpty
        $result.GetType().Name        | Should -Be 'Hashtable'
        $result.Keys                  | Should -Contain $script:Post.id
        $result.Keys                  | Should -Contain $script:Post2.id
        $result[$script:Post2.id][0].emoji_name | Should -Be 'rocket'
    }
}

Describe 'Remove-MMPostReaction' {

    It 'удаляет реакцию' {
        $before = Get-MMPostReactions -PostId $script:Post.id
        Remove-MMPostReaction -PostId $script:Post.id -EmojiName 'thumbsup'
        $after = Get-MMPostReactions -PostId $script:Post.id

        $after.Count | Should -BeLessThan $before.Count
        $after.emoji_name | Should -Not -Contain 'thumbsup'
    }

    It 'принимает пост по пайплайну' {
        { $script:Post | Remove-MMPostReaction -EmojiName 'heart' } | Should -Not -Throw
    }
}
