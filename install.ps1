# Windows counterpart to install.sh. Safe to re-run.
#
#   git clone <repo> ~/.config; pwsh ~/.config/install.ps1
#
# install.sh is macOS-only (brew, launchd, defaults), so Windows gets its own
# script instead of a branch of that one.
$ErrorActionPreference = 'Stop'

$ConfigDir = Join-Path $HOME '.config'

# --- keyboard: kanata ---
# The GUI build, not the plain one: it runs as a tray icon with no console
# window, so a login item does not leave a terminal open. winIOv2 (LLHOOK) needs
# no driver, unlike the wintercept builds. Its one catch: it cannot see keys
# typed into elevated windows unless kanata itself runs elevated.
winget install -e --id jtroo.kanata_gui --accept-source-agreements --accept-package-agreements
if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne -1978335189) {
  # -1978335189 (0x8A15002B) is winget's "already installed, no upgrade".
  throw "winget install jtroo.kanata_gui failed ($LASTEXITCODE)"
}

# Points at winget's Links shim rather than the versioned Packages folder, so
# the shortcut survives `winget upgrade`.
$Kanata = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\kanata_windows_gui_winIOv2_x64.exe'
$KanataCfg = Join-Path $ConfigDir 'kanata\kanata.kbd'

# A Startup-folder shortcut rather than a scheduled task: a task is only needed
# to run elevated, and that costs a UAC prompt to set up.
$Startup = [Environment]::GetFolderPath('Startup')
$Shell = New-Object -ComObject WScript.Shell
$Link = $Shell.CreateShortcut((Join-Path $Startup 'kanata.lnk'))
$Link.TargetPath = $Kanata
$Link.Arguments = "-c `"$KanataCfg`""
$Link.WorkingDirectory = Split-Path $KanataCfg
$Link.Save()

# Start it now rather than waiting for the next login. Restart if it is already
# running so a changed config is picked up.
Get-Process kanata_windows_* -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Process -FilePath $Kanata -ArgumentList "-c `"$KanataCfg`"" -WorkingDirectory (Split-Path $KanataCfg)

# --- orca ---
# Orca only reads ~/.orca/keybindings.json, so the tracked copy is linked there.
# Ctrl+, / Ctrl+. switch tabs, the same keys the Chrome rule in
# karabiner/karabiner.json uses on the Mac.
#
# Change shortcuts in the tracked file, not in Orca's Settings: Orca saves by
# writing a temp file and renaming it over this path, which replaces the link
# with a plain file and quietly cuts it off from the repo. Re-running this
# script restores the link, keeping Orca's copy alongside it.
# Symlinks need Developer Mode (or an elevated shell).
$OrcaKeys = Join-Path $HOME '.orca\keybindings.json'
$OrcaKeysSrc = Join-Path $ConfigDir 'orca\keybindings.json'
New-Item -ItemType Directory -Force (Split-Path $OrcaKeys) | Out-Null
$Existing = Get-Item $OrcaKeys -ErrorAction SilentlyContinue
if ($Existing -and -not $Existing.LinkType) {
  Move-Item -Force $OrcaKeys "$OrcaKeys.pre-dotfiles"
  Write-Host "kept Orca's own keybindings.json as $OrcaKeys.pre-dotfiles"
}
New-Item -ItemType SymbolicLink -Force -Path $OrcaKeys -Target $OrcaKeysSrc | Out-Null

# --- neovim ---
# nvim on Windows reads %LOCALAPPDATA%\nvim, not ~/.config/nvim, so the tracked
# config is linked there. Windows-only additions (MSVC environment, build.bat,
# Visual Studio debugging) live in nvim/lua/plugins/windows.lua and do nothing
# on other platforms. Also a symlink, so also needs Developer Mode.
winget install -e --id Neovim.Neovim --accept-source-agreements --accept-package-agreements
if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne -1978335189) {
  throw "winget install Neovim.Neovim failed ($LASTEXITCODE)"
}
$NvimCfg = Join-Path $env:LOCALAPPDATA 'nvim'
$Existing = Get-Item $NvimCfg -ErrorAction SilentlyContinue
if ($Existing -and -not $Existing.LinkType) {
  Move-Item -Force $NvimCfg "$NvimCfg.pre-dotfiles"
  Write-Host "kept the existing nvim config as $NvimCfg.pre-dotfiles"
}
New-Item -ItemType SymbolicLink -Force -Path $NvimCfg -Target (Join-Path $ConfigDir 'nvim') | Out-Null

Write-Host 'done. kanata is running from the tray and starts at login.'
