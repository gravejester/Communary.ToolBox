function Test-PasswordStrength {
    <#
        .SYNOPSIS
            Test password strength.
        .DESCRIPTION
            This functions lets input a password to test it strength.
        .EXAMPLE
            Test-PasswordStrength 'MyCoolPassword'
        .NOTES
            Based on code example from https://social.msdn.microsoft.com/Forums/vstudio/en-US/5e3f27d2-49af-410a-85a2-3c47e3f77fb1/how-to-check-for-password-strength?forum=csharpgeneral
            Author: Øyvind Kallstad
            Date: 24.09.2015
            Version: 1.0
        .OUTPUTS
            System.String
        .LINK
            https://communary.wordpress.com/
    #>
    [CmdletBinding()]
    param (
        # The password to test
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Password
    )

    $score = 0

    if ($Password.Length -lt 5) {
        Write-Verbose 'Password length is less than 5 characters.'
        Write-Output 'Very Weak'
        break
    }

    if ($Password.Length -ge 8) {
        Write-Verbose 'Password length is equal to or greater than 8 characters. Added 1 to password score.'
        $score++
    }

    if ($Password.Length -ge 12) {
        Write-Verbose 'Password length is equal to or greater than 12 characters. Added 1 to password score.'
        $score++
    }

    if ([regex]::IsMatch($Password, '\d+')) {
        Write-Verbose 'Password contains numbers. Added 1 to password score.'
        $score++
    }

    if ([regex]::IsMatch($Password, '[a-z]+')) {
        Write-Verbose 'Password lowercase letters. Added 1 to password score.'
        $score++
    }

    if ([regex]::IsMatch($Password, '[A-Z]+')) {
        Write-Verbose 'Password uppercase letters. Added 1 to password score.'
        $score++
    }

    if ([regex]::IsMatch($Password, '[!@#$%^&*?_~-£(){},]+')) {
        Write-Verbose 'Password symbols. Added 1 to password score.'
        $score++
    }

    switch ($score) {
        1 { $passwordScore = 'Very Weak' }
        2 { $passwordScore = 'Weak' }
        3 { $passwordScore = 'Medium' }
        4 { $passwordScore = 'Strong' }
        5 { $passwordScore = 'Strong' }
        6 { $passwordScore = 'Very Strong' }
    }

    Write-Output $passwordScore
}

function Invoke-VerifyAndUpdatePasswordComplexity {
    param (
        [System.Text.StringBuilder] $Password,
        [switch] $IncludeSymbols = $true,
        [switch] $IncludeNumbers = $true,
        [switch] $IncludeUppercaseCharacters = $true,
        [switch] $IncludeLowercaseCharacters = $true,
        [string] $Symbols,
        [string] $Numbers,
        [string] $UpperCaseCharacters,
        [string] $LowerCaseCharacters,
        [switch] $UpdatePassword
    )

    $complexityOk = $true

    if ($IncludeSymbols) {
        if (-not(Compare-Object -ReferenceObject $symbols.ToCharArray() -DifferenceObject $password.ToString().ToCharArray() -IncludeEqual -ExcludeDifferent)) {
            if ($UpdatePassword) {
                $password[(Get-Random -Minimum 1 -Maximum ($password.Length))] = $symbols[(Get-Random -Minimum 0 -Maximum ($symbols.Length))]
            }
            else {
                $complexityOk = $false
            }
        }
    }

    if ($IncludeNumbers) {
        if (-not(Compare-Object -ReferenceObject $numbers.ToCharArray() -DifferenceObject $password.ToString().ToCharArray() -IncludeEqual -ExcludeDifferent)) {
            if ($UpdatePassword) {
                $password[(Get-Random -Minimum 1 -Maximum ($password.Length))] = $numbers[(Get-Random -Minimum 0 -Maximum ($numbers.Length))]
            }
            else {
                $complexityOk = $false
            }
        }
    }

    if ($IncludeUppercaseCharacters) {
        if (-not(Compare-Object -ReferenceObject $UpperCaseCharacters.ToCharArray() -DifferenceObject $password.ToString().ToCharArray() -IncludeEqual -ExcludeDifferent)) {
            if ($UpdatePassword) {
                $password[(Get-Random -Minimum 1 -Maximum ($password.Length))] = $UpperCaseCharacters[(Get-Random -Minimum 0 -Maximum ($UpperCaseCharacters.Length))]
            }
            else {
                $complexityOk = $false
            }
        }
    }

    if ($IncludeLowercaseCharacters) {
        if (-not(Compare-Object -ReferenceObject $LowerCaseCharacters.ToCharArray() -DifferenceObject $password.ToString().ToCharArray() -IncludeEqual -ExcludeDifferent)) {
            if ($UpdatePassword) {
                $password[(Get-Random -Minimum 1 -Maximum ($password.Length))] = $LowerCaseCharacters[(Get-Random -Minimum 0 -Maximum ($LowerCaseCharacters.Length))]
            }
            else {
                $complexityOk = $false
            }
        }
    }

    if ($UpdatePassword) {
        Write-Output $Password
    }
    else {
        Write-Output $complexityOk
    }
}


