# Kumo-O-Tagayasu Server Build Script (PowerShell)
# Requires PowerShell 5+ and JDK 21

$ErrorActionPreference = "Stop"

# ==== Configuration ====
$CONFIG_PATH = $null
$PAKKU_URL = $null
$LOCKFILE_PATH = $null
$SERVER_DIR = $null
$SERVERPACK_DIR = $null
$FORGE_INSTALLER_URL_TEMPLATE = $null
$NEOFORGE_INSTALLER_URL_TEMPLATE = $null
$FABRIC_INSTALLER_VERSION = $null
$FABRIC_INSTALLER_URL_TEMPLATE = $null
$LOADER_NAME = $null
$LOADER_VERSION = $null
$MC_VERSION = $null
$LOADER_INSTALLER_URL = $null
$INSTALLER_FILE_GLOB = $null
$INSTALLER_TARGET_FILE = $null

# ==== Color Prompts ====
function Write-Color($Text, $Color="White") {
    Write-Host $Text -ForegroundColor $Color
}

# ==== Utility Functions ====
function Downloader($url, $dest) {
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
    } catch {
        Write-Color "Download failed: $url" Red
        exit 1
    }
}

function Do-Unzip($zip, $dest) {
    try {
        Expand-Archive -Path $zip -DestinationPath $dest -Force
    } catch {
        Write-Color "Unzip failed: $zip" Red
        exit 1
    }
}

# ==== Configuration Loading ====
function Resolve-ConfigPath {
    if (Test-Path "install-config.properties") {
        return "install-config.properties"
    }
    if (Test-Path "installer/install-config.properties") {
        return "installer/install-config.properties"
    }

    Write-Color "install-config.properties not found in current directory or installer/ directory." Red
    exit 1
}

function Get-PropertiesFromFile($Path) {
    $map = @{}
    $lines = Get-Content $Path
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        if (-not $trimmed -or $trimmed.StartsWith("#") -or $trimmed.StartsWith(";")) {
            continue
        }

        $idx = $trimmed.IndexOf("=")
        if ($idx -lt 1) {
            continue
        }

        $key = $trimmed.Substring(0, $idx).Trim()
        $value = $trimmed.Substring($idx + 1).Trim()
        $map[$key] = $value
    }
    return $map
}

function Load-Config {
    $script:CONFIG_PATH = Resolve-ConfigPath

    try {
        $config = Get-PropertiesFromFile $script:CONFIG_PATH
    } catch {
        Write-Color "Failed to parse $($script:CONFIG_PATH): $($_.Exception.Message)" Red
        exit 1
    }

    $script:PAKKU_URL = [string]$config["pakku_url"]
    $script:LOCKFILE_PATH = [string]$config["lockfile_path"]
    $script:SERVER_DIR = [string]$config["server_dir"]
    $script:SERVERPACK_DIR = [string]$config["serverpack_dir"]
    $script:FORGE_INSTALLER_URL_TEMPLATE = [string]$config["forge_installer_url_template"]
    $script:NEOFORGE_INSTALLER_URL_TEMPLATE = [string]$config["neoforge_installer_url_template"]
    $script:FABRIC_INSTALLER_VERSION = [string]$config["fabric_installer_version"]
    $script:FABRIC_INSTALLER_URL_TEMPLATE = [string]$config["fabric_installer_url_template"]

    if (-not $script:PAKKU_URL -or -not $script:LOCKFILE_PATH -or -not $script:SERVER_DIR -or -not $script:SERVERPACK_DIR -or -not $script:FORGE_INSTALLER_URL_TEMPLATE -or -not $script:NEOFORGE_INSTALLER_URL_TEMPLATE -or -not $script:FABRIC_INSTALLER_VERSION -or -not $script:FABRIC_INSTALLER_URL_TEMPLATE) {
        Write-Color "$($script:CONFIG_PATH) is missing required fields." Red
        exit 1
    }
}

# ==== Resolve Loader Info from Lockfile ====
function Resolve-LoaderFromLockfile {
    if (-not (Test-Path $LOCKFILE_PATH)) {
        Write-Color "pakku-lock.json not found at $LOCKFILE_PATH" Red
        exit 1
    }

    try {
        $lock = Get-Content $LOCKFILE_PATH -Raw | ConvertFrom-Json
    } catch {
        Write-Color "Failed to parse pakku-lock.json: $($_.Exception.Message)" Red
        exit 1
    }

    if (-not $lock.mc_versions -or $lock.mc_versions.Count -lt 1) {
        Write-Color "mc_versions not found in pakku-lock.json" Red
        exit 1
    }

    $script:MC_VERSION = [string]$lock.mc_versions[0]

    if ($lock.loaders.neoforge) {
        $script:LOADER_NAME = "neoforge"
        $script:LOADER_VERSION = [string]$lock.loaders.neoforge
        $script:LOADER_INSTALLER_URL = $script:NEOFORGE_INSTALLER_URL_TEMPLATE.Replace("{loader_version}", $script:LOADER_VERSION)
        $script:INSTALLER_FILE_GLOB = "neoforge-*-installer.jar"
        $script:INSTALLER_TARGET_FILE = "$($script:LOADER_NAME)-$($script:LOADER_VERSION)-installer.jar"
    } elseif ($lock.loaders.forge) {
        $script:LOADER_NAME = "forge"
        $script:LOADER_VERSION = [string]$lock.loaders.forge
        $script:LOADER_INSTALLER_URL = $script:FORGE_INSTALLER_URL_TEMPLATE.Replace("{mc_version}", $script:MC_VERSION).Replace("{loader_version}", $script:LOADER_VERSION)
        $script:INSTALLER_FILE_GLOB = "forge-*-installer.jar"
        $script:INSTALLER_TARGET_FILE = "$($script:LOADER_NAME)-$($script:LOADER_VERSION)-installer.jar"
    } elseif ($lock.loaders.fabric) {
        $script:LOADER_NAME = "fabric"
        $script:LOADER_VERSION = [string]$lock.loaders.fabric
        $script:LOADER_INSTALLER_URL = $script:FABRIC_INSTALLER_URL_TEMPLATE.Replace("{installer_version}", $script:FABRIC_INSTALLER_VERSION)
        $script:INSTALLER_FILE_GLOB = "fabric-installer-*.jar"
        $script:INSTALLER_TARGET_FILE = "fabric-installer-$($script:FABRIC_INSTALLER_VERSION).jar"
    } else {
        Write-Color "No supported loader found in pakku-lock.json. Supported loaders: forge, neoforge, fabric." Red
        exit 1
    }

    Write-Color "Detected loader: $($script:LOADER_NAME) $($script:LOADER_VERSION) (MC $($script:MC_VERSION))" Green
}

