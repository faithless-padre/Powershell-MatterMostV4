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

    $script:Channel = Get-MMChannel -Name 'town-square'
    $script:Team    = Get-MMTeam -Name $config.TestTeamName
    $script:FutureTime = (Get-Date).AddDays(1)

    # Scheduled Posts require a MatterMost Enterprise/Professional license
    $script:LicensedFeature = $true
    try {
        New-MMScheduledPost -ChannelId $script:Channel.id -Message 'license check' -ScheduledAt $script:FutureTime | Out-Null
    } catch {
        if ($_ -match 'requires a license') {
            $script:LicensedFeature = $false
            Write-Warning 'Scheduled Posts require a license — tests will be skipped'
        }
    } finally {
        Get-MMScheduledPost -TeamId $script:Team.id -ErrorAction SilentlyContinue | Remove-MMScheduledPost -ErrorAction SilentlyContinue
    }
}

AfterAll {
    # Cleanup any leftover scheduled posts
    Get-MMScheduledPost -TeamId $script:Team.id | Remove-MMScheduledPost
}

Describe 'New-MMScheduledPost' {

    It 'создаёт scheduled post и возвращает MMScheduledPost' -Skip:(-not $script:LicensedFeature) {
        $result = New-MMScheduledPost -ChannelId $script:Channel.id -Message 'Pester scheduled post' -ScheduledAt $script:FutureTime

        $result                | Should -Not -BeNullOrEmpty
        $result.GetType().Name | Should -Be 'MMScheduledPost'
        $result.id             | Should -Not -BeNullOrEmpty
        $result.channel_id     | Should -Be $script:Channel.id
        $result.message        | Should -Be 'Pester scheduled post'
        $result.scheduled_at   | Should -BeGreaterThan 0

        $script:ScheduledPost = $result
    }
}

Describe 'Get-MMScheduledPost' {

    It 'возвращает список scheduled posts' -Skip:(-not $script:LicensedFeature) {
        $result = Get-MMScheduledPost -TeamId $script:Team.id

        $result              | Should -Not -BeNullOrEmpty
        $result[0].GetType().Name | Should -Be 'MMScheduledPost'
    }

    It 'содержит созданный пост' -Skip:(-not $script:LicensedFeature) {
        $result = Get-MMScheduledPost -TeamId $script:Team.id

        $result.id | Should -Contain $script:ScheduledPost.id
    }

    It 'работает с DefaultTeam без -TeamId' -Skip:(-not $script:LicensedFeature) {
        $result = Get-MMScheduledPost

        $result | Should -Not -BeNullOrEmpty
    }

    It 'принимает team по пайплайну' -Skip:(-not $script:LicensedFeature) {
        $result = $script:Team | Get-MMScheduledPost

        $result | Should -Not -BeNullOrEmpty
    }
}

Describe 'Set-MMScheduledPost' {

    It 'обновляет message scheduled post' -Skip:(-not $script:LicensedFeature) {
        $result = Set-MMScheduledPost -ScheduledPostId $script:ScheduledPost.id -ChannelId $script:Channel.id -Message 'Updated message' -ScheduledAtMs $script:ScheduledPost.scheduled_at

        $result                | Should -Not -BeNullOrEmpty
        $result.GetType().Name | Should -Be 'MMScheduledPost'
        $result.message        | Should -Be 'Updated message'

        $script:ScheduledPost = $result
    }

    It 'принимает scheduled post по пайплайну' -Skip:(-not $script:LicensedFeature) {
        $newTime = (Get-Date).AddDays(2)
        $result = $script:ScheduledPost | Set-MMScheduledPost -ScheduledAt $newTime

        $result.id | Should -Be $script:ScheduledPost.id
    }
}

Describe 'Remove-MMScheduledPost' {

    It 'удаляет scheduled post' -Skip:(-not $script:LicensedFeature) {
        Remove-MMScheduledPost -ScheduledPostId $script:ScheduledPost.id

        $remaining = Get-MMScheduledPost -TeamId $script:Team.id
        $remaining.id | Should -Not -Contain $script:ScheduledPost.id
    }

    It 'принимает scheduled post по пайплайну' -Skip:(-not $script:LicensedFeature) {
        $sp = New-MMScheduledPost -ChannelId $script:Channel.id -Message 'To be deleted' -ScheduledAt $script:FutureTime
        { $sp | Remove-MMScheduledPost } | Should -Not -Throw
    }
}