function IsConsonant {
    param([char]$Character)
    if ('bcdfghjklmnpqrstvwxyz'.ToCharArray() -contains $Character) {Write-Output $true}
    else {Write-Output $false}
}

function IsVowel {
    param([char]$Character)
    if ('aeiou'.ToCharArray() -contains $Character) {Write-Output $true}
    else {Write-Output $false}
}

function New-PronounceablePassword {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateRange(4,[int]::MaxValue)]
        [int] $Length = 10,

        [Parameter()]
        [Alias('Numbers')]
        [switch] $IncludeNumbers = $true,

        [Parameter()]
        [Alias('Uppercase')]
        [switch] $IncludeUppercaseCharacters = $true
    )

    $consonantDigraphs = 'bl', 'br', 'ch', 'cl', 'cr', 'dr', 'fl', 'fr', 'gl', 'gr', 'pl', 'pr', 'sc', 'sh', 'sk', 'sl', 'sm', 'sn', 'sp', 'st', 'sw', 'th', 'tr', 'tw', 'wh', 'wr'
    $consonantTrigraphs = 'sch', 'scr', 'shr', 'sph', 'spl', 'spr', 'squ', 'str', 'thr'
    $consonants = 'bcdfghjklmnpqrstvwxyz'
    $vowels = 'aeiou'

    $startSet = $consonantDigraphs + $consonantTrigraphs + $consonants.ToCharArray() + $vowels.ToCharArray()
    $allSet = $consonants.ToCharArray() + $vowels.ToCharArray()

    $currentConsecutiveConsonants = 0
    $currentConsecutiveVowels = 0

    $password = New-Object -TypeName System.Text.StringBuilder -ArgumentList $Length
    $byteArray = New-Object -TypeName System.Byte[] -ArgumentList $Length
    $rng = New-Object -TypeName System.Security.Cryptography.RNGCryptoServiceProvider
    $rng.GetBytes($byteArray)

    for ($i = 0; $i -lt $length; $i++) {

        # as the start of the password, we choose from our special start set
        if ($i -eq 0) {
            [void]$password.Append(($startSet[$byteArray[$i] % $startSet.Length]))
            if ($password.Length -eq 2) { $i++ }
            elseif ($password.Length -eq 3) { $i = $i + 2 }
            $afterStart = $true
            continue
        }

        # handle the character after the start
        if ($afterStart) {
            # if a consonant, next must be a vowel
            if (IsConsonant -Character $password[-1]) {
                [void]$password.Append(($vowels[$byteArray[$i] % $vowels.Length]))
                $currentConsecutiveVowels++
                $currentConsecutiveConsonants = 0
            }
            # if a vowel, next must be a consonant
            else {
                [void]$password.Append(($consonants[$byteArray[$i] % $consonants.Length]))
                $currentConsecutiveConsonants++
                $currentConsecutiveVowels = 0
            }
            $afterStart = $false
        }

        else {
            # if 3 consecutive vowels, next must be a consonant
            if ($currentConsecutiveVowels -eq 3) {
                [void]$password.Append(($consonants[$byteArray[$i] % $consonants.Length]))
                $currentConsecutiveConsonants++
                $currentConsecutiveVowels = 0
                continue
            }

            # if 2 consecutive consonants, next must be a vowel
            if ($currentConsecutiveConsonants -eq 2) {
                [void]$password.Append(($vowels[$byteArray[$i] % $vowels.Length]))
                $currentConsecutiveVowels++
                $currentConsecutiveConsonants = 0
                continue
            }

            # randomly pick next character
            [void]$password.Append(($allSet[$byteArray[$i] % $allSet.Length]))

            # if last character added was a consonant
            if (IsConsonant -Character $password[-1]) {
                $currentConsecutiveConsonants++
                $currentConsecutiveVowels = 0
            }
            # else last character added was a vowel
            else {
                $currentConsecutiveVowels++
                $currentConsecutiveConsonants = 0
            }
        }
    }

    $currentConsecutiveConsonants = 0
    $currentConsecutiveVowels = 0

    $rng.GetBytes($byteArray)

    # perform a second pass of the generated password to try
    # to make it more pronounceable and secure
    for ($i = 0; $i -lt $length; $i++) {
        if (IsConsonant -Character $password[$i]) {
            $currentConsecutiveConsonants++
            $currentConsecutiveVowels = 0
        }
        else {
            $currentConsecutiveVowels++
            $currentConsecutiveConsonants = 0
        }

        # handle difficult to pronounce consonant pairs
        $difficultConsonantPairs = 'gb', 'jb', 'tp', 'tf', 'qx', 'bt', 'js', 'wv', 'jp', 'mz', 'qj', 'fc', 'jq', 'mv', 'kc', 'jr', 'mk', 'bw', 'cg', 'fj', 'kd', 'hc', 'hg', 'cj', 'wc', 'bp', 'bc', 'bv', 'vq', 'mw', 'pk', 'bx', 'fr', 'hv', 'cz', 'vg', 'bd', 'wj', 'dn', 'gj', 'jf', 'qb', 'tg', 'pv', 'vl', 'jy', 'wn', 'pw', 'dw', 'kq', 'vd', 'vw', 'tj', 'qw', 'vm', 'zs', 'sz', 'dx', 'vf', 'yd', 'tx'
        if ($currentConsecutiveConsonants -eq 2) {
            $consonantPair = $password[$i - 1] + $password[$i]
            if ($difficultConsonantPairs -contains $consonantPair) {
                Write-Verbose 'Replacing difficult consonant pairs'
                $password[$i - 1] = (($consonants[$byteArray[$i] % $consonants.Length]))
                $password[$i] = (($consonants[$byteArray[$i] % $consonants.Length]))
            }
        }

        if ($IncludeUppercaseCharacters) {
            # randomly change characters to upper case
            if ($true, $false | Get-Random) {
                $password[$i] = $password[$i].ToString().ToUpper()
            }
            if ($password[$i] -eq 'L') {$password[$i] = 'l'; Write-Verbose 'Changed "l" to "L"'}
        }

        switch ($password[$i]) {
            'O' {$password[$i] = 'o'; Write-Verbose 'Changed "O" to "o"'}
            'I' {$password[$i] = 'i'; Write-Verbose 'Changed "I" to "i"'}
        }
    }

    # replace last character(s) with random numbers
    if ($IncludeNumbers) {
        if ($Length -lt 8) {
            Write-Verbose 'Replacing the last character with a random number'
            $password[-1] = (Get-Random -Minimum 0 -Maximum 9).ToString()
        }
        elseif ($Length -lt 20) {
            Write-Verbose 'Replacing the last two characters with random numbers'
            $password[-2] = (Get-Random -Minimum 0 -Maximum 9).ToString()
            $password[-1] = (Get-Random -Minimum 0 -Maximum 9).ToString()
        }
        else {
            Write-Verbose 'Replacing the last three characters with random numbers'
            $password[-3] = (Get-Random -Minimum 0 -Maximum 9).ToString()
            $password[-2] = (Get-Random -Minimum 0 -Maximum 9).ToString()
            $password[-1] = (Get-Random -Minimum 0 -Maximum 9).ToString()
        }
    }

    Write-Output $password.ToString()
}

