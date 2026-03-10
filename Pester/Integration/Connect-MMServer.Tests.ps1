BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json

    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
        TestUsername  = if ($env:MM_TEST_USERNAME)  { $env:MM_TEST_USERNAME }  else { $fileConfig.TestUsername }
        TestPassword  = if ($env:MM_TEST_PASSWORD)  { $env:MM_TEST_PASSWORD }  else { $fileConfig.TestPassword }
    }

    $modulePath = if (Test-Path '/module/MatterMostV4.psd1') {
        '/module/MatterMostV4.psd1'
    } else {
        Join-Path $PSScriptRoot '..\..\MatterMostV4\MatterMostV4.psd1'
    }
    Import-Module $modulePath -Force
}

Describe 'Connect-MMServer' {

    Context 'Username and Password' {
        It 'connects successfully and returns session info' {
            $result = Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password $config.AdminPassword

            $result.Url      | Should -Be $config.Url
            $result.Username | Should -Be $config.AdminUsername
            $result.AuthType | Should -Be 'SessionToken'
            $result.UserId   | Should -Not -BeNullOrEmpty
        }

        It 'sets $script:MMSession inside the module' {
            Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password $config.AdminPassword

            $session = & (Get-Module MatterMostV4) { $script:MMSession }

            $session           | Should -Not -BeNullOrEmpty
            $session.Token     | Should -Not -BeNullOrEmpty
            $session.Url       | Should -Be $config.Url
            $session.AuthType  | Should -Be 'SessionToken'
        }

        It 'throws on wrong password' {
            { Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password 'WrongPassword!' } |
                Should -Throw
        }
    }

    Context 'PSCredential' {
        It 'connects successfully using Credential parameter' {
            $securePass = ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force
            $cred = New-Object System.Management.Automation.PSCredential($config.AdminUsername, $securePass)

            $result = Connect-MMServer -Url $config.Url -Credential $cred

            $result.Username | Should -Be $config.AdminUsername
            $result.AuthType | Should -Be 'SessionToken'
        }
    }

    Context 'Token' {
        BeforeAll {
            Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password $config.AdminPassword
            $script:TokenForTest = (& (Get-Module MatterMostV4) { $script:MMSession }).Token
        }

        It 'connects successfully using personal token' {
            $result = Connect-MMServer -Url $config.Url -Token $script:TokenForTest

            $result.Username | Should -Be $config.AdminUsername
            $result.AuthType | Should -Be 'PersonalToken'
            $result.UserId   | Should -Not -BeNullOrEmpty
        }

        It 'throws on invalid token' {
            { Connect-MMServer -Url $config.Url -Token 'invalid-token-xyz' } |
                Should -Throw
        }
    }

    Context 'Invalid server' {
        It 'throws when server is unreachable' {
            { Connect-MMServer -Url 'http://localhost:9999' -Username $config.AdminUsername -Password $config.AdminPassword } |
                Should -Throw
        }
    }
}
