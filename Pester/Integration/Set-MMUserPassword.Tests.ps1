BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json

    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
    }

    function ConvertToSecure([string]$plain) {
        ConvertTo-SecureString $plain -AsPlainText -Force
    }

    $modulePath = if (Test-Path '/module/MatterMostV4.psd1') {
        '/module/MatterMostV4.psd1'
    } else {
        Join-Path $PSScriptRoot '..\..\MatterMostV4\MatterMostV4.psd1'
    }
    Import-Module $modulePath -Force

        Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertToSecure $config.AdminPassword)

    $script:Suffix        = (Get-Date -Format 'HHmmss')
    $script:TestUser      = New-MMUser `
        -Username "pwdtest_$($script:Suffix)" `
        -Email    "pwdtest_$($script:Suffix)@test.local" `
        -Password (ConvertToSecure 'Pester123!')
}

AfterAll {
    if ($script:TestUser) {
        Remove-MMUser -UserId $script:TestUser.id
    }
}

Describe 'Set-MMUserPassword' {

    Context 'Смена пароля' {
        It 'админ меняет пароль пользователя без CurrentPassword' {
            { Set-MMUserPassword -UserId $script:TestUser.id -NewPassword (ConvertToSecure 'NewPass456!') } |
                Should -Not -Throw
        }

        It 'после смены пользователь логинится с новым паролем' {
            Set-MMUserPassword -UserId $script:TestUser.id -NewPassword (ConvertToSecure 'Changed789!')

            $newSession = Connect-MMServer -Url $config.Url `
                -Username "pwdtest_$($script:Suffix)" `
                -Password (ConvertToSecure 'Changed789!')

            $newSession.Username | Should -Be "pwdtest_$($script:Suffix)"

            # Возвращаем сессию admin
            Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertToSecure $config.AdminPassword) | Out-Null
        }
    }

    Context 'Pipeline' {
        It 'принимает объект пользователя из пайплайна' {
            { Get-MMUser -UserId $script:TestUser.id | Set-MMUserPassword -NewPassword (ConvertToSecure 'Pipe123456!') } |
                Should -Not -Throw
        }
    }

    Context 'CurrentPassword' {
        BeforeAll {
            $script:SelfUser = New-MMUser `
                -Username "selfpwd_$($script:Suffix)" `
                -Email    "selfpwd_$($script:Suffix)@test.local" `
                -Password (ConvertToSecure 'Pester123!')
        }

        AfterAll {
            Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertToSecure $config.AdminPassword) | Out-Null
            if ($script:SelfUser) { Remove-MMUser -UserId $script:SelfUser.id }
        }

        It 'пользователь меняет собственный пароль с CurrentPassword' {
            Connect-MMServer -Url $config.Url `
                -Username "selfpwd_$($script:Suffix)" `
                -Password (ConvertToSecure 'Pester123!') | Out-Null

            { Set-MMUserPassword -UserId $script:SelfUser.id -NewPassword (ConvertToSecure 'NewSelf456!') -CurrentPassword (ConvertToSecure 'Pester123!') } |
                Should -Not -Throw

            Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertToSecure $config.AdminPassword) | Out-Null
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном UserId' {
            { Set-MMUserPassword -UserId 'invalid-id' -NewPassword (ConvertToSecure 'Pass123!') } |
                Should -Throw
        }
    }
}