function New-ComplexPassword {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateRange(4,[int]::MaxValue)]
        [int] $Length = 12,

        [Parameter()]
        [Alias('Symbols')]
        [switch] $IncludeSymbols = $true,

        [Parameter()]
        [Alias('Numbers')]
        [switch] $IncludeNumbers = $true,

        [Parameter()]
        [Alias('Uppercase')]
        [switch] $IncludeUppercaseCharacters = $true,

        [Parameter()]
        [Alias('Lowercase')]
        [switch] $IncludeLowercaseCharacters = $true,

        [Parameter()]
        [Alias('StartWith')]
        [ValidateSet('Any','Letter','Number')]
        [string] $AlwaysStartWith = 'Any'
    )

    # if for some strange reason the user have disabled using any character groups, give them a funny warning and break
    if (!$IncludeSymbols -and !$IncludeNumbers -and !$IncludeUppercaseCharacters -and !$IncludeLowercaseCharacters) {
        Write-Warning 'Since you have indicated that you want to generate a password consisting of just thin air, here you go:'
        break
    }

    # the different character sets used in generating passwords
    $symbols = '!#%+:=?@'
    $numbers = '23456789'
    $uppercase = 'ABCDEFGHJKLMNPRSTUVWXYZ'
    $lowercase = 'abcdefghijkmnopqrstuvwxyz'

    # based on the parameters used create the character arrays we need
    if ($IncludeSymbols) { $charSetAll += $symbols }
    if ($IncludeNumbers) { $charSetAll += $numbers }
    if ($IncludeUppercaseCharacters) { $charSetAll += $uppercase; $charSetLetters += $uppercase }
    if ($IncludeLowercaseCharacters) { $charSetAll += $lowercase; $charSetLetters += $lowercase }

    # generate a byte array to hold our random numbers
    $byteArray = New-Object -TypeName System.Byte[] -ArgumentList $Length

    # create the RNG and fill the byte array with random numbers
    $rng = New-Object -TypeName System.Security.Cryptography.RNGCryptoServiceProvider
    $rng.GetBytes($byteArray)

    # create our password string object
    $password = New-Object System.Text.StringBuilder -ArgumentList $Length

    for ($i = 0; $i -lt $Length; $i++) {
        # handle first character
        if ($i -eq 0) {
            if ($AlwaysStartWith -eq 'Number') {
                Write-Verbose 'Making sure that the first character in the password is a number'
                if ($IncludeNumbers) { [void]$password.Append(($numbers[$byteArray[$i] % $numbers.Length])) }
                else { Write-Warning 'You can''t have a password that starts with a number without including numbers in the generated password!' ;break }
            }
            elseif ($AlwaysStartWith -eq 'Letter') {
                Write-Verbose 'Making sure that the first character in the password is a letter'
                if ($IncludeUppercaseCharacters -or $IncludeLowercaseCharacters) { [void]$password.Append(($charSetLetters[$byteArray[$i] % $charSetLetters.Length])) }
                else { Write-Warning 'You can''t have a password that starts with a characters without including any characters in the generated password!' ;break }
            }
            else { [void]$password.Append(($charSetAll[$byteArray[$i] % $charSetAll.Length])) }
        }
        # the rest of the characters
        else { [void]$password.Append(($charSetAll[$byteArray[$i] % $charSetAll.Length])) }
    }

    if ($password.Length -eq $Length) {
        $verifyUpdateParameters = @{
            Password = $password
            IncludeSymbols = $IncludeSymbols
            IncludeNumbers = $IncludeNumbers
            IncludeUppercaseCharacters = $IncludeUppercaseCharacters
            IncludeLowercaseCharacters = $IncludeLowercaseCharacters
            Symbols = $symbols
            Numbers = $numbers
            UppercaseCharacters = $uppercase
            LowercaseCharacters = $lowercase
        }
        # before we return the generated password we need to make sure that it includes
        # at least one character from each choosen character group
        # this loop and helper function will randomly replace characters until they
        # meet the complexity rules specified by the user
        if (-not (Invoke-VerifyAndUpdatePasswordComplexity @verifyUpdateParameters)){
            do {
                Write-Verbose 'Password don''t meet complexity rules - updating password'
                $password = Invoke-VerifyAndUpdatePasswordComplexity @verifyUpdateParameters -UpdatePassword
            } until (Invoke-VerifyAndUpdatePasswordComplexity @verifyUpdateParameters)
        }
    }

    Write-Output $password.ToString()
}

