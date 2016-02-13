Add-Type -MemberDefinition @'
[DllImport("crypt32.dll", CharSet = CharSet.Auto, SetLastError = true)]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool CryptStringToBinary(
    [MarshalAs(UnmanagedType.LPWStr)] string pszString,
    uint cchString,
    CRYPT_STRING_FLAGS dwFlags,
    byte[] pbBinary,
    ref uint pcbBinary,
    uint pdwSkip,
    ref uint pdwFlags);
[DllImport("Crypt32.dll", CharSet = CharSet.Auto, SetLastError = true)]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool CryptBinaryToString(
    byte[] pbBinary,
    uint cbBinary,
    CRYPT_STRING_FLAGS dwFlags,
    StringBuilder pszString,
    ref int pcchString);
[System.Flags]
public enum CRYPT_STRING_FLAGS: uint
{
    // Base64, with certificate beginning and ending headers.
    Base64Header = 0x00000000,
    // Base64, without headers.
    Base64 = 0x00000001,
    // Pure binary copy.
    Binary = 0x00000002,
    // Base64, with request beginning and ending headers.
    Base64RequestHeader = 0x00000003,
    // Hexadecimal only format.
    Hex = 0x00000004,
    // Hexadecimal format with ASCII character display.
    HexASCII = 0x00000005,
    // Tries the following, in order: Base64Header, Base64
    Base64Any = 0x00000006,
    // Tries the following, in order: Base64Header, Base64, Binary
    Any = 0x00000007,
    // Tries the following, in order: HexAddr, HexASCIIAddr, Hex, HexRaw, HexASCII
    HexAny = 0x00000008,
    // Base64, with X.509 certificate revocation list (CRL) beginning and ending headers.
    Base64X509ClrHeader = 0x00000009,
    // Hex, with address display.
    HexAddr = 0x0000000a,
    // Hex, with ASCII character and address display.
    HexASCIIAddr = 0x0000000b,
    // A raw hexadecimal string. Windows Server 2003 and Windows XP:  This value is not supported.
    HexRaw = 0x0000000c,
    // Set this flag for Base64 data to specify that the end of the binary data contain only white space and at most three equals "=" signs.
    // Windows Server 2008, Windows Vista, Windows Server 2003, and Windows XP:  This value is not supported.
    Strict = 0x20000000,
    // Do not append any new line characters to the encoded string. The default behavior is to use a carriage return/line feed (CR/LF) pair (0x0D/0x0A) to represent a new line.
    // Windows Server 2003 and Windows XP:  This value is not supported.
    NoCrLf = 0x40000000,
    // Only use the line feed (LF) character (0x0A) for a new line. The default behavior is to use a CR/LF pair (0x0D/0x0A) to represent a new line.
    NoCr = 0x80000000
}
'@ -Namespace 'Win32' -Name 'Native' -UsingNamespace 'System.Text'

function Invoke-CryptStringToBinary {
    <#
        .SYNOPSIS
            Wrapper for the Win32 native function CryptStringToBinary.
        .DESCRIPTION
            The CryptStringToBinary function converts a formatted string into an array of bytes.
        .EXAMPLE
            Invoke-CryptStringToBinary -InputString $string -Format HexAny
        .INPUTS
            System.String
        .OUTPUTS
            System.Array
        .NOTES
            NOTE! This function is based on the work of Vadims Podāns (https://www.sysadmins.lv/blog-en/convert-data-between-binary-hex-and-base64-in-powershell.aspx)
            Author: Øyvind Kallstad
            Date: 08.02.2016
            Version: 1.0
        .LINK
            https://www.sysadmins.lv/blog-en/convert-data-between-binary-hex-and-base64-in-powershell.aspx
        .LINK
            https://msdn.microsoft.com/en-us/library/windows/desktop/aa380285(v=vs.85).aspx
        .LINK
            https://communary.wordpress.com/
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [Alias('String')]
        [ValidateNotNullOrEmpty()]
        [string] $InputString,

        # Indicates the format of the string to be converted.
        [Parameter(Mandatory = $true)]
        [Win32.Native+CRYPT_STRING_FLAGS] $Format
    )

    # Will hold the size of the byte array
    $pcbBinary = 0

    # Will hold the actual flags used in the conversion
    $pwdFlags = 0

    # Call native method to convert
    if ([Win32.Native]::CryptStringToBinary($InputString, $InputString.Length, $Format, $null, [ref]$pcbBinary, 0, [ref]$pwdFlags)) {
        $outputArray = New-Object -TypeName byte[] -ArgumentList $pcbBinary
        [void][Win32.Native]::CryptStringToBinary($InputString, $InputString.Length, $Format, $outputArray, [ref]$pcbBinary, 0, [ref]$pwdFlags)
        Write-Output $outputArray
    }

    else {
        Write-Warning $((New-Object ComponentModel.Win32Exception ([Runtime.InteropServices.Marshal]::GetLastWin32Error())).Message)
    }
}

function Invoke-CryptBinaryToString {
    <#
        .SYNOPSIS
            Wrapper for the Win32 native function CryptBinaryToString.
        .DESCRIPTION
            The CryptBinaryToString function converts an array of bytes into a formatted string.
        .EXAMPLE
            Invoke-CryptBinaryToString $array -Format HexASCIIAddr
        .INPUTS
            System.Array
        .OUTPUTS
            System.String
        .NOTES
            NOTE! This function is based on the work of Vadims Podāns (https://www.sysadmins.lv/blog-en/convert-data-between-binary-hex-and-base64-in-powershell.aspx)
            Author: Øyvind Kallstad
            Date: 08.02.2016
            Version: 1.0
        .LINK
            https://www.sysadmins.lv/blog-en/convert-data-between-binary-hex-and-base64-in-powershell.aspx
        .LINK
            https://msdn.microsoft.com/en-us/library/windows/desktop/aa379887(v=vs.85).aspx
        .LINK
            https://communary.wordpress.com/
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [byte[]] $InputObject,

        # Specifies the format of the resulting formatted string.
        [Parameter(Mandatory = $true)]
        [Win32.Native+CRYPT_STRING_FLAGS] $Format,

        # Do not append any new line characters to the encoded string. The default behavior is to use a carriage return/line feed (CR/LF) pair to represent a new line.
        [Parameter()]
        [switch] $NoCrLf,

        # Only use the line feed (LF) character for a new line. The default behavior is to use a CR/LF pair to represent a new line.
        [Parameter()]
        [switch] $NoCr
    )

    BEGIN {
        [Win32.Native+CRYPT_STRING_FLAGS]$formatFlags = $Format

        if ($NoCrLf) {
            $formatFlags = $formatFlags -bor [Win32.Native+CRYPT_STRING_FLAGS]::NoCrLf
        }

        if ($NoCr) {
            $formatFlags = $formatFlags -bor [Win32.Native+CRYPT_STRING_FLAGS]::NoCr
        }

        # Will hold the size of the output string
        $pcchString = 0

        # Silly workaround to support input from the pipeline
        # We need to catch all items of the pipeline into a temporary array
        $tempArray = New-Object -TypeName System.Collections.ArrayList
    }

    PROCESS {
        foreach ($input in $InputObject) {
            [void]$tempArray.Add($input)
        }
    }

    END {
        # Convert the temp array to a byte array
        [byte[]]$byteArray = $tempArray.ToArray([byte])

        # Call native method to convert
        if ([Win32.Native]::CryptBinaryToString($byteArray, $byteArray.Length,$formatFlags, $null, [ref]$pcchString)) {
            $outputString = New-Object -TypeName System.Text.StringBuilder -ArgumentList $pcchString
            [void][Win32.Native]::CryptBinaryToString($byteArray, $byteArray.Length, $formatFlags, $outputString, [ref]$pcchString)
            Write-Output $outputString.ToString()
        }

        else {
            Write-Warning $((New-Object ComponentModel.Win32Exception ([Runtime.InteropServices.Marshal]::GetLastWin32Error())).Message)
        }
    }
}

