#!/usr/bin/env python3
"""Copy weapon_impact_library_v1 into runtime assets.

Default source: tools/weapon_impact_library_v1/
Runtime target: assets/audio/weapon_impact_library_v1/

Optional: pass a legacy ZIP path as argv[1] to import and rename on first install.
"""

from __future__ import annotations

import os
import shutil
import sys
import zipfile

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSET_DIR = os.path.join(REPO_ROOT, "assets", "audio", "weapon_impact_library_v1")
TOOLS_DIR = os.path.join(REPO_ROOT, "tools", "weapon_impact_library_v1")

LIBRARY_FILES = (
    "hit_dagger_01.wav",
    "hit_sword_01.wav",
    "hit_sword_02.wav",
    "hit_polearm_01.wav",
)

LEGACY_ZIP_MAP = {
    "processed_sword_ping_hits/hit_dagger_best.wav": "hit_dagger_01.wav",
    "processed_sword_ping_hits/hit_sword_best.wav": "hit_sword_01.wav",
    "processed_sword_ping_hits/hit_sword_best - raider.wav": "hit_sword_02.wav",
    "processed_sword_ping_hits/hit_polearm_01.wav": "hit_polearm_01.wav",
}


def _copy_from_tools() -> None:
    os.makedirs(ASSET_DIR, exist_ok=True)
    for filename in LIBRARY_FILES:
        source = os.path.join(TOOLS_DIR, filename)
        if not os.path.isfile(source):
            raise FileNotFoundError(f"Missing library source: {source}")
        shutil.copy2(source, os.path.join(ASSET_DIR, filename))
        print(f"Copied {filename}")


def _import_legacy_zip(zip_path: str) -> None:
    os.makedirs(TOOLS_DIR, exist_ok=True)
    os.makedirs(ASSET_DIR, exist_ok=True)
    with zipfile.ZipFile(zip_path) as archive:
        for source_name, dest_name in LEGACY_ZIP_MAP.items():
            if source_name not in archive.namelist():
                raise FileNotFoundError(f"Missing {source_name} in {zip_path}")
            data = archive.read(source_name)
            for folder in (TOOLS_DIR, ASSET_DIR):
                with open(os.path.join(folder, dest_name), "wb") as handle:
                    handle.write(data)
            print(f"Imported {dest_name}")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        _import_legacy_zip(sys.argv[1])
    else:
        _copy_from_tools()
