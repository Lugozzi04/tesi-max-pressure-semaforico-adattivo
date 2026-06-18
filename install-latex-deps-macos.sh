#!/usr/bin/env bash
set -euo pipefail

# Installa le dipendenze LaTeX su macOS usando Homebrew.
# Il progetto usa MacTeX (full TeX Live senza GUI) e poppler.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v brew >/dev/null 2>&1; then
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$candidate" ]]; then
            eval "$("$candidate" shellenv)"
            break
        fi
    done
fi

if ! command -v brew >/dev/null 2>&1; then
    echo "Errore: Homebrew non trovato."
    echo "Installa Homebrew da https://brew.sh/ e rilancia questo script."
    exit 1
fi

echo "Aggiorno Homebrew..."
brew update

echo "Installo MacTeX (no GUI)..."
brew install --cask mactex-no-gui

echo "Installo poppler..."
brew install poppler

if [[ -x /usr/libexec/path_helper ]]; then
    eval "$(/usr/libexec/path_helper -s)"
fi

echo
echo "Dipendenze installate."
echo "Se la shell non vede ancora i comandi TeX, riaprila."
echo "Per compilare la tesi completa:"
echo "  cd \"$SCRIPT_DIR\" && latexmk -pdf -synctex=1 -interaction=nonstopmode -halt-on-error tesi.tex"
