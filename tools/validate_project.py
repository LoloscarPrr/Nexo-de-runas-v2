#!/usr/bin/env python3
"""Fail fast on broken project structure before the Android export starts."""

from __future__ import annotations

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "project.godot",
    "export_presets.cfg",
    "scenes/main.tscn",
    "scripts/main.gd",
    ".specify/memory/constitution.md",
    "specs/001-core-reconstruction/spec.md",
    "specs/001-core-reconstruction/plan.md",
    "specs/001-core-reconstruction/tasks.md",
    "AGENTS.md",
]

errors: list[str] = []


def fail(message: str) -> None:
    errors.append(message)


for relative in REQUIRED_FILES:
    if not (ROOT / relative).is_file():
        fail(f"Missing required file: {relative}")

project_path = ROOT / "project.godot"
if project_path.is_file():
    project_text = project_path.read_text(encoding="utf-8")
    scene_match = re.search(r'^run/main_scene="res://([^\"]+)"', project_text, re.MULTILINE)
    if not scene_match:
        fail("project.godot does not define application/run/main_scene")
    else:
        main_scene = ROOT / scene_match.group(1)
        if not main_scene.is_file():
            fail(f"Main scene reference is broken: {scene_match.group(1)}")

    if 'config/features=PackedStringArray("4.3"' not in project_text:
        fail("project.godot is expected to target Godot 4.3")

preset_path = ROOT / "export_presets.cfg"
if preset_path.is_file():
    preset_text = preset_path.read_text(encoding="utf-8")
    if 'platform="Android"' not in preset_text:
        fail("export_presets.cfg has no Android export preset")

for gdscript in sorted(ROOT.rglob("*.gd")):
    text = gdscript.read_text(encoding="utf-8")
    relative = gdscript.relative_to(ROOT)
    if not text.strip():
        fail(f"Empty GDScript file: {relative}")
    if any(marker in text for marker in ("<<<<<<<", "=======", ">>>>>>>")):
        fail(f"Merge conflict marker found in: {relative}")

for scene in sorted(ROOT.rglob("*.tscn")):
    text = scene.read_text(encoding="utf-8")
    relative = scene.relative_to(ROOT)
    if any(marker in text for marker in ("<<<<<<<", "=======", ">>>>>>>")):
        fail(f"Merge conflict marker found in: {relative}")

if errors:
    print("Nexo de Runas V2 validation FAILED:\n")
    for error in errors:
        print(f" - {error}")
    sys.exit(1)

print("Nexo de Runas V2 validation OK")
print(f"Checked {len(list(ROOT.rglob('*.gd')))} GDScript file(s) and {len(list(ROOT.rglob('*.tscn')))} scene file(s).")
