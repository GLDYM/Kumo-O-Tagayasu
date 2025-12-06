# Kumo-O-Tagayasu Server Build Script (PowerShell)
# Requires PowerShell 5+ and JDK 21

$ErrorActionPreference = "Stop"

# === Configuration ===
$PAKKU_URL = "https://github.com/juraj-hrivnak/Pakku/releases/download/v1.3.2/pakku.jar"
$FORGE_VERSION = $env:FORGE_VERSION
if (-not $FORGE_VERSION) { $FORGE_VERSION = "1.20.1-47.4.6" }
$FORGE_URL = "https://maven.minecraftforge.net/net/minecraftforge/forge/$FORGE_VERSION/forge-$FORGE_VERSION-installer.jar"

$SERVER_DIR = "server"
$SERVERPACK_DIR = "build/serverpack"

# === Color Prompts ===
function Write-Color($Text, $Color="White") {
    Write-Host $Text -ForegroundColor $Color
}

# === Utility Functions ===
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

# === Check Java ===
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


# === pakku Management ===
function Ensure-Pakku {
    if (Test-Path "pakku.jar") {
        Write-Color "pakku.jar already exists, skipping download." Green
    } else {
        Write-Color "Downloading pakku.jar..." Yellow
        Downloader $PAKKU_URL "pakku.jar"
        Write-Color "pakku.jar download completed." Green
    }
}

# === Build Serverpack ===
function Build-Serverpack {
    New-Item -ItemType Directory -Force -Path $SERVER_DIR | Out-Null

    $serverpackZip = Get-ChildItem "$SERVERPACK_DIR" -Filter *.zip -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($serverpackZip) {
        Write-Color "Detected existing serverpack file $($serverpackZip.FullName), skipping build." Green
    } else {
        Write-Color "Building serverpack using pakku.jar..." Yellow
        & java -jar pakku.jar export
        Write-Color "Serverpack build completed." Green
    }

    if (Test-Path "build/.cache/serverpack") {
        Write-Color "Trying to copy cached serverpack files to $SERVERPACK_DIR" Yellow
        Copy-Item "build/.cache/serverpack/"* "$SERVERPACK_DIR/" -Force
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

# === Forge Installer Management ===
function Ensure-ForgeInstaller {
    New-Item -ItemType Directory -Force -Path $SERVER_DIR | Out-Null
    $localInstaller = Get-ChildItem -Filter "forge-*-installer.jar" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($localInstaller) {
        Write-Color "Detected local $($localInstaller.Name), copying to $SERVER_DIR" Green
        Copy-Item $localInstaller.FullName "$SERVER_DIR/"
    } else {
        Write-Color "Downloading Forge installer version $FORGE_VERSION..." Yellow
        $targetInstaller = "$SERVER_DIR/forge-$FORGE_VERSION-installer.jar"
        Downloader $FORGE_URL $targetInstaller
        Write-Color "Forge installer download completed: $targetInstaller" Green
    }
}

# === Install Forge ===
function Install-Forge {
    Write-Color "Installing Forge in ./$SERVER_DIR..." Yellow
    Push-Location $SERVER_DIR

    $installer = Get-ChildItem -Filter "forge-*-installer.jar" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $installer) {
        Write-Color "Forge installer not found, please check if the download was successful." Red
        exit 1
    }

    & java -jar $installer.FullName --installServer | Out-Null
    Write-Color "Forge installation completed." Green

    Write-Color "Generating eula.txt..." Yellow
    "eula=true" | Out-File -Encoding ASCII eula.txt

    Write-Color "Cleaning up invalid files..." Yellow
    Remove-Item $installer.FullName -ErrorAction SilentlyContinue
    Remove-Item installer.log, *.log -ErrorAction SilentlyContinue
    Pop-Location
}

# === Main Process ===
Write-Color "==== Kumo-O-Tagayasu Server Build Script ====" Green
Check-Java
Ensure-Pakku
Build-Serverpack
Ensure-ForgeInstaller
Install-Forge
Write-Color "Build completed! The server has been generated in ./$SERVER_DIR directory. You can now delete other files." Green
