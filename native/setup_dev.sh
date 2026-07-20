#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — VS Code + Godot (Nativo Termux)
#  Usa tur-repo, no necesita contenedor
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"

header "VS Code + Godot — Termux Nativo (tur-repo)"

RAM_GB=$(config_get RAM_GB)
TO_INSTALL=""
TO_SKIP=""

# — VS Code OSS —
echo -e "${MINT}═══ VS Code OSS ═══${NC}"
if command -v code-oss >/dev/null 2>&1; then
    echo -e "  ${GRAY}○ VS Code ya instalado${NC}"
    TO_INSTALL="${TO_INSTALL}VS_Code "
else
    if [ "$RAM_GB" -le 3 ]; then
        ram_warning "VS Code" "400" "$RAM_GB"
        if ask "¿Instalar VS Code de todos modos?" n; then
            TO_INSTALL="${TO_INSTALL}VS_Code "
        else
            TO_SKIP="${TO_SKIP}VS_Code "
        fi
    else
        if ask "¿Instalar VS Code OSS?" y; then
            TO_INSTALL="${TO_INSTALL}VS_Code "
        else
            TO_SKIP="${TO_SKIP}VS_Code "
        fi
    fi
fi

# — Godot —
echo ""
echo -e "${MINT}═══ Godot Engine ═══${NC}"
if command -v godot >/dev/null 2>&1; then
    echo -e "  ${GRAY}○ Godot ya instalado${NC}"
    TO_INSTALL="${TO_INSTALL}Godot "
else
    if ask "¿Instalar Godot Engine?" y; then
        TO_INSTALL="${TO_INSTALL}Godot "
    else
        TO_SKIP="${TO_SKIP}Godot "
    fi
fi

# — Resumen —
summary "VS Code + Godot" "$TO_INSTALL" "$TO_SKIP"

if [ -z "$TO_INSTALL" ]; then
    echo -e "  ${GRAY}Nada que instalar. Saliendo.${NC}"
    exit 0
fi

if ! ask "¿Proceder con la instalación?" y; then
    echo -e "  ${GRAY}Cancelado.${NC}"
    exit 0
fi

# — Instalar —
echo ""
ERRORS=0

if echo "$TO_INSTALL" | grep -q "VS_Code"; then
    install_pkg "code-oss" "VS Code OSS"
    if ! command -v code-oss >/dev/null 2>&1; then
        ERRORS=$((ERRORS + 1))
    fi
fi

if echo "$TO_INSTALL" | grep -q "Godot"; then
    install_pkg "godot" "Godot Engine"
    if ! command -v godot >/dev/null 2>&1; then
        ERRORS=$((ERRORS + 1))
    fi
fi

# — Verificación —
echo ""
if [ "$ERRORS" -eq 0 ]; then
    echo -e "  ${LIME}✓ Todo instalado correctamente.${NC}"
    exit 0
else
    echo -e "  ${RED}✗ Algunas instalaciones fallaron.${NC}"
    exit 1
fi