# ==== Check Java ====
function Check-Java {
    if (-not (Get-Command "java.exe" -ErrorAction SilentlyContinue)) {
        Write-Host "Didn't detect Java, please install it first (recommended JDK 21 or above)." -ForegroundColor Red
        exit 1
    }

    $tmp = [System.IO.Path]::GetTempFileName()
    Start-Process -FilePath "java" -ArgumentList "-version" -NoNewWindow -RedirectStandardError $tmp -Wait
    $javaVer = Get-Content $tmp | Select-Object -First 1
    Remove-Item $tmp -ErrorAction SilentlyContinue

    Write-Host "Java detected: $javaVer" -ForegroundColor Green
}


# ==== Pakku Management ====
function Ensure-Pakku {
    if (Test-Path "pakku.jar") {
        Write-Color "pakku.jar already exists, skipping download." Green
    } else {
        Write-Color "Downloading pakku.jar..." Yellow
        Downloader $PAKKU_URL "pakku.jar"
        Write-Color "pakku.jar download completed." Green
    }
}

# ==== Build Serverpack ====
function Build-Serverpack {
    New-Item -ItemType Directory -Force -Path $SERVER_DIR | Out-Null

    $serverpackZip = Get-ChildItem "$SERVERPACK_DIR" -Filter *.zip -ErrorAction SilentlyContinue | Select-Object -First 1

    Write-Color "Building serverpack using pakku.jar..." Yellow
    & java -jar pakku.jar export
    Write-Color "Serverpack build completed." Green


    if (Test-Path "build/.cache/serverpack") {
        Write-Color "Trying to copy cached serverpack files to $SERVER_DIR" Yellow
        Copy-Item "build/.cache/serverpack/*" "$SERVER_DIR/" -Recurse -Force
        Write-Color "Cache copy completed." Green
    } else {
        Write-Color "Cache have been clear. Extracting serverpack to ./$SERVER_DIR" Yellow
        Get-ChildItem "$SERVERPACK_DIR" -Filter *.zip | ForEach-Object {
            Write-Host "Extracting $($_.FullName) ..."
            Do-Unzip $_.FullName $SERVER_DIR
        }
        Write-Color "serverpack extraction completed." Green
    }
}

# ==== Loader Installer Management ====
function Ensure-LoaderInstaller {
    New-Item -ItemType Directory -Force -Path $SERVER_DIR | Out-Null
    $localInstaller = Get-ChildItem -Filter $INSTALLER_FILE_GLOB -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($localInstaller) {
        Write-Color "Detected local $($localInstaller.Name), copying to $SERVER_DIR" Green
        Copy-Item $localInstaller.FullName "$SERVER_DIR/"
    } else {
        Write-Color "Downloading $LOADER_NAME installer version $LOADER_VERSION..." Yellow
        $targetInstaller = "$SERVER_DIR/$INSTALLER_TARGET_FILE"
        Downloader $LOADER_INSTALLER_URL $targetInstaller
        Write-Color "$LOADER_NAME installer download completed: $targetInstaller" Green
    }
}

# ==== Install Loader ====
function Install-Loader {
    Write-Color "Installing $LOADER_NAME in ./$SERVER_DIR..." Yellow
    Push-Location $SERVER_DIR

    $installer = Get-ChildItem -Filter $INSTALLER_FILE_GLOB -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $installer) {
        Write-Color "$LOADER_NAME installer not found, please check if the download was successful." Red
        exit 1
    }

    if ($LOADER_NAME -eq "fabric") {
        & java -jar $installer.FullName server -mcversion $MC_VERSION -loader $LOADER_VERSION -downloadMinecraft | Out-Null
    } else {
        & java -jar $installer.FullName --installServer | Out-Null
    }
    Write-Color "$LOADER_NAME installation completed." Green

    Write-Color "Generating eula.txt..." Yellow
    "eula=true" | Out-File -Encoding ASCII eula.txt

    Write-Color "Cleaning up invalid files..." Yellow
    Remove-Item $installer.FullName -ErrorAction SilentlyContinue
    Remove-Item installer.log, *.log -ErrorAction SilentlyContinue
    Pop-Location
}

# ==== Main Process ====
Write-Color "==== Pakku Modpack Template Server Build Script ====" Green
Load-Config
Resolve-LoaderFromLockfile
Check-Java
Ensure-Pakku
Build-Serverpack
Ensure-LoaderInstaller
Install-Loader
Write-Color "Build completed! The server has been generated in ./$SERVER_DIR directory. You can now delete other files." Green
