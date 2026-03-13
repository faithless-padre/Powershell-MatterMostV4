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
}

Describe 'Disconnect-MMServer' {

    Context 'Успешный logout' {
        BeforeEach {
            Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertToSecure $config.AdminPassword)
        }

        It 'очищает $script:MMSession после логаута' {
            Disconnect-MMServer

            $session = & (Get-Module MatterMostV4) { $script:MMSession }
            $session | Should -BeNullOrEmpty
        }

        It 'последующий API вызов бросает исключение' {
            Disconnect-MMServer

            { Get-MMUser -Me } | Should -Throw
        }
    }

    Context 'Без активной сессии' {
        BeforeEach {
            # Убеждаемся что сессии нет
            & (Get-Module MatterMostV4) { $script:MMSession = $null }
        }

        It 'не бросает исключение если сессии нет' {
            { Disconnect-MMServer } | Should -Not -Throw
        }
    }
}