function Measure-Frequency {
    <#
        .SYNOPSIS
            Get the frequency distribution of a set.
        .DESCRIPTION
            This function will get the frequency distribution of a set (array) of data.
            It supports array types, as well as strings.
        .EXAMPLE
            Measure-Frequency $array
        .EXAMPLE
            Measure-Frequency $string -CaseSensitive
        .NOTES
            Author: Øyvind Kallstad
            Date: 10.02.2016
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        $InputObject,

        [Parameter()]
        [switch] $CaseSensitive
    )

    try {
        if ($InputObject.GetType().Name -eq 'String') {
            if ($CaseSensitive) {
                $inputArray = $InputObject.ToCharArray()
            }
            else {
                $inputArray = $InputObject.ToLower().ToCharArray()
            }
        }

        else {
            $inputArray = $InputObject
        }

        $inputArray | Group-Object | Sort-Object -Descending -Property Count | ForEach-Object {

            $frequency = $_.Count / $inputArray.Length
            $percent = '{0:P0}' -f $frequency

            Write-Output ([PSCustomObject] [Ordered] @{
                Value = $_.Name
                Count = $_.Count
                Percent = $percent
                Frequency = $frequency
            })
        }
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}

function Remove-Characters {
    <#
        .SYNOPSIS
            Remove characters from a string.
        .DESCRIPTION
            This function will take an array of characters, and will remove
            those characters from the input string.
        .EXAMPLE
            $myString | Remove-Characters
            This will remove all 'default' characters from myString.
        .EXAMPLE
            Remove-Characters -InputString $myString -Remove ([char[]](0..47 + 58..64 + 91..96 + 123..255 | ForEach-Object {[char]$_}))
            This will remove all characters in the ASCII table except letters and numbers.
        .EXAMPLE
            Remove-Characters -InputString $myString -Remove ([char[]](0..47 + 58..64 + 91..96 + 123..[int][char]::MaxValue | ForEach-Object {[char]$_}))
            This will remove all special characters with the exception of letters and numbers. NOTE This one is a bit slower than the other two examples.
        .INPUTS
            System.String
        .OUTPUTS
            System.String
        .LINK
            https://communary.wordpress.com/
        .NOTES
            This code was translated and adapted from this StackOverflow answer: http://stackoverflow.com/a/1120407/3940558
            Author: Øyvind Kallstad
            Date: 11.02.2016
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $InputString,

        # Characters to remove. Default value is '!"#¤%&€/()=?`+[]{}@£$\¨^~*-_.:,;<> '
        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [char[]] $Remove = '!"#¤%&€/()=?`+[]{}@£$\¨^~*-_.:,;<> '
    )

    [char[]]$buffer = New-Object -TypeName System.Char[] -ArgumentList $InputString.Length
    $index = 0

    foreach ($character in $InputString.ToCharArray()) {
        if (-not ($Remove -contains $character)) {
            $buffer[$index] = $character
            $index++
        }
    }

    Write-Output (New-Object -TypeName System.String -ArgumentList ($buffer,0,$index))
}

function Get-Entropy {
    <#
        .SYNOPSIS
            Calculate the entropy of a data set.
        .DESCRIPTION
            This function will calculate either the Shannon Entropy, or the
            Metric Entropy of a data set.
        .EXAMPLE
            Get-Entropy -InputObject $myArray
            Calculate the Shannon Entropy in the data in the myArray array.
        .EXAMPLE
            Get-Entropy -InputObject $myString -MetricEntropy
            Calculate the Metric Entropy of the string in the myString variable.
        .INPUTS
            System.String
            System.Array
        .OUTPUTS
            System.Double
        .NOTES
            Author: Øyvind Kallstad
            Date: 12.02.2016
            Version: 1.0
        .LINK
            https://en.wikipedia.org/wiki/Entropy_%28information_theory%29
            https://communary.wordpress.com/
    #>
    [CmdletBinding()]
    param (
        # A string or an array to calculate the entropy of.
        [Parameter(Mandatory = $true, Position = 0)]
        $InputObject,

        # If the input is a string, keep it case sensitive.
        [Parameter()]
        [switch] $CaseSensitive,

        # Metric Entropy will help you assess the randomness of the input. It will return
        # a value between 0 and 1, where 1 means that the data is equally distributed.
        [Parameter()]
        [switch] $MetricEntropy
    )

    try {
        if ($InputObject.Length -gt 1) {
            if ((-not($CaseSensitive)) -and ($InputObject.GetType().Name -eq 'String')) {
                $InputObject = $InputObject.ToLower()
            }

            # create a frequency array, counting each occurence of every element in the input array
            $frequencyArray = @{}
            foreach ($item in $inputObject.GetEnumerator()) {
                $frequencyArray[$item]++
            }

            $entropy = 0.0
            foreach ($item in $frequencyArray.GetEnumerator()) {
                # calculate the probability distribution by dividing the frequency with the total size of the data set
                $probabilityDistribution = $item.Value / $inputObject.Length
                # calculate the entropy by using the Shannon Entropy algorithm
                $entropy += $probabilityDistribution * [Math]::Log((1/$probabilityDistribution),2)
            }

            if ($MetricEntropy) {
                # calculate Metric Entropy by dividing the Shannon Entropy with the total size of the data set
                Write-Output ($entropy / $inputObject.Length)
            }
            else {
                Write-Output $entropy
            }
        }
        else {
            Write-Warning 'Size of data set is too small.'
        }
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}

function ConvertTo-Bytes {
    <#
        .SYNOPSIS
            Convert a string to bytes.
        .NOTES
            Author: Øyvind Kallstad
            Date: 13.02.2016
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        # String to convert to bytes.
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Alias('String')]
        [string] $InputString,

        # Text encoding to use. Valid values are 'Default','ASCII','BigEndianUnicode','Unicode','UTF32','UTF7' and'UTF8'.
        # Default value is 'Default'.
        [Parameter()]
        [ValidateSet('Default','ASCII','BigEndianUnicode','Unicode','UTF32','UTF7','UTF8')]
        [string] $Encoding = 'Default'
    )
    Write-output ([System.Text.Encoding]::$Encoding.GetBytes($InputString))
}

