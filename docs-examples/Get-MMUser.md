# Get-MMUser — Examples with Output

> Auto-generated against MatterMost sandbox. Do not edit manually.

## Default — current authenticated user
```powershell
PS> Get-MMUser

Id            : fccduydam7883kwpdsundo3oke
Username      : admin
Email         : admin@test.local
FirstName     : Admin
LastName      : User
Nickname      : 
Position      : 
Roles         : system_admin system_user
Locale        : en
EmailVerified : False
MfaActive     : False
AuthService   :
```

## By username
```powershell
PS> Get-MMUser -Username 'testuser'

Id            : p9zmsd5m5jynbpgbqnghn4r7rc
Username      : testuser
Email         : testuser@test.local
FirstName     : Test
LastName      : User
Nickname      : 
Position      : 
Roles         : system_user
Locale        : en
EmailVerified : False
MfaActive     : False
AuthService   :
```

## By email
```powershell
PS> Get-MMUser -Email 'admin@test.local'

Id            : fccduydam7883kwpdsundo3oke
Username      : admin
Email         : admin@test.local
FirstName     : Admin
LastName      : User
Nickname      : 
Position      : 
Roles         : system_admin system_user
Locale        : en
EmailVerified : False
MfaActive     : False
AuthService   :
```

## By ID
```powershell
PS> Get-MMUser -UserId 'fccduydam7883kwpdsundo3oke'

Id            : fccduydam7883kwpdsundo3oke
Username      : admin
Email         : admin@test.local
FirstName     : Admin
LastName      : User
Nickname      : 
Position      : 
Roles         : system_admin system_user
Locale        : en
EmailVerified : False
MfaActive     : False
AuthService   :
```

## Bulk by usernames
```powershell
PS> Get-MMUser -Usernames 'admin', 'testuser'

Username Email               FirstName LastName Roles
-------- -----               --------- -------- -----
admin    admin@test.local    Admin     User     system_admin system_user
testuser testuser@test.local Test      User     system_user
```

## Bulk by IDs
```powershell
PS> Get-MMUser -Ids 'fccduydam7883kwpdsundo3oke', 'p9zmsd5m5jynbpgbqnghn4r7rc'

Username Email               FirstName LastName Roles
-------- -----               --------- -------- -----
admin    admin@test.local    Admin     User     system_admin system_user
testuser testuser@test.local Test      User     system_user
```

## Filter by username (exact)
```powershell
PS> Get-MMUser -Filter {username -eq 'admin'}

Id            : fccduydam7883kwpdsundo3oke
Username      : admin
Email         : admin@test.local
FirstName     : Admin
LastName      : User
Nickname      : 
Position      : 
Roles         : system_admin system_user
Locale        : en
EmailVerified : False
MfaActive     : False
AuthService   :
```

## Filter by username (wildcard)
```powershell
PS> Get-MMUser -Filter {username -like 'test*'}

Username Email               FirstName LastName Roles
-------- -----               --------- -------- -----
testuser testuser@test.local Test      User     system_user
```

## All users
```powershell
PS> Get-MMUser -All

Username Email               FirstName LastName Roles
-------- -----               --------- -------- -----
admin    admin@test.local    Admin     User     system_admin system_user
calls    calls@localhost     Calls              system_user
testuser testuser@test.local Test      User     system_user
```

## Pipeline — get team members then enrich with full user objects
```powershell
PS> Get-MMTeam -Name 'testteam' | Get-MMTeamMembers | Get-MMUser

Username Email            FirstName LastName Roles
-------- -----            --------- -------- -----
admin    admin@test.local Admin     User     system_admin system_user
```

