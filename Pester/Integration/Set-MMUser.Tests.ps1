BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json

    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
    }

    Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force)

    $script:Suffix   = (Get-Date -Format 'HHmmss')
    $script:TestPass = ConvertTo-SecureString 'Pester123!' -AsPlainText -Force
    $script:TestUser = New-MMUser `
        -Username  "settest_$($script:Suffix)" `
        -Email     "settest_$($script:Suffix)@test.local" `
        -Password  $script:TestPass
}

AfterAll {
    if ($script:TestUser) {
        Remove-MMUser -UserId $script:TestUser.id
    }
}

Describe 'Set-MMUser' {

    Context 'Именованные параметры' {
        It 'обновляет Nickname' {
            $result = Set-MMUser -UserId $script:TestUser.id -Nickname 'NickNamed'

            $result.nickname | Should -Be 'NickNamed'
        }

        It 'обновляет FirstName и LastName' {
            $result = Set-MMUser -UserId $script:TestUser.id -FirstName 'Ivan' -LastName 'Petrov'

            $result.first_name | Should -Be 'Ivan'
            $result.last_name  | Should -Be 'Petrov'
        }

        It 'обновляет Position' {
            $result = Set-MMUser -UserId $script:TestUser.id -Position 'Developer'

            $result.position | Should -Be 'Developer'
        }
    }

    Context 'Сырые данные через -Properties' {
        It 'обновляет поле через -Properties' {
            $result = Set-MMUser -UserId $script:TestUser.id -Properties @{ nickname = 'RawNick' }

            $result.nickname | Should -Be 'RawNick'
        }

        It '-Properties перекрывает именованный параметр' {
            $result = Set-MMUser -UserId $script:TestUser.id -Nickname 'Named' -Properties @{ nickname = 'Override' }

            $result.nickname | Should -Be 'Override'
        }
    }

    Context 'Частичное обновление не затирает другие поля' {
        It 'username и email сохраняются при обновлении Nickname' {
            Set-MMUser -UserId $script:TestUser.id -Nickname 'SafeCheck' | Out-Null
            $user = Get-MMUser -UserId $script:TestUser.id

            $user.username | Should -Be "settest_$($script:Suffix)"
            $user.email    | Should -Be "settest_$($script:Suffix)@test.local"
            $user.nickname | Should -Be 'SafeCheck'
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
            { Set-MMUser -UserId 'invalid-id-xyz' -Nickname 'x' } | Should -Throw
        }
    }
}