function Invoke-RepeatingKeyXOR {
    # http://cryptopals.com/sets/1/challenges/5/
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('String')]
        [string] $InputString,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string] $Key
    )

    try {
        $binaryString = $inputString | ConvertTo-Bytes
        $keyBinary = $Key | ConvertTo-Bytes

        $outputBytes = New-Object -TypeName System.Collections.ArrayList

        $keyIndex = 0
        foreach ($byte in $binaryString) {
            [void]$outputBytes.Add((($byte -bxor $keyBinary[$keyIndex])))
            $keyIndex++
            if ($keyIndex -gt ($keyBinary.Length - 1)) {
                $keyIndex = 0
            }
        }

        (Invoke-CryptBinaryToString -InputObject $outputBytes -Format Hex -NoCrLf).Replace(' ','') -join ''
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}

function Invoke-FixedXOR {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [byte[]] $ByteArrayOne,

        [Parameter(Mandatory = $true, Position = 1)]
        [byte[]] $ByteArrayTwo
    )
    $combinedBytes = New-Object System.Collections.ArrayList

    if ($ByteArrayOne.Length -eq $ByteArrayTwo.Length) {

        for ($index = 0; $index -lt $ByteArrayOne.Length; $index++) {
            [void]$combinedBytes.Add(($ByteArrayOne[$index] -bxor $ByteArrayTwo[$index]))
        }

        Write-Output $combinedBytes
    }
    else {
        Write-Warning 'Different length!'
    }
}

function ConvertTo-BinaryString {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 0)]
        [array] $InputObject,

        [Parameter()]
        [switch] $Pad
    )

    PROCESS {
        foreach ($item in $InputObject) {
            if ($item.GetType().Name -eq 'string') {
                [System.Text.Encoding]::ASCII.GetBytes($item) | ForEach-Object {
                    if ($Pad) {
                        Write-Output (([System.Convert]::ToString($_,2)).PadLeft(8,'0'))
                    }
                    else {
                        Write-Output ([System.Convert]::ToString($_,2))
                    }

                }
            }
            else {
                if ($Pad) {
                    Write-Output (([System.Convert]::ToString($item,2)).PadLeft(8,'0'))
                }
                else {
                    Write-Output ([System.Convert]::ToString($item,2))
                }

            }
        }
    }
}

function ConvertTo-HexString {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 0)]
        [byte[]] $InputObject
    )

    BEGIN {
        $outString = New-Object -TypeName System.Text.StringBuilder
    }

    PROCESS {
        foreach ($byte in $InputObject) {
            [void]$outString.AppendFormat('{0:x2}', $byte)
        }
    }

    END {
        Write-Output $outString.ToString()
    }
}

function ConvertTo-StringArray {
    <#
        .SYNOPSIS
            Split a string on newline to produce a string array.
        .NOTES
            Author: Øyvind Kallstad
            Date: 07.01.2016
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [string] $InputString
    )

    Write-Output ($InputString -Split '\r\n')
}

function Get-Square {
    param([double]$Number)
    $n = [math]::Abs($Number)
    Write-Output ($n * $n)
}

#https://en.wikipedia.org/wiki/Root_mean_square
function Get-RootMeanSquare {
    param ([double[]]$NumberSet)
    $squaredNumberSet = New-Object System.Collections.ArrayList
    foreach ($number in $NumberSet) {
        [void]$squaredNumberSet.Add((Get-Square $number))
    }
    Write-Output ([math]::Sqrt((($squaredNumberSet | Measure-Object -Average).Average)))
}

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

function Get-Variance {
    <#
        .SYNOPSIS
            Get the variance of a set of numbers.
        .LINK
            http://en.wikipedia.org/wiki/Variance
        .NOTES
            Author: Øyvind Kallstad
            Date: 03.06.2015
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [double[]] $Set,

        # Choose the variance type; Population Variance or Sample Variance. Default value is 'Population'.
        [Parameter()]
        [ValidateSet('Population','Sample')]
        [string] $Type = 'Population'
    )

    [double]$mean = ($Set | Measure-Object -Average).Average

    foreach ($double in $Set) {
        $squaredDeviations += ,(($double - $mean) * ($double - $mean))
    }

    foreach ($squaredDeviation in $squaredDeviations) {
        $variance += $squaredDeviation
    }

    switch ($Type) {
        'Population' { $output = $variance / $Set.Count }
        'Sample' { $output = $variance / ($Set.Count - 1) }
    }

    Write-Output $output
}

function Get-StandardDeviation {
    <#
        .SYNOPSIS
            Get the standard variation of a set of numbers.
        .LINK
            http://en.wikipedia.org/wiki/Standard_deviation
        .NOTES
            Author: Øyvind Kallstad
            Date: 03.06.2015
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [double[]] $Set,

        [Parameter()]
        [ValidateSet('Population','Sample')]
        [string] $Type = 'Population'
    )

    $variance = Get-Variance $Set -Type $Type
    [math]::Sqrt($variance)
}

function Get-Permutation {
    <#
        .SYNOPSIS
            Get k permutations of n.
        .DESCRIPTION
            Get k permutations of n.
        .EXAMPLE
            Get-Permutation 6 3
        .LINK
            http://en.wikipedia.org/wiki/Permutation
        .NOTES
            Author: Øyvind Kallstad
            Date: 23.05.2015
            Version: 1.0
            Dependencies: Get-Factorial, Get-LogGamma
    #>
    param (
        [ValidateRange(0,[int]::MaxValue)]
        [int] $n,

        [ValidateRange(0,[int]::MaxValue)]
        [int] $k,

        # Choose the method used to calculate permutations.
        [ValidateSet('Factorial','LogGamma')]
        [string] $Method = 'LogGamma'
    )

    switch ($Method) {
        'Factorial' { (Get-Factorial $n) / (Get-Factorial ($n - $k)) }
        'LogGamma' { [math]::Round([math]::Exp((Get-LogGamma ($n + 1)) - (Get-LogGamma ($n - $k + 1)))) }
    }
}

