BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json
    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
        TestTeamName  = $fileConfig.TestTeamName
    }
    $modulePath = if (Test-Path '/module/MatterMostV4.psd1') {
        '/module/MatterMostV4.psd1'
    } else {
        Join-Path $PSScriptRoot '..\..\MatterMostV4\MatterMostV4.psd1'
    }
    Import-Module $modulePath -Force

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

    Context 'По TeamName' {
        It 'создаёт канал по TeamName' {
            $chan = New-MMChannel -TeamName $script:Team.name -Name "byname_$($script:Suffix)" -DisplayName 'ByName Channel'
            try {
                $chan      | Should -Not -BeNullOrEmpty
                $chan.name | Should -Be "byname_$($script:Suffix)"
            } finally {
                Remove-MMChannel -ChannelId $chan.id
            }
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

    Context 'DefaultTeam' {
        BeforeAll {
            Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force) -DefaultTeam $config.TestTeamName
        }

        AfterAll {
            Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force)
        }

        It 'создаёт канал без -TeamId используя DefaultTeam' {
            $chan = New-MMChannel -Name "defteam_$($script:Suffix)" -DisplayName 'DefaultTeam Channel'
            try {
                $chan      | Should -Not -BeNullOrEmpty
                $chan.name | Should -Be "defteam_$($script:Suffix)"
            } finally {
                Remove-MMChannel -ChannelId $chan.id
            }
        }
    }
}
