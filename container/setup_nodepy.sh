#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Node.js + Python en Termux
#  (Para uso nativo, accesibles desde Arch)
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"

header "Node.js + Python — Termux Host"

# Reutiliza la lógica del script nativo
bash "$HOME/scripts/native/setup_nodepy.sh"