function Get-BinomialCoefficient {
    <#
        .SYNOPSIS
            Get the binomial coefficient between two positive integers.
        .DESCRIPTION
            In mathematics, binomial coefficients are a family of positive integers that occur as coefficients in the binomial theorem.
        .EXAMPLE
            Get-BinomialCoefficient 49 6
        .LINK
            http://en.wikipedia.org/wiki/Binomial_coefficient
        .NOTES
            Author: Øyvind Kallstad
            Date: 23.05.2015
            Version: 1.0
            Dependencies: Get-Factorial, Get-LogGamma
    #>
    param (
        [ValidateRange(0,[int]::MaxValue)]
        [int] $n,

        [ValidateRange(0,[int]::MaxValue)]
        [int] $k,

        # Choose the method used to calculate the binomial coefficient.
        [ValidateSet('Factorial','LogGamma')]
        [string] $Method = 'LogGamma'
    )

    switch ($Method) {
        'Factorial' { (Get-Factorial $n) / ((Get-Factorial $k) * (Get-Factorial ($n - $k))) }
        'LogGamma' { [math]::Round([math]::Exp((Get-LogGamma ($n + 1)) - (Get-LogGamma ($k + 1)) - (Get-LogGamma ($n - $k + 1)))) }
    }
}

function Get-LogGamma {
    <#
        .SYNOPSIS
        .DESCRIPTION
        .EXAMPLE
            Get-LogGamma 10
        .LINK
            http://www.johndcook.com/Gamma.cs
            http://www.johndcook.com/stand_alone_code.html
        .NOTES
            Author: Øyvind Kallstad (translated from code by John D. Cook)
            Date: 23.05.2015
            Version: 1.0
            Dependencies: Get-Gamma
    #>
    param (
        [ValidateRange(0,[double]::MaxValue)]
        [double] $x
    )

    if ($x -lt 12.0) {
        return ([math]::Log([math]::Abs((Get-Gamma -x $x))))
    }

    # Abramowitz and Stegun 6.1.41
    # Asymptotic series should be good to at least 11 or 12 figures
    # For error analysis, see Whittiker and Watson
    # A Course in Modern Analysis (1927), page 252

    [double[]] $c = (
        (1.0/12.0),
        (-1.0/360.0),
        (1.0/1260.0),
        (-1.0/1680.0),
        (1.0/1188.0),
        (-691.0/360360.0),
        (1.0/156.0),
        (-3617.0/122400.0)
    )
    [double] $z = 1.0 / ($x * $x)
    [double] $sum = $c[7]

    for ($i = 6; $i -ge 0; $i--) {
        $sum *= $z
        $sum += $c[$i]
    }

    [double] $series = $sum / $x
    [double] $halfLogTwoPi = 0.91893853320467274178032973640562
    [double] $logGamma = ($x - 0.5) * [math]::Log($x) - $x + $halfLogTwoPi + $series
    return $logGamma
}

function Get-Gamma {
    <#
        .SYNOPSIS
        .DESCRIPTION
        .EXAMPLE
            Get-Gamma 4
        .LINK
            http://www.johndcook.com/Gamma.cs
            http://www.johndcook.com/stand_alone_code.html
            http://en.wikipedia.org/wiki/Gamma_function
        .NOTES
            Author: Øyvind Kallstad (translated from code by John D. Cook)
            Date: 23.05.2015
            Version: 1.0
            Dependencies: Get-LogGamma
    #>
    param (
        [ValidateRange(0,[double]::MaxValue)]
        [double] $x
    )

    # First interval: (0, 0.001)

    # Euler's gamma constant
    [double]$gamma = 0.577215664901532860606512090

    if ($x -lt 0.001) {
        return (1.0 / ($x * (1.0 + $gamma * $x)))
    }

    # Second interval: (0.001, 12)

    if ($x -lt 12.0) {

        # The algorithm directly approximates gamma over (1,2) and uses
        # reduction identities to reduce other arguments to this interval.

        [double] $y = $x
        [int]$n = 0
        [bool]$argumentWasLessThanOne = ($y -lt 1.0)

        # Add or subtract integers as necessary to bring y into (1,2)
        # Will correct for this below
        if ($argumentWasLessThanOne) {
            $y += 1.0
        }
        else {
            $n = [int]([math]::Floor($y) - 1)
            $y -= $n
        }

        # numerator coefficients for approximation over the interval (1,2)
        [double[]] $p = (
           -1.71618513886549492533811E+0,
            2.47656508055759199108314E+1,
           -3.79804256470945635097577E+2,
            6.29331155312818442661052E+2,
            8.66966202790413211295064E+2,
           -3.14512729688483675254357E+4,
           -3.61444134186911729807069E+4,
            6.64561438202405440627855E+4
        )

        # denominator coefficients for approximation over the interval (1,2)
        [double[]] $q = (
           -3.08402300119738975254353E+1,
            3.15350626979604161529144E+2,
           -1.01515636749021914166146E+3,
           -3.10777167157231109440444E+3,
            2.25381184209801510330112E+4,
            4.75584627752788110767815E+3,
           -1.34659959864969306392456E+5,
           -1.15132259675553483497211E+5
        )

        [double] $num = 0.0
        [double] $den = 1.0
        [double] $z = $y - 1

        for ($i = 0; $i -lt 8; $i++) {
            $num = ($num + $p[$i]) * $z
            $den = $den * $z + $q[$i]
        }
        [double] $results = $num / $den + 1.0

        # Apply correction if argument was not initially in (1,2)
        if ($argumentWasLessThanOne) {
            # Use identity gamma(z) = gamma(z+1)/z
            # The variable "result" now holds gamma of the original y + 1
            # Thus we use y-1 to get back the orginal y.
            $results /= ($y - 1.0)
        }
        else {
            # Use the identity gamma(z+n) = z*(z+1)* ... *(z+n-1)*gamma(z)
            for ($i = 0; $i -lt $n; $i++) {
                $results *= $y++
            }
        }

        return $results
    }

    # Third interval: (12, infinity)

    if ($x -gt 171.624) {
        # Correct answer too large to display.
        return ([double]::PositiveInfinity)
    }

    return ([math]::Exp((Get-LogGamma $x)))
}

