#!/usr/bin/env python3

'''
resolve-client-launch-targets.py
Resolves the Minecraft version and loader targets based on the lockfile.
'''

import json
import pathlib
import sys


def unique_preserve_order(items: list[str]) -> list[str]:
    seen: set[str] = set()
    out: list[str] = []
    for item in items:
        if not item or item in seen:
            continue
        seen.add(item)
        out.append(item)
    return out


def main() -> int:
    if len(sys.argv) != 3:
        print("Usage: resolve-client-launch-targets.py <lockfile-path> <output-path>")
        return 1

    lock_path = pathlib.Path(sys.argv[1])
    out_path = pathlib.Path(sys.argv[2])

    if not lock_path.is_file():
        print(f"Lockfile not found: {lock_path}")
        return 1

    lock = json.loads(lock_path.read_text(encoding="utf-8"))
    mc_version = str((lock.get("mc_versions") or [""])[0]).strip()
    loaders = lock.get("loaders", {})

    if not mc_version:
        print("Missing mc_versions in lockfile")
        return 1

    targets: list[str] = []

    if "neoforge" in loaders:
        loader_ver = str(loaders["neoforge"]).strip()
        targets = unique_preserve_order([
            f"neoforge::{loader_ver}",
            f"neoforge:{mc_version}",
            f"neoforge:{mc_version}:unstable",          
        ])
    elif "forge" in loaders:
        loader_ver = str(loaders["forge"]).strip()
        targets = unique_preserve_order([
            f"forge::{loader_ver}",
            f"forge:{mc_version}",
            f"forge:{mc_version}:unstable",
        ])
    elif "fabric" in loaders:
        loader_ver = str(loaders["fabric"]).strip()
        targets = unique_preserve_order([
            f"fabric:{mc_version}",
            f"fabric:{mc_version}:{loader_ver}",
        ])
    else:
        targets = [mc_version]

    # First line is MC version; following lines are portablemc target candidates.
    out_path.write_text("\n".join([mc_version, *targets]), encoding="utf-8")
    print(f"Resolved {len(targets)} launch target candidates")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
