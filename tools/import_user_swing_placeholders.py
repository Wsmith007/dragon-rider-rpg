#!/usr/bin/env python3
"""Copy user-recorded swing placeholders into assets/audio/placeholders/.

Source package: user-supplied ZIP (see docs/checkpoints for provenance).
Performs light cleanup only — trim silence, de-click fades, gentle normalize.
Does not modify non-swing placeholder assets.
"""

from __future__ import annotations

import math
import os
import struct
import wave

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE_DIR = os.path.join(REPO_ROOT, "tools", "user_swing_sources")
OUTPUT_DIR = os.path.join(REPO_ROOT, "assets", "audio", "placeholders")

# User README assignments — preserve recording character.
SWING_MAP = {
    "swing_dagger.wav": "weapon_swing_dagger_user_placeholder.wav",
    "swing_sword.wav": "weapon_swing_swordnew_user_placeholder.wav",
    "swing_polearm.wav": "weapon_swing_polearm_user_placeholder.wav",
}

TARGET_PEAK = 26000
TRIM_THRESHOLD_RATIO = 0.015
FADE_MS = 4.0


def _read_wav(path: str) -> tuple[int, list[int]]:
    with wave.open(path, "rb") as wav_file:
        if wav_file.getsampwidth() != 2 or wav_file.getnchannels() != 1:
            raise ValueError(f"Expected mono 16-bit PCM: {path}")
        sample_rate = wav_file.getframerate()
        frame_count = wav_file.getnframes()
        raw = wav_file.readframes(frame_count)
    samples = [struct.unpack("<h", raw[i : i + 2])[0] for i in range(0, len(raw), 2)]
    return sample_rate, samples


def _write_wav(path: str, sample_rate: int, samples: list[int]) -> None:
    with wave.open(path, "w") as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        frames = b"".join(struct.pack("<h", max(-32767, min(32767, sample))) for sample in samples)
        wav_file.writeframes(frames)


def _trim_silence(samples: list[int]) -> list[int]:
    if not samples:
        return samples
    peak = max(abs(sample) for sample in samples)
    threshold = max(int(peak * TRIM_THRESHOLD_RATIO), 120)
    start = 0
    for index, sample in enumerate(samples):
        if abs(sample) > threshold:
            start = index
            break
    end = len(samples) - 1
    for index in range(len(samples) - 1, -1, -1):
        if abs(samples[index]) > threshold:
            end = index
            break
    return samples[start : end + 1]


def _apply_fades(samples: list[int], sample_rate: int) -> list[int]:
    fade_samples = max(1, int(sample_rate * FADE_MS / 1000.0))
    fade_samples = min(fade_samples, len(samples) // 4)
    if fade_samples <= 0:
        return samples

    out = samples[:]
    for index in range(fade_samples):
        gain = index / fade_samples
        out[index] = int(out[index] * gain)
    tail_start = len(out) - fade_samples
    for offset in range(fade_samples):
        gain = 1.0 - (offset / fade_samples)
        out[tail_start + offset] = int(out[tail_start + offset] * gain)
    return out


def _normalize(samples: list[int]) -> list[int]:
    peak = max(abs(sample) for sample in samples) if samples else 0
    if peak <= 0:
        return samples
    scale = TARGET_PEAK / peak
    return [int(sample * scale) for sample in samples]


def _process(source_path: str) -> tuple[int, list[int]]:
    sample_rate, samples = _read_wav(source_path)
    samples = _trim_silence(samples)
    samples = _apply_fades(samples, sample_rate)
    samples = _normalize(samples)
    return sample_rate, samples


def import_swings() -> None:
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    for output_name, source_name in SWING_MAP.items():
        source_path = os.path.join(SOURCE_DIR, source_name)
        if not os.path.isfile(source_path):
            raise FileNotFoundError(f"Missing user source: {source_path}")

        sample_rate, samples = _process(source_path)
        output_path = os.path.join(OUTPUT_DIR, output_name)
        _write_wav(output_path, sample_rate, samples)
        duration = len(samples) / sample_rate
        print(f"Wrote {output_path} ({duration:.3f}s from {source_name})")

    # Legacy event path alias.
    sword_path = os.path.join(OUTPUT_DIR, "swing_sword.wav")
    swing_path = os.path.join(OUTPUT_DIR, "swing.wav")
    sample_rate, samples = _read_wav(sword_path)
    _write_wav(swing_path, sample_rate, samples)
    print(f"Wrote {swing_path} (sword alias)")


if __name__ == "__main__":
    import_swings()