function New-Password {
    <#
        .SYNOPSIS
            Generate complex password(s).
        .DESCRIPTION
            This functions lets you generate either random passwords of the
            choosen complexity and length, or pronounceable passwords.
        .EXAMPLE
            New-Password
            Will generate a random password.
        .EXAMPLE
            New-Password -Length 20
            Will generate a random password 20 characters in length.
        .EXAMPLE
            New-Password -Min 12 -Max 20 -IncludeSymbols:$false -AlwaysStartWith Letter
            Will generate a password between 12 and 20 characters in length, that don't include symbols
            but that always starts with a letter.
        .EXAMPLE
            New-Password -Type Pronounceable -Amount 10
            Will generate 10 pronounceable passwords.
        .NOTES
            Author: Øyvind Kallstad
            Date: 19.09.2015
            Version: 1.2
        .OUTPUTS
            System.String
            System.Security.SecureString
        .LINK
            https://communary.wordpress.com/
    #>
    [CmdletBinding(DefaultParameterSetName = 'FixedLength')]
    param (
        # Specifies the length of the generated password.
        [Parameter(ParameterSetName = 'FixedLength')]
        [ValidateRange(4,[int]::MaxValue)]
        [int] $Length = 12,

        # Specifies a minimum length of the generated password.
        [Parameter(ParameterSetName = 'VariableLength')]
        [ValidateRange(4,[int]::MaxValue)]
        [int] $MinimumPasswordLength = 12,

        # Specifies a maximum length of the generated password.
        [Parameter(ParameterSetName = 'VariableLength')]
        [ValidateScript({if ($_ -lt $MinimumPasswordLength) {Throw "Maximum password length must larger than or equal to $MinimumPasswordLength"} else {$true}})]
        [int] $MaximumPasswordLength = 14,

        # The type of passwords being generated. Valid values are 'Complex' and 'Pronounceable'.
        [Parameter()]
        [ValidateSet('Complex','Pronounceable')]
        [string] $Type = 'Complex',

        # Specifies how many generated passwords are returned.
        [Parameter()]
        [Alias('Count')]
        [ValidateRange(1,[int]::MaxValue)]
        [int] $Amount = 1,

        # Include symbols in the generated password. Note that symbols are not
        # implemented for pronounceable passwords yet.
        [Parameter()]
        [Alias('Symbols')]
        [switch] $IncludeSymbols = $true,

        # Include numbers in the generated password.
        [Parameter()]
        [Alias('Numbers')]
        [switch] $IncludeNumbers = $true,

        # Include uppercase characters in the generated password.
        [Parameter()]
        [Alias('Uppercase')]
        [switch] $IncludeUppercaseCharacters = $true,

        # Include lowercase characters in the generated password.
        [Parameter()]
        [Alias('Lowercase')]
        [switch] $IncludeLowercaseCharacters = $true,

        # Force the generated password to start with a letter or a number.
        [Parameter()]
        [Alias('StartWith')]
        [ValidateSet('Any','Letter','Number')]
        [string] $AlwaysStartWith = 'Any',

        # Output will be a SecureString object instead of a string.
        [Parameter()]
        [switch] $AsSecureString
    )

    # display a warning if trying to generate weak passwords
    $warningThreshold = 12
    if (($Length -lt $warningThreshold) -or ($MinimumPasswordLength -lt $warningThreshold)) {
        Write-Warning "Passwords with a length of less than $warningThreshold characters are not very secure! Please consider generating longer passwords."
    }

    # display warning regarding pronounceable passwords and symbols
    if (($Type -eq 'Pronounceable') -and ($IncludeSymbols)) {
        Write-Warning 'Pronounceable passwords will be generated without symbols.'
    }

    for ($i = 1; $i -le $Amount; $i++) {
        if ($PSCmdlet.ParameterSetName -eq 'VariableLength') {
            # if min and max password length are equal just use one of them
            if ($MinimumPasswordLength -eq $MaximumPasswordLength) {
                $Length = $MinimumPasswordLength
            }
            # else randomize the password length based on the min and max values
            # we use Get-Random here for simplicity, and the length of the password hardly needs
            # to be calculated using a cryptographically secure method :)
            else {
                $Length = Get-Random -Minimum $MinimumPasswordLength -Maximum $MaximumPasswordLength
            }
        }

        switch ($Type) {
            'Complex' {$passwordString = New-ComplexPassword -Length $Length -IncludeSymbols:$IncludeSymbols -IncludeNumbers:$IncludeNumbers -IncludeUppercaseCharacters:$IncludeUppercaseCharacters -IncludeLowercaseCharacters:$IncludeLowercaseCharacters -AlwaysStartWith $AlwaysStartWith}
            'Pronounceable' {$passwordString = New-PronounceablePassword -Length $Length -IncludeNumbers:$IncludeNumbers -IncludeUppercaseCharacters:$IncludeUppercaseCharacters}
        }

        if ($AsSecureString) {
            $secureString = ConvertTo-SecureString -String $passwordString -AsPlainText -Force
            Write-Output $secureString
        }
        else {
            Write-Output $passwordString
        }
    }
}