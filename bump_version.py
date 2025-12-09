#!/usr/bin/env python
"""
Simple version bump script for stanley_cbp.

Usage:
    python bump_version.py           # bump patch (0.1.52 -> 0.1.53)
    python bump_version.py patch     # same as above
    python bump_version.py minor     # 0.1.52 -> 0.2.0
    python bump_version.py major     # 0.1.52 -> 1.0.0
"""

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent
PYPROJECT = ROOT / "pyproject.toml"
INIT_FILE = ROOT / "stanley_cbp" / "__init__.py"


def parse_current_version(pyproject_text: str) -> tuple[int, int, int]:
    """
    Find the version line under [project], e.g.:

        version = "0.1.52"

    and return (0, 1, 52).
    """
    m = re.search(r'(?m)^version\s*=\s*"(\d+)\.(\d+)\.(\d+)"', pyproject_text)
    if not m:
        raise SystemExit("Could not find `version = \"X.Y.Z\"` in pyproject.toml")
    return tuple(int(x) for x in m.groups())


def bump(major: int, minor: int, patch: int, part: str) -> tuple[int, int, int]:
    if part == "patch":
        patch += 1
    elif part == "minor":
        minor += 1
        patch = 0
    elif part == "major":
        major += 1
        minor = 0
        patch = 0
    else:
        raise SystemExit(f"Unknown bump type: {part!r} (use major|minor|patch)")
    return major, minor, patch


def update_pyproject(py_text: str, new_version: str) -> str:
    """Replace the version line in pyproject.toml with the new version."""
    return re.sub(
        r'(?m)^version\s*=\s*".*"$',
        f'version = "{new_version}"',
        py_text,
        count=1,
    )


def update_init(init_text: str, new_version: str) -> str:
    """
    Update or add __version__ in stanley_cbp/__init__.py.
    """
    if "__version__" in init_text:
        return re.sub(
            r'(?m)^__version__\s*=\s*".*"$',
            f'__version__ = "{new_version}"',
            init_text,
            count=1,
        )
    else:
        # Append at the end if it somehow was missing
        return init_text.rstrip() + f'\n\n__version__ = "{new_version}"\n'


def main():
    # Which part to bump: default = patch
    part = "patch"
    if len(sys.argv) >= 2:
        part = sys.argv[1].strip().lower()

    py_text = PYPROJECT.read_text(encoding="utf-8")
    major, minor, patch = parse_current_version(py_text)

    old_version = f"{major}.{minor}.{patch}"
    major, minor, patch = bump(major, minor, patch, part)
    new_version = f"{major}.{minor}.{patch}"

    if new_version == old_version:
        print(f"Version unchanged ({old_version}) – nothing to do.")
        return

    # Update pyproject.toml
    py_text_new = update_pyproject(py_text, new_version)
    PYPROJECT.write_text(py_text_new, encoding="utf-8")

    # Update stanley_cbp/__init__.py
    init_text = INIT_FILE.read_text(encoding="utf-8")
    init_text_new = update_init(init_text, new_version)
    INIT_FILE.write_text(init_text_new, encoding="utf-8")

    print(f"Bumped version: {old_version} -> {new_version}")


if __name__ == "__main__":
    main()