function ConvertTo-Radians {
    param (
        [Parameter(ValueFromPipeline)]
        [double] $Degrees
    )
    Write-Output (([math]::PI * $Degrees) / 180.0)
}

function Get-Sine {
    param (
        [double] $Angle
    )
    Write-Output (([math]::Sin(($Angle | ConvertTo-Radians))))
}

function Get-Union {
    <#
        .SYNOPSIS
            Get the union of two sets.
        .DESCRIPTION
            This function returns all distinct elements of two sets, also called the union of two sets.
        .EXAMPLE
            Get-Union (1,10,2,1) (1,2,3)
        .EXAMPLE
            Get-Union 'John' 'Ronny'
        .EXAMPLE
            Get-Union 'Jon' 'jon' -CaseSensitive
        .LINK
            http://en.wikipedia.org/wiki/Union_%28set_theory%29
        .NOTES
            Author: Øyvind Kallstad
            Date: 21.05.2015
            Version: 1.0
    #>
    [OutputType([System.Array])]
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        $Set1,

        [Parameter(Position = 1, Mandatory)]
        $Set2,

        # Makes string unions case sensitive.
        [Parameter()]
        [switch] $CaseSensitive
    )

    try {
        # if sets are strings, convert to array of chars
        if ($Set1 -is [string]) {
            if (-not($CaseSensitive)) {
                $Set1 = $Set1.ToLowerInvariant()
            }
            $Set1 = $Set1.ToCharArray()
        }
        if ($Set2 -is [string]) {
            if (-not($CaseSensitive)) {
                $Set2 = $Set2.ToLowerInvariant()
            }
            $Set2 = $Set2.ToCharArray()
        }

        # check that the sets are arrays
        if (-not($set1.GetType().IsArray) -or -not($Set2.GetType().IsArray)) {
            Write-Warning 'Oops! Input must be arrays!'
            break
        }

        # get the types of the elements in the sets
        $arrayTypesSet1 = Get-TypeName $Set1
        $arrayTypesSet2 = Get-TypeName $Set2

        # check that the sets do not contain mixed types
        if (($arrayTypesSet1 -is [array]) -and ($arrayTypesSet2 -is [array])) {
            Write-Warning 'Oops! One, or both, of the sets contain mixed types!'
            break
        }

        # check that the sets contain the same type
        if ($arrayTypesSet1 -ne $arrayTypesSet2) {
            Write-Warning 'Oops! The two sets contain different types!'
            break
        }

        # create hash sets
        $hashSet1 = New-Object System.Collections.Generic.HashSet[$arrayTypesSet1] (,($set1 -as "$arrayTypesSet1[]"))
        $hashSet2 = New-Object System.Collections.Generic.HashSet[$arrayTypesSet2] (,($set2 -as "$arrayTypesSet2[]"))

        # get the union between them
        $hashSet1.UnionWith($hashSet2)

        # convert hashset to array and write output to pipeline
        $outputArray = New-Object -TypeName "$arrayTypesSet1[]" ($hashSet1.Count)
        $hashSet1.CopyTo($outputArray)
        Write-Output $outputArray
    }

    catch {
        Write-Warning $_.Exception.Message
    }
}

function Get-TypeName {
    param ($InputObject)
    Write-Output (($InputObject | Get-Member).TypeName | Select-Object -Unique)
}

function Get-CartesianProduct {
    <#
        .SYNOPSIS
            Get the Cartesian Product from two sets.
        .DESCRIPTION
            Get the Cartesian Product from two sets.
        .EXAMPLE
            Get-CartesianProduct (1,2,3) ('one','two','three')
        .LINK
            http://en.wikipedia.org/wiki/Cartesian_product
        .NOTES
            Author: Øyvind Kallstad
            Date: 21.05.2015
            Version: 1.0
    #>
    [OutputType([System.Array])]
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [system.array] $Set1,

        [Parameter(Position = 1)]
        [system.array] $Set2,

        [Parameter()]
        [string] $Divider = ','
    )

    try {
        $outputArray = New-Object -TypeName System.Collections.ArrayList
        foreach ($set1Item in $Set1) {
            foreach ($set2Item in $Set2) {
                [void]$outputArray.Add(($set1Item.ToString() + $Divider + $set2Item.ToString()))
            }
        }
        Write-Output $outputArray
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}

function Test-IsPrime {
    <#
        .SYNOPSIS
            Test if a number is a prime number.
        .DESCRIPTION
            This function uses the Rabin-Miller primality test to check for primality.
        .EXAMPLE
            Test-IsPrime 6461335109
            Returns True.
        .LINK
            http://en.wikipedia.org/wiki/Miller%E2%80%93Rabin_primality_test
            http://rosettacode.org/wiki/Miller-Rabin_primality_test#C.23
        .INPUTS
            bigint
        .NOTES
            This code is translated to PowerShell from code found on rosettacode.
            Author: Øyvind Kallstad
            Date: 11.05.2015
            Version: 1.0
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        # The number you want to check for primality.
        [Parameter(Position = 0, ValueFromPipeline)]
        [bigint]$Number,

        # Determines the accuracy of the test. Default value is 40.
        [Parameter(Position = 1)]
        [ValidateRange(1,[int]::MaxValue)]
        [int]$Iterations = 40
    )

    if ($Number -in 2..3) {
        return $true
    }

    if (($Number -lt 2) -or (($Number % 2) -eq 0)) {
        return $false
    }

    [bigint]$d = $Number - 1
    [int]$s = 0

    while (($d % 2) -eq 0) {
        $d /= 2
        $s += 1
    }

    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    [byte[]] $bytes = $Number.ToByteArray().LongLength
    [bigint]$a = 0

    for ($i = 0; $i -lt $Iterations; $i++) {
        do {
            $rng.GetBytes($bytes)
            $a = [bigint]$bytes
        } while (($a -lt 2) -or ($a -ge ($Number - 2)))

        [bigint]$x = [bigint]::ModPow($a, $d, $Number)
        if (($x -eq 1) -or ($x -eq ($Number - 1))) {
            continue
        }

        for ($r = 1; $r -lt $s; $r++) {
            $x = [bigint]::ModPow($x, 2, $Number)
            if ($x -eq 1) {
                return $false
            }
            if ($x -eq ($Number - 1)) {
                break
            }
        }

        if ($x -ne ($Number - 1)) {
            return $false
        }
    }
    return $true
}

Add-Type -TypeDefinition @"
   public enum PrimeMethods
   {
      Standard,
      SieveOfEratosthenes,
      SieveOfSundaram
   }
"@

