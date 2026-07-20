#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Termux:X11 (Nativo Termux)
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"

header "Termux:X11 — Display Local"

DISPLAY_MODE=$(config_get DISPLAY_MODE)

# Si el modo es solo VNC, preguntar si quiere X11 de todos modos
if [ "$DISPLAY_MODE" = "vnc" ]; then
    echo -e "  ${YELLOW}Tu modo de display actual es VNC exclusivo.${NC}"
    if ! ask "¿Instalar Termux:X11 de todos modos?" n; then
        echo -e "  ${GRAY}Omitido.${NC}"
        exit 0
    fi
fi

TO_INSTALL=""
TO_SKIP=""

# Termux:X11
echo -e "${MINT}═══ Termux:X11 ═══${NC}"
if command -v termux-x11 >/dev/null 2>&1; then
    echo -e "  ${GRAY}○ Termux:X11 ya instalado${NC}"
else
    if ask "¿Instalar Termux:X11 Nightly?" y; then
        TO_INSTALL="${TO_INSTALL}Termux:X11 "
    else
        TO_SKIP="${TO_SKIP}Termux:X11 "
    fi
fi

# GPU acceleration para X11
echo ""
echo -e "${MINT}═══ Aceleración gráfica ═══${NC}"
echo -e "  ${GRAY}Para Termux:X11 necesitas aceleración gráfica.${NC}"
echo -e "  ${GRAY}Esto permite que las apps usen la GPU real del teléfono.${NC}"
echo ""

if pkg list-installed 2>/dev/null | grep -q "mesa-zink"; then
    echo -e "  ${GRAY}○ Mesa Zink ya instalado${NC}"
else
    if ask "¿Instalar Mesa Zink (aceleración OpenGL)?" y; then
        TO_INSTALL="${TO_INSTALL}Mesa_Zink "
    else
        TO_SKIP="${TO_SKIP}Mesa_Zink "
    fi
fi

if pkg list-installed 2>/dev/null | grep -q "virglrenderer"; then
    echo -e "  ${GRAY}○ VirGL ya instalado${NC}"
else
    if ask "¿Instalar VirGL Renderer (GPU virtualizada)?" y; then
        TO_INSTALL="${TO_INSTALL}VirGL "
    else
        TO_SKIP="${TO_SKIP}VirGL "
    fi
fi

summary "Termux:X11" "$TO_INSTALL" "$TO_SKIP"

if [ -z "$TO_INSTALL" ]; then
    echo -e "  ${GRAY}Nada que instalar.${NC}"
    exit 0
fi

if ! ask "¿Proceder?" y; then
    echo -e "  ${GRAY}Cancelado.${NC}"
    exit 0
fi

# — Instalar —
echo ""
ERRORS=0

if echo "$TO_INSTALL" | grep -q "Termux:X11"; then
    install_pkg "termux-x11-nightly" "Termux:X11"
    command -v termux-x11 >/dev/null 2>&1 || ERRORS=$((ERRORS + 1))
fi

if echo "$TO_INSTALL" | grep -q "Mesa_Zink"; then
    install_pkg "mesa-zink" "Mesa Zink"
    pkg list-installed 2>/dev/null | grep -q "mesa-zink" || ERRORS=$((ERRORS + 1))
fi

if echo "$TO_INSTALL" | grep -q "VirGL"; then
    install_pkg "virglrenderer-mesa-zink" "VirGL Renderer"
    pkg list-installed 2>/dev/null | grep -q "virglrenderer" || ERRORS=$((ERRORS + 1))
fi

# — Verificación —
echo ""
echo -e "${MINT}Verificación:${NC}"
if command -v termux-x11 >/dev/null 2>&1; then
    echo -e "  ${LIME}✓${NC} termux-x11"
else
    echo -e "  ${RED}✗${NC} termux-x11 faltante"
    ERRORS=$((ERRORS + 1))
fi

echo ""
if [ "$ERRORS" -eq 0 ]; then
    echo -e "  ${LIME}✓ Termux:X11 configurado.${NC}"
    echo -e "  ${GRAY}Nota: Necesitas la app 'Termux:X11' instalada desde F-Droid.${NC}"
    echo -e "  ${GRAY}Para iniciar: bash ~/start-forge.sh${NC}"
    exit 0
else
    echo -e "  ${RED}✗ La instalación falló.${NC}"
    exit 1
fi