#!/usr/bin/env python3

'''
resolve-client-mod-downloads.py
Resolve client mods download URLs based on the lockfile.
If Portable MC adds their support of Curseforge modpack format,
this file is no longer needed.
'''

import json
import pathlib
import sys
from urllib.parse import quote, urlsplit, urlunsplit


def _read_side_overrides(pakku_path: pathlib.Path) -> dict[str, str]:
    """Read side overrides from pakku.json (projects.<slug>.side)."""
    if not pakku_path.is_file():
        return {}

    try:
        pakku = json.loads(pakku_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return {}

    projects = pakku.get("projects")
    if not isinstance(projects, dict):
        return {}

    overrides: dict[str, str] = {}
    for slug, config in projects.items():
        if not isinstance(slug, str) or not isinstance(config, dict):
            continue
        side = config.get("side")
        if isinstance(side, str) and side:
            overrides[slug] = side.upper()

    return overrides


def _get_project_slugs(project: dict) -> list[str]:
    slug = project.get("slug")
    if not isinstance(slug, dict):
        return []

    slugs: list[str] = []
    for value in slug.values():
        if isinstance(value, str) and value:
            slugs.append(value)
    return slugs


def _normalize_url(url: str) -> str:
    """Percent-encode unsafe characters in URL components for curl/wget."""
    parts = urlsplit(url)
    return urlunsplit(
        (
            parts.scheme,
            parts.netloc,
            quote(parts.path, safe="/%:@!$&'()*+,;=-._~"),
            quote(parts.query, safe="=&%:@!$'()*+,;/-._~?"),
            quote(parts.fragment, safe="%:@!$&'()*+,;=/-._~?"),
        )
    )


def main() -> int:
    if len(sys.argv) != 4:
        print("Usage: resolve-client-mod-downloads.py <lockfile-path> <pakku-json-path> <output-list-path>")
        return 1

    lock_path = pathlib.Path(sys.argv[1])
    pakku_path = pathlib.Path(sys.argv[2])
    out_path = pathlib.Path(sys.argv[3])

    if not lock_path.is_file():
        print(f"Lockfile not found: {lock_path}")
        return 1

    if not pakku_path.is_file():
        print(f"Pakku config not found: {pakku_path}")
        return 1

    lock = json.loads(lock_path.read_text(encoding="utf-8"))
    projects = lock.get("projects", [])
    side_overrides = _read_side_overrides(pakku_path)

    side_allowed = {"BOTH", "CLIENT"}
    # Match the server pack built by `pakku export`, which is consumed from
    # CurseForge in CI/release flows. Falling back to Modrinth is still useful
    # for mods that do not have a CurseForge file in the lockfile.
    priority = {"curseforge": 0, "modrinth": 1}

    lines: list[str] = []

    for project in projects:
        project_type = str(project.get("type", "")).upper()
        if project_type != "MOD":
            continue

        side = str(project.get("side", "BOTH")).upper()
        for project_slug in _get_project_slugs(project):
            if project_slug in side_overrides:
                side = side_overrides[project_slug]
                break
        if side not in side_allowed:
            continue

        files = project.get("files", [])
        candidates = [f for f in files if f.get("url")]
        if not candidates:
            continue

        candidates.sort(key=lambda f: priority.get(str(f.get("type", "")).lower(), 99))
        chosen = candidates[0]

        url = chosen.get("url")
        if url:
            url = _normalize_url(str(url))
        file_name = chosen.get("file_name")
        if not file_name:
            file_name = str(url).rstrip("/").split("/")[-1]

        sha1 = ""
        hashes = chosen.get("hashes")
        if isinstance(hashes, dict):
            sha1 = str(hashes.get("sha1", ""))

        lines.append("\t".join([str(url), str(file_name), sha1]))

        source_type = str(chosen.get("type", "")).lower()
        if source_type != "curseforge":
            print(f"Falling back to {source_type or 'unknown'} for {file_name}", file=sys.stderr)

    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Resolved {len(lines)} client mod downloads")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
