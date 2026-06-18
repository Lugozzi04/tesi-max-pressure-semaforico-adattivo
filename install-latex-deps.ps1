# Installa le dipendenze LaTeX su Windows usando MiKTeX.
# MiKTeX scarica automaticamente i pacchetti mancanti quando compili.

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Invoke-WingetInstall {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageId
    )

    Write-Host "Provo a installare $PackageId con winget..."
    & winget install --id $PackageId --exact --silent --accept-package-agreements --accept-source-agreements
    return ($LASTEXITCODE -eq 0)
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Errore: winget non trovato."
    Write-Host "Installa 'App Installer' di Microsoft oppure scarica MiKTeX da:"
    Write-Host "  https://miktex.org/download"
    exit 1
}

$Installed = $false
foreach ($PackageId in @('MiKTeX.MiKTeX', 'ChristianSchenk.MiKTeX')) {
    if (Invoke-WingetInstall -PackageId $PackageId) {
        $Installed = $true
        break
    }
}

if (-not $Installed) {
    throw "Impossibile installare MiKTeX con winget."
}

$Initexmf = Get-Command initexmf -ErrorAction SilentlyContinue
if ($Initexmf) {
    & $Initexmf.Source '--set-config-value=[MPM]AutoInstall=1'
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Avviso: non sono riuscito ad abilitare l'auto-installazione da CLI."
        Write-Host "Apri MiKTeX Console e imposta 'Always install missing packages on-the-fly'."
    }
} else {
    Write-Host "Apri MiKTeX Console e imposta 'Always install missing packages on-the-fly'."
}

Write-Host ""
Write-Host "Dipendenze installate."
Write-Host "Apri una nuova shell, poi compila con:"
Write-Host "  cd `"$ScriptDir`""
Write-Host "  latexmk -pdf -synctex=1 -interaction=nonstopmode -halt-on-error tesi.tex"
