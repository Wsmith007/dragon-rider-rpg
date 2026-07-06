#!/usr/bin/env python3
"""Generate procedural placeholder WAV files for Dragon Rider RPG audio architecture tests.

Uses only the Python standard library. Deterministic output (fixed RNG seed).
Regenerates every file in assets/audio/placeholders/.
"""

from __future__ import annotations

import math
import os
import random
import struct
import wave

SAMPLE_RATE = 22050
OUTPUT_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "assets",
    "audio",
    "placeholders",
)

FILES = (
    "swing.wav",
    "impact.wav",
    "ui_soft.wav",
    "defeat.wav",
    "dragon_soft.wav",
    "heavy_thud.wav",
)


def _clamp_sample(value: float) -> int:
    return max(-32767, min(32767, int(value)))


def _write_wav(path: str, samples: list[float]) -> None:
    with wave.open(path, "w") as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        frames = b"".join(struct.pack("<h", _clamp_sample(sample)) for sample in samples)
        wav_file.writeframes(frames)


def _envelope(length: int, attack: float, release: float, duration: float) -> list[float]:
    env: list[float] = []
    for index in range(length):
        time = index / SAMPLE_RATE
        value = min(1.0, time / attack, (duration - time) / release, 1.0)
        env.append(max(0.0, value))
    return env


def _tone(
    frequency: float,
    duration: float,
    volume: float = 0.25,
    attack: float = 0.02,
    release: float = 0.02,
) -> list[float]:
    length = int(SAMPLE_RATE * duration)
    env = _envelope(length, attack, release, duration)
    samples: list[float] = []
    for index in range(length):
        time = index / SAMPLE_RATE
        wave_value = math.sin(2.0 * math.pi * frequency * time)
        samples.append(volume * env[index] * 32767.0 * wave_value)
    return samples


def _noise_burst(
    duration: float,
    volume: float = 0.18,
    attack: float = 0.005,
    release: float = 0.04,
) -> list[float]:
    rng = random.Random(1)
    length = int(SAMPLE_RATE * duration)
    env = _envelope(length, attack, release, duration)
    samples: list[float] = []
    for index in range(length):
        wave_value = rng.random() * 2.0 - 1.0
        samples.append(volume * env[index] * 32767.0 * wave_value)
    return samples


def _descending_tone(
    start_frequency: float,
    end_frequency: float,
    duration: float,
    volume: float = 0.22,
) -> list[float]:
    length = int(SAMPLE_RATE * duration)
    env = _envelope(length, 0.02, 0.05, duration)
    samples: list[float] = []
    for index in range(length):
        time = index / SAMPLE_RATE
        progress = time / duration if duration > 0.0 else 0.0
        frequency = start_frequency + (end_frequency - start_frequency) * progress
        wave_value = math.sin(2.0 * math.pi * frequency * time)
        samples.append(volume * env[index] * 32767.0 * wave_value)
    return samples


def generate_all() -> None:
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    outputs = {
        "swing.wav": _noise_burst(duration=0.07, volume=0.14),
        "impact.wav": _tone(frequency=180.0, duration=0.09, volume=0.32, attack=0.008, release=0.03),
        "ui_soft.wav": _tone(frequency=880.0, duration=0.05, volume=0.08, attack=0.01, release=0.02),
        "defeat.wav": _descending_tone(
            start_frequency=160.0,
            end_frequency=90.0,
            duration=0.18,
            volume=0.22,
        ),
        "dragon_soft.wav": _tone(frequency=220.0, duration=0.12, volume=0.06, attack=0.03, release=0.05),
        "heavy_thud.wav": _tone(frequency=95.0, duration=0.14, volume=0.28, attack=0.01, release=0.05),
    }

    for filename in FILES:
        path = os.path.join(OUTPUT_DIR, filename)
        _write_wav(path, outputs[filename])
        print(f"Wrote {path}")


if __name__ == "__main__":
    generate_all()