function Get-PrimeNumbers {
    <#
        .SYNOPSIS
            Get Prime numbers.
        .DESCRIPTION
            This function will calculate the prime numbers from 2 to the amount specified using the
            Amount parameter. You have a choice of using three different methods to calculate the
            prime numbers; the Standard method, the Sieve Of Eratosthenes or the Sieve Of Sundaram.
        .EXAMPLE
            Get-PrimeNumbers 100
            This will list the first 100 prime numbers.
        .EXAMPLE
            Get-PrimeNumbers 100 -Method 'SieveOfEratosthenes'
            This will list the first 100 prime numbers using the Sieve Of Eratosthenes method.
        .NOTES
            These functions were translated from c# to PowerShell from a post on stackoverflow,
            written/collected by David Johnstone, but other authors were responsible for some of them.
            Author: Øyvind Kallstad
            Date: 09.05.2015
            Version: 1.0
        .LINK
            http://stackoverflow.com/questions/1042902/most-elegant-way-to-generate-prime-numbers
            http://en.wikipedia.org/wiki/Sieve_of_Sundaram
            http://en.wikipedia.org/wiki/Sieve_of_Eratosthenes
            http://en.wikipedia.org/wiki/Prime_number
    #>
    [CmdletBinding()]
    param (
        # The amount of prime numbers to get. The default value is 10.
        [Parameter(Position = 0)]
        [ValidateRange(1,[int]::MaxValue)]
        [int] $Amount = 10,

        # The method used to get the prime numbers. Choices are 'Standard', 'SieveOfEratosthenes' and 'SieveOfSundaram'.
        # The default value is 'Standard'.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [PrimeMethods] $Method = 'Standard'
    )

    function Get-PrimeNumbersStandardMethod {
        param ([int]$Amount)

        $primes = New-Object System.Collections.ArrayList
        [void]$primes.Add(2)
        $nextPrime = 3
        while ($primes.Count -lt $Amount) {
            $squareRoot = [math]::Sqrt($nextPrime)
            $isPrime = $true
            for ($i = 0; $primes[$i] -le $squareRoot; $i++) {
                if (($nextPrime % $primes[$i]) -eq 0) {
                    $isPrime = $false
                    break
                }
            }
            if ($isPrime) {
                [void]$primes.Add($nextPrime)
            }
            $nextPrime += 2
        }
        Write-Output $primes
    }

    function Invoke-ApproximateNthPrime {
        param ([int]$nn)
        [double]$n = $nn
        [double]$p = 0
        if ($nn -ge 7022) {
            $p = $n * [math]::Log($n) + $n * ([math]::Log([math]::Log($n)) - 0.9385)
        }
        elseif ($nn -ge 6) {
            $p = $n * [math]::Log($n) + $n * [math]::Log([math]::Log($n))
        }
        elseif ($nn -gt 0) {
            $p = (2,3,5,7,11)[($nn - 1)]
        }
        Write-Output ([int]$p)
    }

    function Invoke-SieveOfEratosthenes {
        param([int]$Limit)
        $bits = New-Object -TypeName System.Collections.BitArray -ArgumentList (($Limit + 1), $true)
        $bits[0] = $false
        $bits[1] = $false
        for ($i = 0; ($i * $i) -le $Limit; $i++) {
            if ($bits[$i]) {
                for (($j = $i * $i); $j -le $Limit; $j += $i) {
                    $bits[$j] = $false
                }
            }
        }
        Write-Output (,($bits))
    }

    function Invoke-SieveOfSundaram {
        param([int]$Limit)
        $limit /= 2
        $bits = New-Object -TypeName System.Collections.BitArray -ArgumentList (($Limit + 1), $true)
        for ($i = 1; (3 * ($i + 1)) -lt $Limit; $i++) {
            for ($j = 1; ($i + $j + 2 * $i * $j) -le $Limit; $j++) {
                $bits[($i + $j + 2 * $i * $j)] = $false
            }
        }
        Write-Output (,($bits))
    }

    function Get-PrimeNumbersSieveOfEratosthenes {
        param([int]$Amount)
        $limit = Invoke-ApproximateNthPrime $Amount
        [System.Collections.BitArray]$bits = Invoke-SieveOfEratosthenes $limit
        $primes = New-Object System.Collections.ArrayList
        $found = 0
        for ($i = 0; $i -lt $limit -and $found -lt $Amount; $i++) {
            if ($bits[$i]) {
                [void]$primes.Add($i)
                $found++
            }
        }
        Write-Output $primes
    }
    function Get-PrimeNumbersSieveOfSundaram {
        param([int]$Amount)
        $limit = Invoke-ApproximateNthPrime $Amount
        [System.Collections.BitArray]$bits = Invoke-SieveOfSundaram $limit
        $primes = New-Object System.Collections.ArrayList
        [void]$primes.Add(2)
        $found = 1
        for ($i = 1; (2 * ($i + 1)) -le $limit -and $found -lt $Amount; $i++) {
            if ($bits[$i]) {
                [void]$primes.Add((2 * $i + 1))
                $found++
            }
        }
        Write-Output $primes
    }

    switch ($Method) {
        'Standard' {Get-PrimeNumbersStandardMethod $Amount;break}
        'SieveOfEratosthenes' {Get-PrimeNumbersSieveOfEratosthenes $Amount;break}
        'SieveOfSundaram' {Get-PrimeNumbersSieveOfSundaram $Amount;break}
    }
}

function Test-IsFactorion {
    <#
        .SYNOPSIS
            Test if a number is a factorion.
        .DESCRIPTION
            Test if a number is a factorion.
        .EXAMPLE
            Test-IsFactorion 40585
        .NOTES
            Author: Øyvind Kallstad
            Date: 09.05.2015
            Version: 1.0
        .LINK
            http://en.wikipedia.org/wiki/Factorion
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [ValidateRange(1,[int]::MaxValue)]
        [int] $Number
    )

    [byte[]]$numberDigits = ConvertTo-Digits $Number
    $sum = 0
    foreach ($digit in ($numberDigits.GetEnumerator())) {
        $sum += Get-Factorial $digit
    }
    if ($sum -eq $Number) {
        Write-Output $true
    }
    else {
        Write-Output $false
    }
}

function Get-Factorial {
    <#
        .SYNOPSIS
            Get the factorial of a number.
        .DESCRIPTION
            Get the factorial of a number.
        .EXAMPLE
            Get-Factorial 5
            Get the factorial of 5.
        .NOTES
            Author: Øyvind Kallstad
            Date: 09.05.2015
            Version: 1.0
        .LINK
            http://en.wikipedia.org/wiki/Factorial
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [ValidateRange(0,[int]::MaxValue)]
        [int] $Number
    )
    if ($Number -eq 0) {
        Write-Output 1
    }
    else {
        Write-Output ($Number * (Get-Factorial ($Number - 1)))
    }
}

