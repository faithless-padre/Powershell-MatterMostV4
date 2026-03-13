BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json
    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
        TestTeamName  = $fileConfig.TestTeamName
    }
    Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force)
    $script:Suffix = (Get-Date -Format 'HHmmss')
    $script:Team   = Get-MMTeam -Name $config.TestTeamName
}

Describe 'New-MMChannel' {

    Context 'Базовое создание' {
        BeforeAll {
            $script:NewChannel = New-MMChannel -TeamId $script:Team.id -Name "pchan_$($script:Suffix)" -DisplayName "Pester Channel $($script:Suffix)"
        }

        AfterAll {
            if ($script:NewChannel) {
                Remove-MMChannel -ChannelId $script:NewChannel.id
            }
        }

        It 'возвращает объект канала' {
            $script:NewChannel      | Should -Not -BeNullOrEmpty
            $script:NewChannel.id   | Should -Not -BeNullOrEmpty
            $script:NewChannel.name | Should -Be "pchan_$($script:Suffix)"
        }

        It 'по умолчанию создаётся публичный канал' {
            $script:NewChannel.type | Should -Be 'O'
        }

        It 'канал доступен через Get-MMChannel' {
            $found = Get-MMChannel -TeamId $script:Team.id -Name "pchan_$($script:Suffix)"
            $found.id | Should -Be $script:NewChannel.id
        }
    }

    Context 'С параметрами' {
        BeforeAll {
            $script:PrivChannel = New-MMChannel -TeamId $script:Team.id -Name "priv_$($script:Suffix)" -DisplayName 'Private Channel' -Type Private -Purpose 'Test purpose' -Header 'Test header'
        }

        AfterAll {
            if ($script:PrivChannel) {
                Remove-MMChannel -ChannelId $script:PrivChannel.id
            }
        }

        It 'создаёт приватный канал' {
            $script:PrivChannel.type | Should -Be 'P'
        }

        It 'сохраняет Purpose и Header' {
            $script:PrivChannel.purpose | Should -Be 'Test purpose'
            $script:PrivChannel.header  | Should -Be 'Test header'
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при дублирующемся имени канала' {
            $tempChan = New-MMChannel -TeamId $script:Team.id -Name "dup_$($script:Suffix)" -DisplayName 'Dup Channel'
            try {
                { New-MMChannel -TeamId $script:Team.id -Name "dup_$($script:Suffix)" -DisplayName 'Dup Channel 2' } | Should -Throw
            } finally {
                Remove-MMChannel -ChannelId $tempChan.id
            }
        }
    }
}
