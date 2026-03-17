import math
import wave
import struct

# Parameters
sample_rate = 44100
duration = 0.25  # seconds
num_samples = int(sample_rate * duration)

audio_data = []

# Synthesize a water droplet sound
# A water drop is typically an exponentially decaying sine wave
# with an upward frequency sweep (chirp).
start_freq = 400.0  # Hz
end_freq = 1200.0   # Hz
decay = 25.0        # Exponential decay rate

for i in range(num_samples):
    t = float(i) / sample_rate
    
    # Let's use a simpler exponential curve for frequency
    freq = start_freq + (end_freq - start_freq) * (1.0 - math.exp(-15.0 * t))
    
    # Phase accumulation (approximate)
    phase = 2.0 * math.pi * (start_freq * t + (end_freq - start_freq) * (t + (math.exp(-15.0 * t) - 1.0) / 15.0))
    
    # Envelope: fast attack, exponential decay
    attack_time = 0.005
    if t < attack_time:
        envelope = t / attack_time
    else:
        envelope = math.exp(-decay * (t - attack_time))
        
    # Amplitude modulation to add a little "bloop" character
    am = 1.0 + 0.5 * math.sin(2.0 * math.pi * 50.0 * t)
        
    sample = int(32767.0 * 0.8 * envelope * math.sin(phase) * am)
    # Clamp
    sample = max(-32768, min(32767, sample))
    audio_data.append(sample)

# Second droplet slightly delayed and lower pitch for "bloop" effect
delay = int(sample_rate * 0.04)
for i in range(delay, num_samples):
    t = float(i - delay) / sample_rate
    start_f = 300.0
    end_f = 800.0
    freq = start_f + (end_f - start_f) * (1.0 - math.exp(-20.0 * t))
    phase = 2.0 * math.pi * (start_f * t + (end_f - start_f) * (t + (math.exp(-20.0 * t) - 1.0) / 20.0))
    
    attack_time = 0.005
    if t < attack_time:
        envelope = t / attack_time
    else:
        envelope = math.exp(-30.0 * (t - attack_time))
        
    sample = int(32767.0 * 0.4 * envelope * math.sin(phase))
    # Add to existing
    audio_data[i] = max(-32768, min(32767, audio_data[i] + sample))

# Write to WAV file
with wave.open(r"c:\Nuu App Flutter\assets\audio\water_drop.wav", "w") as wav_file:
    wav_file.setnchannels(1) # mono
    wav_file.setsampwidth(2) # 2 bytes per sample (16-bit)
    wav_file.setframerate(sample_rate)
    
    for sample in audio_data:
        data = struct.pack("<h", sample) # little-endian 16-bit integer
        wav_file.writeframesraw(data)
        
print("Water drop sound generated successfully.")
