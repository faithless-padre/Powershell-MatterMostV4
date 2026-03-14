@{
    ExcludeRules = @(
        # Test files use ConvertTo-SecureString -AsPlainText with test credentials only
        'PSAvoidUsingConvertToSecureStringWithPlainText'
    )
}
