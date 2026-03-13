BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json

    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
        TestUsername  = if ($env:MM_TEST_USERNAME)  { $env:MM_TEST_USERNAME }  else { $fileConfig.TestUsername }
        TestPassword  = if ($env:MM_TEST_PASSWORD)  { $env:MM_TEST_PASSWORD }  else { $fileConfig.TestPassword }
        TestTeamName  = $fileConfig.TestTeamName
    }

    $modulePath = if (Test-Path '/module/MatterMostV4.psd1') {
        '/module/MatterMostV4.psd1'
    } else {
        Join-Path $PSScriptRoot '..\..\MatterMostV4\MatterMostV4.psd1'
    }
    Import-Module $modulePath -Force

    # Хелпер для конвертации строки в SecureString
    function ConvertToSecure([string]$plain) {
        ConvertTo-SecureString $plain -AsPlainText -Force
    }
}

Describe 'Connect-MMServer' {

    Context 'Username и Password' {
        It 'успешно подключается и возвращает информацию о сессии' {
            $result = Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertToSecure $config.AdminPassword)

            $result.Url      | Should -Be $config.Url
            $result.Username | Should -Be $config.AdminUsername
            $result.AuthType | Should -Be 'SessionToken'
            $result.UserId   | Should -Not -BeNullOrEmpty
        }

        It 'сохраняет $script:MMSession внутри модуля' {
            Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertToSecure $config.AdminPassword)

            $session = & (Get-Module MatterMostV4) { $script:MMSession }

            $session          | Should -Not -BeNullOrEmpty
            $session.Token    | Should -Not -BeNullOrEmpty
            $session.Url      | Should -Be $config.Url
            $session.AuthType | Should -Be 'SessionToken'
        }

        It 'бросает исключение при неверном пароле' {
            { Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertToSecure 'WrongPassword!') } |
                Should -Throw
        }
    }

    Context 'PSCredential' {
        It 'успешно подключается через параметр Credential' {
            $cred = New-Object System.Management.Automation.PSCredential($config.AdminUsername, (ConvertToSecure $config.AdminPassword))

            $result = Connect-MMServer -Url $config.Url -Credential $cred

            $result.Username | Should -Be $config.AdminUsername
            $result.AuthType | Should -Be 'SessionToken'
        }
    }

    Context 'Token' {
        BeforeAll {
            Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertToSecure $config.AdminPassword)
            $script:TokenForTest = (& (Get-Module MatterMostV4) { $script:MMSession }).Token
        }

        It 'успешно подключается через personal token' {
            $result = Connect-MMServer -Url $config.Url -Token $script:TokenForTest

            $result.Username | Should -Be $config.AdminUsername
            $result.AuthType | Should -Be 'PersonalToken'
            $result.UserId   | Should -Not -BeNullOrEmpty
        }

        It 'бросает исключение при невалидном токене' {
            { Connect-MMServer -Url $config.Url -Token 'invalid-token-xyz' } |
                Should -Throw
        }
    }

    Context 'Недоступный сервер' {
        It 'бросает исключение если сервер недоступен' {
            { Connect-MMServer -Url 'http://localhost:9999' -Username $config.AdminUsername -Password (ConvertToSecure $config.AdminPassword) } |
                Should -Throw
        }
    }

    Context 'DefaultTeam' {
        AfterAll {
            Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertToSecure $config.AdminPassword)
        }

        It 'устанавливает DefaultTeamId при корректном имени команды' {
            Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertToSecure $config.AdminPassword) -DefaultTeam $config.TestTeamName

            $session = & (Get-Module MatterMostV4) { $script:MMSession }
            $session.DefaultTeamId | Should -Not -BeNullOrEmpty
        }

        It 'бросает исключение при несуществующей команде' {
            { Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertToSecure $config.AdminPassword) -DefaultTeam 'nonexistent-team-xyz' } |
                Should -Throw
        }

        It 'бросает исключение если DefaultTeamId не задан и TeamId не передан' {
            Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertToSecure $config.AdminPassword)

            { Get-MMChannel } | Should -Throw
        }
    }
}
