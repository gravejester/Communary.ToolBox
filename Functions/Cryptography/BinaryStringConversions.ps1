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