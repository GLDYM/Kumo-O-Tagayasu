#!/usr/bin/env python3

"""
compare-installed-mods.py
Compare installed server/client mod jars and report mismatches for BOTH-side mods.
"""

import json
import pathlib
import sys


def _read_side_overrides(pakku_path: pathlib.Path) -> dict[str, str]:
    if not pakku_path.is_file():
        return {}

    pakku = json.loads(pakku_path.read_text(encoding="utf-8"))
    projects = pakku.get("projects", {})
    overrides: dict[str, str] = {}

    if not isinstance(projects, dict):
        return overrides

    for slug, config in projects.items():
        if not isinstance(slug, str) or not isinstance(config, dict):
            continue
        side = config.get("side")
        if isinstance(side, str) and side:
            overrides[slug] = side.upper()

    return overrides


def _project_slugs(project: dict) -> list[str]:
    slug = project.get("slug")
    if not isinstance(slug, dict):
        return []
    return [value for value in slug.values() if isinstance(value, str) and value]


def _normalize(name: str) -> str:
    return name.strip().lower()


def main() -> int:
    if len(sys.argv) != 5:
        print(
            "Usage: compare-installed-mods.py <lockfile-path> <pakku-json-path> <server-mods-dir> <client-mods-dir>"
        )
        return 1

    lock_path = pathlib.Path(sys.argv[1])
    pakku_path = pathlib.Path(sys.argv[2])
    server_mods = pathlib.Path(sys.argv[3])
    client_mods = pathlib.Path(sys.argv[4])

    if not lock_path.is_file():
        print(f"Lockfile not found: {lock_path}")
        return 1
    if not pakku_path.is_file():
        print(f"Pakku config not found: {pakku_path}")
        return 1
    if not server_mods.is_dir():
        print(f"Server mods dir not found: {server_mods}")
        return 1
    if not client_mods.is_dir():
        print(f"Client mods dir not found: {client_mods}")
        return 1

    lock = json.loads(lock_path.read_text(encoding="utf-8"))
    overrides = _read_side_overrides(pakku_path)

    server_files = {_normalize(path.name) for path in server_mods.glob("*.jar")}
    client_files = {_normalize(path.name) for path in client_mods.glob("*.jar")}

    both_projects: list[tuple[str, set[str]]] = []
    for project in lock.get("projects", []):
        if str(project.get("type", "")).upper() != "MOD":
            continue

        side = str(project.get("side", "BOTH")).upper()
        slugs = _project_slugs(project)
        for slug in slugs:
            if slug in overrides:
                side = overrides[slug]
                break
        if side != "BOTH":
            continue

        file_names = {
            _normalize(str(file.get("file_name", "")))
            for file in project.get("files", [])
            if file.get("url") and file.get("file_name")
        }
        if not file_names:
            continue

        label = slugs[0] if slugs else str(project.get("pakku_id", "unknown"))
        both_projects.append((label, file_names))

    missing_server: list[str] = []
    missing_client: list[str] = []
    version_mismatch: list[str] = []

    for label, expected_files in both_projects:
        server_match = sorted(expected_files & server_files)
        client_match = sorted(expected_files & client_files)

        if not server_match and not client_match:
            continue
        if not server_match:
            missing_server.append(f"{label}: client has {client_match[0]}")
            continue
        if not client_match:
            missing_client.append(f"{label}: server has {server_match[0]}")
            continue
        if server_match[0] != client_match[0]:
            version_mismatch.append(
                f"{label}: server={server_match[0]} client={client_match[0]}"
            )

    print("Installed BOTH mod comparison summary")
    print(f"Server jars: {len(server_files)}")
    print(f"Client jars: {len(client_files)}")
    print(f"Tracked BOTH mods: {len(both_projects)}")

    if not missing_server and not missing_client and not version_mismatch:
        print("No BOTH-side mod mismatches found.")
        return 0

    if missing_server:
        print("\nMissing on server:")
        for item in missing_server:
            print(item)

    if missing_client:
        print("\nMissing on client:")
        for item in missing_client:
            print(item)

    if version_mismatch:
        print("\nVersion mismatches:")
        for item in version_mismatch:
            print(item)

    return 1


if __name__ == "__main__":
    raise SystemExit(main())
