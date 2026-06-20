#!/usr/bin/env bash
set -euo pipefail

# Installa le dipendenze LaTeX su macOS usando Homebrew.
# Il progetto usa MacTeX (full TeX Live senza GUI) e poppler.
# Alla fine compila subito la tesi nella stessa shell.

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

if [[ -d /Library/TeX/texbin ]]; then
    export PATH="/Library/TeX/texbin:$PATH"
fi

cd "$SCRIPT_DIR"

echo
echo "Compilazione iniziale in corso..."
pdflatex -synctex=1 -interaction=nonstopmode -file-line-error -halt-on-error tesi.tex
biber tesi
pdflatex -synctex=1 -interaction=nonstopmode -file-line-error -halt-on-error tesi.tex
pdflatex -synctex=1 -interaction=nonstopmode -file-line-error -halt-on-error tesi.tex

echo
echo "Compilazione completata."
