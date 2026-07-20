#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Tweaks de Terminal (contenedor)
#  Reutiliza la lógica del lado nativo
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"

header "Tweaks de Terminal"

echo -e "  ${GRAY}Los tweaks se aplican en Termux (compartidos con Arch).${NC}"
echo ""

bash "$HOME/scripts/native/termux_tweaks.sh"