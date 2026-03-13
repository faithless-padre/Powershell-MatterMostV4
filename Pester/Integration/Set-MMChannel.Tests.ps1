BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json
    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
        TestTeamName  = $fileConfig.TestTeamName
    }
    Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force)
    $script:Suffix  = (Get-Date -Format 'HHmmss')
    $script:Team    = Get-MMTeam -Name $config.TestTeamName
    $script:Channel = New-MMChannel -TeamId $script:Team.id -Name "setch_$($script:Suffix)" -DisplayName 'Set Test Channel'
}

AfterAll {
    if ($script:Channel) {
        Invoke-MMRequest -Endpoint "channels/$($script:Channel.id)" -Method DELETE | Out-Null
    }
}

Describe 'Set-MMChannel' {

    Context 'Обновление полей' {
        It 'обновляет DisplayName' {
            $result = Set-MMChannel -ChannelId $script:Channel.id -DisplayName 'Updated Channel'
            $result.display_name | Should -Be 'Updated Channel'
        }

        It 'обновляет Header' {
            $result = Set-MMChannel -ChannelId $script:Channel.id -Header 'New header'
            $result.header | Should -Be 'New header'
        }

        It 'обновляет Purpose' {
            $result = Set-MMChannel -ChannelId $script:Channel.id -Purpose 'New purpose'
            $result.purpose | Should -Be 'New purpose'
        }

        It 'сохраняет остальные поля при частичном обновлении' {
            Set-MMChannel -ChannelId $script:Channel.id -DisplayName 'Partial' | Out-Null
            $chan = Get-MMChannel -ChannelId $script:Channel.id
            $chan.display_name | Should -Be 'Partial'
            $chan.name         | Should -Be "setch_$($script:Suffix)"
        }
    }

    Context 'Pipeline' {
        It 'принимает объект канала из пайплайна' {
            $result = Get-MMChannel -ChannelId $script:Channel.id | Set-MMChannel -DisplayName 'Pipeline Channel'
            $result.display_name | Should -Be 'Pipeline Channel'
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном ChannelId' {
            { Set-MMChannel -ChannelId 'invalid-id-xyz' -DisplayName 'Test' } | Should -Throw
        }
    }
}

Describe 'Remove-MMChannel' {

    Context 'Архивирование' {
        It 'архивирует канал без ошибок' {
            $chan = New-MMChannel -TeamId $script:Team.id -Name "rmch_$($script:Suffix)" -DisplayName 'Remove Test'
            { Remove-MMChannel -ChannelId $chan.id } | Should -Not -Throw
        }

        It 'принимает объект канала из пайплайна' {
            $chan = New-MMChannel -TeamId $script:Team.id -Name "rmpch_$($script:Suffix)" -DisplayName 'Remove Pipe'
            { $chan | Remove-MMChannel } | Should -Not -Throw
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном ChannelId' {
            { Remove-MMChannel -ChannelId 'invalid-id-xyz' } | Should -Throw
        }
    }
}
