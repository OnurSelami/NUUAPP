$SampleRate = 44100
$Duration = 0.25
$NumSamples = [int]($SampleRate * $Duration)
$AudioData = New-Object 'System.Collections.Generic.List[Int16]'

$StartFreq1 = 400.0
$EndFreq1 = 1200.0
$Decay1 = 25.0

for ($i = 0; $i -lt $NumSamples; $i++) {
    $t = $i / $SampleRate
    
    $Phase = 2.0 * [Math]::PI * ($StartFreq1 * $t + ($EndFreq1 - $StartFreq1) * ($t + ([Math]::Exp(-15.0 * $t) - 1.0) / 15.0))
    
    if ($t -lt 0.005) {
        $Envelope = $t / 0.005
    } else {
        $Envelope = [Math]::Exp(-$Decay1 * ($t - 0.005))
    }
    
    $Am = 1.0 + 0.5 * [Math]::Sin(2.0 * [Math]::PI * 50.0 * $t)
    $Sample = [int](32767.0 * 0.8 * $Envelope * [Math]::Sin($Phase) * $Am)
    
    $Sample = [Math]::Max(-32768, [Math]::Min(32767, $Sample))
    $AudioData.Add([Int16]$Sample)
}

$Delay = [int]($SampleRate * 0.04)
for ($i = $Delay; $i -lt $NumSamples; $i++) {
    $t = ($i - $Delay) / $SampleRate
    $StartFreq2 = 300.0
    $EndFreq2 = 800.0
    
    $Phase = 2.0 * [Math]::PI * ($StartFreq2 * $t + ($EndFreq2 - $StartFreq2) * ($t + ([Math]::Exp(-20.0 * $t) - 1.0) / 20.0))
    
    if ($t -lt 0.005) {
        $Envelope = $t / 0.005
    } else {
        $Envelope = [Math]::Exp(-30.0 * ($t - 0.005))
    }
    
    $Sample = [int](32767.0 * 0.4 * $Envelope * [Math]::Sin($Phase))
    $NewSample = [Math]::Max(-32768, [Math]::Min(32767, $AudioData[$i] + $Sample))
    $AudioData[$i] = [Int16]$NewSample
}

# WAV Header
$DataSize = $AudioData.Count * 2
$FileSize = 36 + $DataSize
$Header = New-Object Byte[] 44

[System.Text.Encoding]::ASCII.GetBytes("RIFF").CopyTo($Header, 0)
[BitConverter]::GetBytes($FileSize).CopyTo($Header, 4)
[System.Text.Encoding]::ASCII.GetBytes("WAVE").CopyTo($Header, 8)
[System.Text.Encoding]::ASCII.GetBytes("fmt ").CopyTo($Header, 12)
[BitConverter]::GetBytes(16).CopyTo($Header, 16) # Subchunk1Size
[BitConverter]::GetBytes([Int16]1).CopyTo($Header, 20) # AudioFormat (PCM)
[BitConverter]::GetBytes([Int16]1).CopyTo($Header, 22) # NumChannels (Mono)
[BitConverter]::GetBytes($SampleRate).CopyTo($Header, 24) # SampleRate
[BitConverter]::GetBytes($SampleRate * 2).CopyTo($Header, 28) # ByteRate
[BitConverter]::GetBytes([Int16]2).CopyTo($Header, 32) # BlockAlign
[BitConverter]::GetBytes([Int16]16).CopyTo($Header, 34) # BitsPerSample
[System.Text.Encoding]::ASCII.GetBytes("data").CopyTo($Header, 36)
[BitConverter]::GetBytes($DataSize).CopyTo($Header, 40)

$OutPath = "c:\Nuu App Flutter\assets\audio\water_drop.wav"
$FileStream = [System.IO.File]::Create($OutPath)
$FileStream.Write($Header, 0, 44)

# Convert List to byte array manually instead of using MemoryMarshal
$Bytes = New-Object Byte[] $DataSize
for ($i = 0; $i -lt $AudioData.Count; $i++) {
    $sampleBytes = [BitConverter]::GetBytes($AudioData[$i])
    $Bytes[$i * 2] = $sampleBytes[0]
    $Bytes[$i * 2 + 1] = $sampleBytes[1]
}

$FileStream.Write($Bytes, 0, $DataSize)
$FileStream.Close()

Write-Host "Water drop sound saved to: $OutPath"
