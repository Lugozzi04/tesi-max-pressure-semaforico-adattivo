# Installa le dipendenze LaTeX su Windows usando MiKTeX.
# MiKTeX scarica automaticamente i pacchetti mancanti quando compili.
# Il workspace usa una recipe LaTeX Workshop basata su pdflatex + biber,
# quindi non serve Perl.

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Add-MiKTeXPathToSession {
    $CandidatePaths = @(
        (Join-Path $env:LOCALAPPDATA 'Programs\MiKTeX\miktex\bin\x64'),
        (Join-Path $env:ProgramFiles 'MiKTeX\miktex\bin\x64')
    )

    foreach ($CandidatePath in $CandidatePaths) {
        if (Test-Path $CandidatePath) {
            $CurrentPaths = $env:Path -split ';' | Where-Object { $_ }
            if ($CurrentPaths -notcontains $CandidatePath) {
                $env:Path = "$CandidatePath;$env:Path"
            }
        }
    }
}

function Invoke-Tool {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    Write-Host "Eseguo: $Command $($Arguments -join ' ')"
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Command ha restituito codice $LASTEXITCODE."
    }
}

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

Add-MiKTeXPathToSession

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

Push-Location $ScriptDir
try {
    Write-Host ""
    Write-Host "Compilazione iniziale in corso..."
    Invoke-Tool -Command 'pdflatex' -Arguments @(
        '-synctex=1',
        '-interaction=nonstopmode',
        '-file-line-error',
        '-halt-on-error',
        'tesi.tex'
    )
    Invoke-Tool -Command 'biber' -Arguments @('tesi')
    Invoke-Tool -Command 'pdflatex' -Arguments @(
        '-synctex=1',
        '-interaction=nonstopmode',
        '-file-line-error',
        '-halt-on-error',
        'tesi.tex'
    )
    Invoke-Tool -Command 'pdflatex' -Arguments @(
        '-synctex=1',
        '-interaction=nonstopmode',
        '-file-line-error',
        '-halt-on-error',
        'tesi.tex'
    )
    Write-Host ""
    Write-Host "Compilazione completata."
} finally {
    Pop-Location
}
