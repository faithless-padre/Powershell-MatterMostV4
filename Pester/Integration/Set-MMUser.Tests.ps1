BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json

    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
    }

    Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force)

    $script:Suffix   = (Get-Date -Format 'HHmmss')
    $script:TestUser = New-MMUser `
        -Username  "settest_$($script:Suffix)" `
        -Email     "settest_$($script:Suffix)@test.local" `
        -Password  'Pester123!'
}

AfterAll {
    if ($script:TestUser) {
        Invoke-MMRequest -Endpoint "users/$($script:TestUser.id)" -Method DELETE | Out-Null
    }
}

Describe 'Set-MMUser' {

    Context 'Обновление полей профиля' {
        It 'обновляет FirstName и LastName' {
            $result = Set-MMUser -UserId $script:TestUser.id -FirstName 'Updated' -LastName 'Name'

            $result.first_name | Should -Be 'Updated'
            $result.last_name  | Should -Be 'Name'
        }

        It 'обновляет Nickname' {
            $result = Set-MMUser -UserId $script:TestUser.id -Nickname 'NickUpdated'

            $result.nickname | Should -Be 'NickUpdated'
        }

        It 'обновляет Position' {
            $result = Set-MMUser -UserId $script:TestUser.id -Position 'Developer'

            $result.position | Should -Be 'Developer'
        }

        It 'сохраняет остальные поля при частичном обновлении' {
            Set-MMUser -UserId $script:TestUser.id -FirstName 'Partial' | Out-Null
            $user = Get-MMUser -UserId $script:TestUser.id

            $user.first_name | Should -Be 'Partial'
            $user.username   | Should -Be "settest_$($script:Suffix)"
        }
    }

    Context 'Pipeline' {
        It 'принимает объект пользователя из пайплайна' {
            $result = Get-MMUser -UserId $script:TestUser.id | Set-MMUser -Nickname 'PipeNick'

            $result.nickname | Should -Be 'PipeNick'
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном UserId' {
            { Set-MMUser -UserId 'invalid-id-xyz' -FirstName 'Test' } | Should -Throw
        }
    }
}
