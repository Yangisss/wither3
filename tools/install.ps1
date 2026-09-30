<#
    Loot Multiplier - установщик / деинсталлятор
    The Witcher 3: Wild Hunt - Remastered (5.00+)

    Установка:
        powershell -ExecutionPolicy Bypass -File install.ps1
        powershell -ExecutionPolicy Bypass -File install.ps1 -GamePath "D:\Games\The Witcher 3"

    Удаление:
        powershell -ExecutionPolicy Bypass -File install.ps1 -Uninstall
#>

param(
    [string]$GamePath = "",
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

$ModName    = "modLootMultiplier"
$MenuFile   = "modLootMultiplier.xml"
$RepoRoot   = Split-Path -Parent $PSScriptRoot
$SrcMod     = Join-Path $RepoRoot $ModName
$SrcMenu    = Join-Path $RepoRoot "bin\config\r4game\user_config_matrix\pc\$MenuFile"

function Write-Info($text)  { Write-Host "[i] $text" -ForegroundColor Cyan }
function Write-Ok($text)    { Write-Host "[+] $text" -ForegroundColor Green }
function Write-Warn($text)  { Write-Host "[!] $text" -ForegroundColor Yellow }

function Test-GameDir($path) {
    if (-not $path) { return $false }
    return (Test-Path (Join-Path $path "witcher3.exe")) -and (Test-Path (Join-Path $path "bin"))
}

function Find-GamePath {
    # 1. GOG
    $gogIds = @("1207664643", "1495134320", "1640424747", "1971474941")
    foreach ($id in $gogIds) {
        $key = "HKLM:\SOFTWARE\WOW6432Node\GOG.com\Games\$id"
        if (Test-Path $key) {
            $p = (Get-ItemProperty -Path $key -Name "path" -ErrorAction SilentlyContinue).path
            if (Test-GameDir $p) { return $p }
        }
    }

    # 2. Steam (основная библиотека + дополнительные из libraryfolders.vdf)
    $steam = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -Name "InstallPath" -ErrorAction SilentlyContinue).InstallPath
    if (-not $steam) {
        $steam = (Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name "SteamPath" -ErrorAction SilentlyContinue).SteamPath
    }

    $libs = New-Object System.Collections.ArrayList
    if ($steam) { [void]$libs.Add($steam) }

    if ($steam -and (Test-Path (Join-Path $steam "steamapps\libraryfolders.vdf"))) {
        $vdf = Get-Content (Join-Path $steam "steamapps\libraryfolders.vdf") -ErrorAction SilentlyContinue
        foreach ($line in $vdf) {
            if ($line -match '"path"\s+"(.+)"') { [void]$libs.Add(($matches[1] -replace '\\\\', '\')) }
        }
    }

    foreach ($lib in $libs) {
        $p = Join-Path $lib "steamapps\common\The Witcher 3"
        if (Test-GameDir $p) { return $p }
    }

    # 3. Частые пути
    $common = @(
        "C:\Program Files (x86)\Steam\steamapps\common\The Witcher 3",
        "C:\GOG Games\The Witcher 3 Wild Hunt GOTY",
        "D:\SteamLibrary\steamapps\common\The Witcher 3",
        "D:\GOG Games\The Witcher 3 Wild Hunt GOTY",
        "D:\Games\The Witcher 3"
    )
    foreach ($p in $common) { if (Test-GameDir $p) { return $p } }

    return $null
}

function Add-ToFileList($dir) {
    foreach ($file in @("dx11filelist.txt", "dx12filelist.txt")) {
        $full = Join-Path $dir $file
        if (-not (Test-Path $full)) { Write-Warn "Нет файла $file - пропускаю"; continue }

        $lines = Get-Content $full -ErrorAction SilentlyContinue
        if ($lines -contains "$MenuFile;") { Write-Info "$file уже содержит $MenuFile"; continue }

        Add-Content -Path $full -Value "$MenuFile;" -Encoding ASCII
        Write-Ok "Добавлено $MenuFile в $file"
    }
}

function Remove-FromFileList($dir) {
    foreach ($file in @("dx11filelist.txt", "dx12filelist.txt")) {
        $full = Join-Path $dir $file
        if (-not (Test-Path $full)) { continue }

        $lines = Get-Content $full | Where-Object { $_ -ne "$MenuFile;" }
        Set-Content -Path $full -Value $lines -Encoding ASCII
        Write-Ok "Убрано $MenuFile из $file"
    }
}

# ---------- путь к игре ----------
if ($GamePath -and -not (Test-GameDir $GamePath)) {
    Write-Warn "По пути $GamePath не похоже на папку с игрой"
    $GamePath = ""
}

if (-not $GamePath) {
    Write-Info "Ищу игру..."
    $GamePath = Find-GamePath
}

if (-not $GamePath) {
    $GamePath = Read-Host "Не нашёл игру сам. Введи путь к папке с witcher3.exe"
}

if (-not (Test-GameDir $GamePath)) {
    Write-Host "[-] Путь неверный: $GamePath" -ForegroundColor Red
    exit 1
}

Write-Ok "Игра найдена: $GamePath"

$modsDir   = Join-Path $GamePath "mods"
$menuDir   = Join-Path $GamePath "bin\config\r4game\user_config_matrix\pc"
$dstMod    = Join-Path $modsDir $ModName
$dstMenu   = Join-Path $menuDir $MenuFile

if (-not $Uninstall) {
    if (-not (Test-Path $SrcMod))  { Write-Host "[-] Нет папки $SrcMod" -ForegroundColor Red; exit 1 }
    if (-not (Test-Path $SrcMenu)) { Write-Host "[-] Нет файла $SrcMenu" -ForegroundColor Red; exit 1 }

    if (-not (Test-Path $modsDir)) { New-Item -ItemType Directory -Path $modsDir | Out-Null }
    if (-not (Test-Path $menuDir)) { New-Item -ItemType Directory -Path $menuDir | Out-Null }

    if (Test-Path $dstMod) { Remove-Item $dstMod -Recurse -Force }
    Copy-Item $SrcMod -Destination $dstMod -Recurse -Force
    Write-Ok "Скопировано: mods\$ModName"

    Copy-Item $SrcMenu -Destination $dstMenu -Force
    Write-Ok "Скопировано: bin\config\r4game\user_config_matrix\pc\$MenuFile"

    Add-ToFileList $menuDir

    Write-Host ""
    Write-Ok "Готово. В игре: Настройки -> Моды -> Loot Multiplier."
    Write-Host "    Мод меняет только то, что ты подбираешь руками/автолутом."
    Write-Host "    Чтобы проверить, что скрипт загрузился: включи консоль"
    Write-Host "    (bin\config\base\general.ini -> DBGConsoleOn=true), нажми ~ и набери lm_status()"
} else {
    if (Test-Path $dstMod) { Remove-Item $dstMod -Recurse -Force; Write-Ok "Удалено mods\$ModName" }
    if (Test-Path $dstMenu) { Remove-Item $dstMenu -Force; Write-Ok "Удалено $MenuFile" }
    Remove-FromFileList $menuDir
    Write-Ok "Готово, мод удалён."
}
