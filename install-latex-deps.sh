#!/usr/bin/env bash
set -euo pipefail

# Installa le dipendenze LaTeX necessarie per compilare la tesi.
# Target: Ubuntu/Debian o distribuzioni derivate con apt-get.

if ! command -v apt-get >/dev/null 2>&1; then
    echo "Errore: questo script richiede apt-get. Usalo su Ubuntu/Debian."
    exit 1
fi

if [[ "${EUID}" -eq 0 ]]; then
    SUDO=""
else
    SUDO="sudo"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGES=(
    latexmk
    biber
    texlive-latex-base
    texlive-latex-recommended
    texlive-latex-extra
    texlive-bibtex-extra
    texlive-fonts-recommended
    texlive-fonts-extra
    texlive-pictures
    texlive-science
    texlive-lang-italian
    poppler-utils
)

echo "Aggiorno l'indice dei pacchetti..."
${SUDO} apt-get update

echo "Installo dipendenze LaTeX per la tesi..."
${SUDO} apt-get install -y "${PACKAGES[@]}"

echo
echo "Dipendenze installate."
echo "Per compilare la tesi completa:"
echo "  cd \"$SCRIPT_DIR\" && latexmk -pdf -synctex=1 -interaction=nonstopmode -halt-on-error tesi.tex"
