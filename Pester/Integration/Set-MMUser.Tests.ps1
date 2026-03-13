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

    Context 'Обновление одного поля' {
        It 'обновляет nickname' {
            $result = Set-MMUser -UserId $script:TestUser.id -Properties @{ nickname = 'NickUpdated' }

            $result.nickname | Should -Be 'NickUpdated'
        }

        It 'обновляет first_name и last_name' {
            $result = Set-MMUser -UserId $script:TestUser.id -Properties @{ first_name = 'Ivan'; last_name = 'Petrov' }

            $result.first_name | Should -Be 'Ivan'
            $result.last_name  | Should -Be 'Petrov'
        }

        It 'обновляет position' {
            $result = Set-MMUser -UserId $script:TestUser.id -Properties @{ position = 'Developer' }

            $result.position | Should -Be 'Developer'
        }
    }

    Context 'Частичное обновление не затирает другие поля' {
        It 'username и email сохраняются при обновлении nickname' {
            Set-MMUser -UserId $script:TestUser.id -Properties @{ nickname = 'SafeCheck' } | Out-Null
            $user = Get-MMUser -UserId $script:TestUser.id

            $user.username | Should -Be "settest_$($script:Suffix)"
            $user.email    | Should -Be "settest_$($script:Suffix)@test.local"
            $user.nickname | Should -Be 'SafeCheck'
        }
    }

    Context 'Pipeline' {
        It 'принимает объект пользователя из пайплайна' {
            $result = Get-MMUser -UserId $script:TestUser.id | Set-MMUser -Properties @{ nickname = 'PipeNick' }

            $result.nickname | Should -Be 'PipeNick'
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном UserId' {
            { Set-MMUser -UserId 'invalid-id-xyz' -Properties @{ nickname = 'x' } } | Should -Throw
        }
    }
}
