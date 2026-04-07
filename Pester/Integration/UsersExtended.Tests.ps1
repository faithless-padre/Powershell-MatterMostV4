BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json

    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
        TestTeamName  = if ($env:MM_TEST_TEAM_NAME) { $env:MM_TEST_TEAM_NAME } else { $fileConfig.TestTeamName }
    }

    $modulePath = if (Test-Path '/module/MatterMostV4.psd1') {
        '/module/MatterMostV4.psd1'
    } else {
        Join-Path $PSScriptRoot '..\..\MatterMostV4\MatterMostV4.psd1'
    }
    Import-Module $modulePath -Force

    Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force) -DefaultTeam $config.TestTeamName

    $script:Me     = Get-MMUser
    $script:Suffix = (Get-Date -Format 'HHmmss')

    $script:TestUser = New-MMUser `
        -Username  "usrext_$($script:Suffix)" `
        -Email     "usrext_$($script:Suffix)@test.local" `
        -Password  (ConvertTo-SecureString 'Test123456!' -AsPlainText -Force) `
        -FirstName 'Usr' -LastName 'Ext'
}

AfterAll {
    if ($script:TestUser) {
        Remove-MMUser -UserId $script:TestUser.id
    }
}

# ---------------------------------------------------------------------------
Describe 'Search-MMUser' {

    Context 'Базовый поиск' {
        It 'возвращает результаты для term=admin' {
            $result = Search-MMUser -Term 'admin'

            $result | Should -Not -BeNullOrEmpty
        }

        It 'возвращает объекты типа MMUser' {
            $result = Search-MMUser -Term 'admin'

            $result[0].PSObject.TypeNames | Should -Contain 'MMUser'
            $result[0].id                 | Should -Not -BeNullOrEmpty
            $result[0].username           | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Параметр -Limit' {
        It 'ограничивает количество результатов' {
            $result = Search-MMUser -Term 'admin' -Limit 5

            $result.Count | Should -BeLessOrEqual 5
        }
    }
}

# ---------------------------------------------------------------------------
Describe 'Send-MMPasswordResetEmail' {

    Context 'Отправка письма' {
        It 'не бросает исключение при отправке на валидный email' {
            { Send-MMPasswordResetEmail -Email $script:TestUser.email } | Should -Not -Throw
        }
    }
}

# ---------------------------------------------------------------------------
Describe 'Get-MMUserProfileImage' {

    Context 'Скачивание аватара' {
        It 'скачивает файл на диск' {
            $tmp = [System.IO.Path]::GetTempFileName()
            try {
                Get-MMUserProfileImage -UserId $script:Me.id -OutputPath $tmp
                Test-Path $tmp | Should -BeTrue
                (Get-Item $tmp).Length | Should -BeGreaterThan 0
            } finally {
                Remove-Item $tmp -ErrorAction SilentlyContinue
            }
        }

        It 'принимает UserId из пайплайна по свойству id' {
            $tmp = [System.IO.Path]::GetTempFileName()
            try {
                $script:Me | Get-MMUserProfileImage -OutputPath $tmp
                Test-Path $tmp | Should -BeTrue
            } finally {
                Remove-Item $tmp -ErrorAction SilentlyContinue
            }
        }
    }
}

# ---------------------------------------------------------------------------
Describe 'Set-MMUserProfileImage' {

    It 'Set-MMUserProfileImage сабмит изображения (требуется реальный файл)' -Skip:($true) {
        # Пропускается: для корректного теста нужен валидный PNG/JPEG файл на диске.
        # Создайте реальный файл и уберите -Skip для ручной проверки.
    }
}

# ---------------------------------------------------------------------------
Describe 'Remove-MMUserProfileImage' {

    Context 'Сброс аватара' {
        It 'не бросает исключение при сбросе аватара тестового пользователя' {
            { Remove-MMUserProfileImage -UserId $script:TestUser.id } | Should -Not -Throw
        }

        It 'принимает UserId из пайплайна по свойству id' {
            { $script:TestUser | Remove-MMUserProfileImage } | Should -Not -Throw
        }
    }
}

# ---------------------------------------------------------------------------
Describe 'Set-MMUserMFA' {

    Context 'Деактивация MFA' {
        It 'не бросает исключение при деактивации (no-op если MFA не включён)' {
            { Set-MMUserMFA -UserId $script:Me.id } | Should -Not -Throw
        }
    }
}

# ---------------------------------------------------------------------------
Describe 'New-MMUserMFASecret' {

    Context 'Генерация секрета' {
        It 'возвращает объект с полем secret' -Skip:($true) {
            # MFA disabled on sandbox server
            $result = New-MMUserMFASecret -UserId $script:TestUser.id
            $result        | Should -Not -BeNullOrEmpty
            $result.secret | Should -Not -BeNullOrEmpty
        }

        It 'возвращает объект с полем qr_code' -Skip:($true) {
            # MFA disabled on sandbox server
            $result = New-MMUserMFASecret -UserId $script:TestUser.id
            $result.qr_code | Should -Not -BeNullOrEmpty
        }
    }
}

# ---------------------------------------------------------------------------
Describe 'ConvertTo-MMBotAccount' {

    It 'ConvertTo-MMBotAccount (необратимо — не тестируется в интеграции)' -Skip:($true) {
        # Пропускается: конвертация необратима.
        # Тестировать только вручную на специально созданном пользователе.
    }
}

# ---------------------------------------------------------------------------
Describe 'Get-MMUsersByGroupChannel' {

    Context 'Получение пользователей группового канала' {
        It 'возвращает хэштаблицу с ключом = channel_id' {
            # Requires a group message channel (3+ users); create one with admin + testuser + second user
            $suffix2 = (Get-Date -Format 'HHmmssf')
            $user2 = New-MMUser -Username "grpusr_$suffix2" -Email "grpusr_$suffix2@test.local" `
                -Password (ConvertTo-SecureString 'Test123456!' -AsPlainText -Force) -FirstName 'Grp' -LastName 'Two'

            $gm = New-MMGroupChannel -UserIds @($script:Me.id, $script:TestUser.id, $user2.id)
            $result = Get-MMUsersByGroupChannel -GroupChannelIds $gm.id

            $result          | Should -Not -BeNullOrEmpty
            $result          | Should -BeOfType [hashtable]
            $result[$gm.id]  | Should -Not -BeNullOrEmpty
            $result[$gm.id][0].PSObject.TypeNames | Should -Contain 'MMUser'

            Remove-MMUser -UserId $user2.id
        }
    }
}