function Test-IsHarshadNumber {
    <#
        .SYNOPSIS
            Check if a number is a Harshad number.
        .DESCRIPTION
            This function will check if a number is a Harshad number.
            A Harshad number is an integer that is divisible by the sum of its digits.
        .EXAMPLE
            11 | Test-IsHarshadNumber
            Test if 11 is a Harshad number.
        .EXAMPLE
            1..200 | ForEach-Object {if (Test-IsHarshadNumber $_) {$_}}
            List all Harshad numbers between 1 and 200.
        .NOTES
            Author: Øyvind Kallstad
            Date: 09.05.2015
            Version: 1.0
        .LINK
            http://en.wikipedia.org/wiki/Harshad_number
        .INPUTS
            System.Int32
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Position = 0, ValueFromPipeline, Mandatory)]
        [ValidateRange(1,[int]::MaxValue)]
        [int]$Number
    )
    [byte[]]$numberDigits = ConvertTo-Digits $Number
    if (($Number % $numberDigits.Sum()) -eq 0) {$true} else {$false}
}

function ConvertTo-Digits {
    <#
        .SYNOPSIS
            Convert an integer into an array of bytes of its individual digits.
        .DESCRIPTION
            Convert an integer into an array of bytes of its individual digits.
        .EXAMPLE
            ConvertTo-Digits 145
        .INPUTS
            System.Int32
        .NOTES
            Author: Øyvind Kallstad
            Date: 09.05.2015
            Version: 1.0
    #>
    [OutputType([System.Byte[]])]
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Number
    )
    $n = $Number
    $numberOfDigits = 1 + [convert]::ToInt32([math]::Floor(([math]::Log10($n))))
    $digits = New-Object Byte[] $numberOfDigits
    for ($i = ($numberOfDigits - 1); $i -ge 0; $i--) {
        $digit = $n % 10
        $digits[$i] = $digit
        $n = [math]::Floor($n / 10)
    }
    Write-Output $digits
}

function Test-IsPronicNumber {
    <#
        .SYNOPSIS
            Check if a number is a Pronic number.
        .DESCRIPTION
            This function will check if a number is a Pronic number.
            A pronic number is a number which is the product of two consecutive integers.
        .EXAMPLE
            2 | Test-IsPronicNumber
            Test if 2 is a Pronic Number.
        .EXAMPLE
            0..500 | ForEach-Object {if (Test-IsPronicNumber $_) {$_}}
            List all Pronic numbers between 0 and 500.
        .NOTES
            Author: Øyvind Kallstad
            Date: 09.05.2015
            Version: 1.0
        .LINK
            http://en.wikipedia.org/wiki/Pronic_number
        .INPUTS
            System.Int32
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Position = 0, ValueFromPipeline, Mandatory)]
        [ValidateRange(0,[int]::MaxValue)]
        [int]$Number
    )

    # We know 0 is a Pronic number, and since it will break
    # the math below, we handle it separately.
    if ($Number -eq 0) {
        Write-Output $true
    }

    else {
        # Get factors
        $n1 = [math]::Ceiling([math]::Sqrt($Number))
        $n2 = $Number / $n1
        # Check if factors are consecutive numbers
        if ((([math]::Min($n1, $n2)) + 1) -eq ([math]::Max($n1,$n2))) {
            Write-Output $true
        }
        else {
            Write-Output $false
        }
    }
}

function Invoke-Base64UrlDecode {
    <#
        .SYNOPSIS
        .DESCRIPTION
        .NOTES
            http://blog.securevideo.com/2013/06/04/implementing-json-web-tokens-in-net-with-a-base-64-url-encoded-key/
            Author: Øyvind Kallstad
            Date: 23.03.2015
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [string] $Argument
    )

    $Argument = $Argument.Replace('-', '+')
    $Argument = $Argument.Replace('_', '/')

    switch($Argument.Length % 4) {
        0 {break}
        2 {$Argument += '=='; break}
        3 {$Argument += '='; break}
        DEFAULT {Write-Warning 'Illegal base64 string!'}
    }

    Write-Output $Argument
}

function Invoke-Base64UrlEncode {
    <#
        .SYNOPSIS
        .DESCRIPTION
        .NOTES
            http://blog.securevideo.com/2013/06/04/implementing-json-web-tokens-in-net-with-a-base-64-url-encoded-key/
            Author: Øyvind Kallstad
            Date: 23.03.2015
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [byte[]] $Argument
    )

    $output = [System.Convert]::ToBase64String($Argument)
    $output = $output.Split('=')[0]
    $output = $output.Replace('+', '-')
    $output = $output.Replace('/', '_')

    Write-Output $output
}

function Get-TrimmedMean {
    <#
        .SYNOPSIS
            Function to calculate the trimmed mean of a set of numbers.
        .DESCRIPTION
            Function to calculate the trimmed mean of a set of numbers.
            The default trim percent is 25, which when used will calculate the Interquartile Mean of the number set.
            Use the TrimPercent parameter to set the trim percent as needed.
        .EXAMPLE
            [double[]]$dataSet = 8, 3, 7, 1, 3, 9
            Get-TrimmedMean -NumberSet $dataSet
            Calculate the trimmed mean of the number set, using the default trim percent of 25.
        .NOTES
            Author: Øyvind Kallstad
            Date: 29.10.2014
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [double[]] $NumberSet,

        [Parameter()]
        [ValidateRange(1,100)]
        [int] $TrimPercent = 25
    )

    try {
        # collect the number set into an arraylist and sort it
        $orderedSet = New-Object System.Collections.ArrayList
        $orderedSet.AddRange($NumberSet)
        $orderedSet.Sort()

        # calculate the trim count
        $numberSetLength = $orderedSet.Count
        $trimmedMean = $TrimPercent/100
        $trimmedCount = [Math]::Floor($trimmedMean * $numberSetLength)

        # subtract trim count from top and bottom of the number set
        [double[]]$trimmedSet = $orderedSet[$trimmedCount..($numberSetLength - ($trimmedCount+1))]

        # calculate the mean of the trimmed set
        Write-Output ($trimmedSet | Measure-Object -Average | Select-Object -ExpandProperty Average)
    }

    catch {
        Write-Warning $_.Exception.Message
    }
}

