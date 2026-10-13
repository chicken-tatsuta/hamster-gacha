import math
import os
import random
import struct
import sys
import wave

RATE = 22050
random.seed(30)


def tone(freq, seconds, volume=.45, wave_type='sine', end_freq=None):
    count = int(RATE * seconds)
    out = []
    phase = 0.0
    for i in range(count):
        p = i / max(1, count - 1)
        current = freq if end_freq is None else freq + (end_freq - freq) * p
        phase += 2 * math.pi * current / RATE
        if wave_type == 'square':
            raw = 1 if math.sin(phase) >= 0 else -1
        elif wave_type == 'triangle':
            raw = 2 / math.pi * math.asin(math.sin(phase))
        elif wave_type == 'noise':
            raw = random.uniform(-1, 1)
        else:
            raw = math.sin(phase)
        attack = min(1, i / max(1, int(RATE * .012)))
        release = min(1, (count - i) / max(1, int(RATE * .06)))
        out.append(raw * volume * attack * release)
    return out


def silence(seconds):
    return [0.0] * int(RATE * seconds)


def mix(*tracks):
    length = max(map(len, tracks))
    return [sum(track[i] if i < len(track) else 0 for track in tracks) for i in range(length)]


def sequence(*tracks):
    out = []
    for track in tracks:
        out.extend(track)
    return out


def write(path, samples):
    peak = max(1, max(abs(v) for v in samples))
    scale = .92 / peak
    payload = b''.join(struct.pack('<h', int(max(-1, min(1, v * scale)) * 32767)) for v in samples)
    with wave.open(path, 'wb') as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(RATE)
        output.writeframes(payload)


target = sys.argv[1]
os.makedirs(target, exist_ok=True)

sounds = {
    'button.wav': mix(tone(150, .11, .45, 'triangle', 260), tone(520, .07, .2)),
    'reel_spin.wav': mix(tone(74, .34, .22, 'triangle'), tone(148, .34, .16), tone(0, .34, .09, 'noise')),
    'reel_slow.wav': sequence(tone(520, .12, .34), tone(410, .15, .38), tone(300, .19, .4), tone(190, .24, .44)),
    'reel_stop.wav': mix(tone(118, .14, .66, 'triangle', 72), tone(0, .035, .3, 'noise')),
    'hold_change.wav': sequence(tone(720, .08, .35), tone(970, .13, .45)),
    'chance_alert.wav': sequence(tone(560, .11, .35), silence(.04), tone(740, .11, .4), silence(.04), tone(930, .18, .45)),
    'hot_alert.wav': sequence(tone(320, .13, .45, 'square'), tone(490, .13, .45, 'square'), tone(760, .24, .5, 'square')),
    'jackpot.wav': sequence(tone(523, .12, .42), tone(659, .12, .45), tone(784, .12, .48), tone(1047, .5, .58)),
    'ssr_jackpot.wav': mix(
        sequence(tone(523, .12, .4), tone(659, .12, .42), tone(784, .12, .46), tone(1047, .75, .58)),
        tone(130, 1.11, .18, 'triangle', 260),
    ),
    'revival.wav': mix(tone(170, .85, .4, 'triangle', 1180), tone(0, .3, .12, 'noise')),
}

for filename, samples in sounds.items():
    write(os.path.join(target, filename), samples)
