#!/usr/bin/env python3

'''
resolve-loader-installer-meta.py
Resolve Mod Loader Installer URL for lightweight server-pack.
Full server-pack resolve this in the install script.
'''


import json
import pathlib
import sys


def log(message: str) -> None:
    print(f"[resolve-loader-installer-meta] {message}", file=sys.stderr)


def load_key_value_properties(path: pathlib.Path) -> dict[str, str]:
    data: dict[str, str] = {}
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or line.startswith(";"):
            continue
        if "=" not in line:
            continue
        key, value = line.split("=", 1)
        data[key.strip()] = value.strip()
    return data


def main() -> int:
    if len(sys.argv) != 3:
        print("Usage: resolve-loader-installer-meta.py <pakku-lock.json> <install-config.properties>")
        return 1

    lock_path = pathlib.Path(sys.argv[1])
    install_config_path = pathlib.Path(sys.argv[2])

    log(f"Input lock path: {lock_path}")
    log(f"Input config path: {install_config_path}")

    if not lock_path.is_file():
        print(f"pakku-lock.json not found: {lock_path}", file=sys.stderr)
        return 1
    if not install_config_path.is_file():
        print(f"install-config.properties not found: {install_config_path}", file=sys.stderr)
        return 1
    if install_config_path.suffix.lower() != ".properties":
        print(f"install-config must be .properties: {install_config_path}", file=sys.stderr)
        return 1

    lock = json.loads(lock_path.read_text(encoding="utf-8"))
    cfg = load_key_value_properties(install_config_path)

    log("Loaded lockfile and install config successfully")

    mc_versions = lock.get("mc_versions") or []
    mc_version = str(mc_versions[0]) if mc_versions else ""
    loaders = lock.get("loaders") or {}

    loader_name = ""
    loader_version = ""
    installer_file_name = ""
    installer_url = ""

    if "neoforge" in loaders:
        loader_name = "neoforge"
        loader_version = str(loaders["neoforge"])
        installer_file_name = f"neoforge-{loader_version}-installer.jar"
        template = str(cfg.get("neoforge_installer_url_template") or "")
        installer_url = template.replace("{loader_version}", loader_version)
    elif "forge" in loaders:
        loader_name = "forge"
        loader_version = str(loaders["forge"])
        installer_file_name = f"forge-{mc_version}-{loader_version}-installer.jar"
        template = str(cfg.get("forge_installer_url_template") or "")
        installer_url = template.replace("{mc_version}", mc_version).replace("{loader_version}", loader_version)
    elif "fabric" in loaders:
        loader_name = "fabric"
        loader_version = str(loaders["fabric"])
        fabric_installer_version = str(cfg.get("fabric_installer_version") or "")
        installer_file_name = f"fabric-installer-{fabric_installer_version}.jar"
        template = str(cfg.get("fabric_installer_url_template") or "")
        installer_url = template.replace("{installer_version}", fabric_installer_version)
    else:
        print("Unsupported loader in pakku-lock.json", file=sys.stderr)
        return 1

    required_values = {
        "mc_version": mc_version,
        "loader_name": loader_name,
        "loader_version": loader_version,
        "installer_file_name": installer_file_name,
        "installer_url": installer_url,
    }

    missing = [k for k, v in required_values.items() if not str(v).strip()]
    if missing:
        log(f"Missing required output values: {', '.join(missing)}")
        return 1

    log(
        "Resolved values: "
        f"loader_name={loader_name}, loader_version={loader_version}, "
        f"mc_version={mc_version}, installer_file_name={installer_file_name}"
    )

    print(f"mc_version={mc_version}")
    print(f"loader_name={loader_name}")
    print(f"loader_version={loader_version}")
    print(f"installer_file_name={installer_file_name}")
    print(f"installer_url={installer_url}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