function Measure-ScriptBlock {
    <#
        .SYNOPSIS
        Measure time, memory consumption and CPU time for a block of code to execute.

        .DESCRIPTION
        Measure time, memory consumption and CPU time for a block of code to execute.
        This function is using Measure-Command internally, but is also trying to record how much memory and CPU time the code uses during execution.

        .EXAMPLE
        Measure-ScriptBlock -ScriptBlock {Get-ChildItem -Recurse} -Iteration 10 -TimeUnit 'Milliseconds' -SizeUnit 'KB'
        Run the code 10 times, formatting the mean values in Milliseconds and KB.

        .EXAMPLE
        Measure-ScriptBlock -ScriptBlock {Get-ChildItem -Recurse} -Iteration 10 -TimeUnit 'Milliseconds' -SizeUnit 'KB' -CalculateMeans:$false
        Run the same measurements are the above example, except skip calculating the mean value for the measurements taken.

        .EXAMPLE
        Measure-ScriptBlock -ScriptBlock $codeArray -Iteration 10 | Format-Table
        Run an array of script blocks 10 times, formatting the output in a table.

        .OUTPUTS
        System.Management.Automation.PSCustomObject

        .NOTES
        Author: Øyvind Kallstad
        Date: 28.10.2014
        Version: 1.0
    #>
    [CmdletBinding()]
    param (
        # Code to measure
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ScriptBlock[]] $ScriptBlock,

        # Set how many times you want to execute each ScriptBlock
        [Parameter()]
        [int32] $Iterations = 1,

        # Pause, in milliseconds, between each iteration
        [Parameter()]
        [int32] $Pause = 600,

        # Use this switch to control whether the mean values of each iteration should be calculated or not
        [Parameter()]
        [switch] $CalculateMeans = $true,

        # Customize the unit used for timings. Valid values are 'Hours','Minutes','Seconds' and 'Milliseconds'.
        [Parameter()]
        [ValidateSet('Hours','Minutes','Seconds','Milliseconds')]
        [string] $TimeUnit = 'Seconds',

        # Customize the unit of size. Valid values are 'KB','MB','GB' and 'TB'.
        [Parameter()]
        [ValidateSet('KB','MB','GB','TB')]
        [string] $SizeUnit = 'MB'
    )

    # initializing our counters - used by Write-Progress
    $arrayLength = $ScriptBlock.Count
    $totalCount = 0
    $arrayCount = 0

    # perform garbage collecting
    [gc]::Collect()
    [gc]::WaitForPendingFinalizers()
    [gc]::Collect()

    Start-Sleep -Seconds 1

    foreach ($script in $ScriptBlock) {
        $arrayCount++

        for ($i = 1; $i -le $Iterations; $i++) {

            # write progress bar
            $totalCount++
            Write-Progress -Activity 'Measuring' -Status "Executing ScriptBlock $($arrayCount)" -CurrentOperation "Iteration $($i)" -PercentComplete (($totalCount/($arrayLength*$iterations))*100)

            # perform garbage collecting
            [gc]::Collect()
            [gc]::WaitForPendingFinalizers()
            [gc]::Collect()

            # get current memory usage for current process
            $memBefore = [System.Diagnostics.Process]::GetCurrentProcess().PrivateMemorySize64

            # get current processor time for current process
            $cpuTimeBefore = [System.Diagnostics.Process]::GetCurrentProcess().TotalProcessorTime

            # run code
            $ttr = Measure-Command {
                $result = Invoke-Command -ScriptBlock $script
            } | Select-Object -ExpandProperty "Total$($TimeUnit)"
            $ttrArray += ,($ttr)

            # get current processor time for current process
            $cpuTimeAfter = [System.Diagnostics.Process]::GetCurrentProcess().TotalProcessorTime

            # get current memory usage for current process
            $memAfter = [System.Diagnostics.Process]::GetCurrentProcess().PrivateMemorySize64

            # do calculations
            $cpuTime = ($cpuTimeAfter | Select-Object -ExpandProperty "Total$($TimeUnit)") - ($cpuTimeBefore | Select-Object -ExpandProperty "Total$($TimeUnit)")
            $cpuTimeArray += ,($cpuTime)
            $memDifference = ($memAfter/"1$SizeUnit") - ($memBefore/"1$SizeUnit")
            if ($memDifference -lt 0) {$memDifference = 0} # just making sure we don't get a negative value
            $memDifferenceArray += ,($memDifference)

            if (-not($CalculateMeans)) {
                # if we don't want the calculated means we can
                # write the output to the pipeline after each iteration
                Write-Output ([PSCustomObject] [Ordered] @{
                    'ScriptBlock' = $script
                    'Result' = $result
                    'Iteration' = $i
                    "Memory ($($SizeUnit))" = ('{0:N0}' -f $memDifference)
                    "Processor Time ($($TimeUnit))" = ('{0:N2}' -f $cpuTime)
                    "Time To Run ($($TimeUnit))" = ('{0:N2}' -f $ttr)
                })
            }

            # a small pause before next iteration
            Start-Sleep -Milliseconds $Pause
        }

        # if we want the calculated means of our measurements,
        # we need to wait until all iterations are complete before
        # writing the output to the pipeline
        if ($CalculateMeans) {
            # create output object
            Write-Output ([PSCustomObject] [Ordered] @{
                'ScriptBlock' = $script
                'Result' = $result
                'Iterations' = $Iterations
                "Memory ($($SizeUnit))" = ('{0:N0}' -f ($memDifferenceArray | Measure-Object -Average | Select-Object -ExpandProperty Average))
                "Processor Time ($($TimeUnit))" = ('{0:N2}' -f ($cpuTimeArray | Measure-Object -Average | Select-Object -ExpandProperty Average))
                "Time To Run ($($TimeUnit))" = ('{0:N2}' -f ($ttrArray | Measure-Object -Average | Select-Object -ExpandProperty Average))
            })

            # reset the arrays
            Remove-Variable -Name memDifferenceArray,cpuTimeArray,ttrArray -ErrorAction SilentlyContinue
        }

    }

    # perform garbage collecting
    [gc]::Collect()
    [gc]::WaitForPendingFinalizers()
    [gc]::Collect()
}

function ConvertTo-ScriptBlock{
    <#
        .SYNOPSIS
            Convert to ScriptBlock.
        .DESCRIPTION
            Convert input to ScriptBlock.

        .EXAMPLE
            Get-Content '.\scriptFile.ps1' -raw | ConvertTo-ScriptBlock
            Converts a script file to a ScriptBlock.

        .NOTES
            Author: Øyvind Kallstad
            Date: 13.03.2014
            Version: 1.0
    #>
	param (
        # Input you want converted to a ScriptBlock.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]$InputObject
    )

    try {
        $scriptBlock = [ScriptBlock]::Create($inputObject)
    }

    catch {
        Write-Warning $_.Exception.Message
    }

    Write-Output $scriptBlock
}