#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Node.js + Python (Nativo Termux)
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"

header "Node.js + Python — Termux Nativo"

TO_INSTALL=""
TO_SKIP=""

# — Node.js —
echo -e "${MINT}═══ Node.js ═══${NC}"
if command -v node >/dev/null 2>&1; then
    local_ver=$(node -v 2>/dev/null)
    echo -e "  ${GRAY}○ Node.js ya instalado (${local_ver})${NC}"
else
    if ask "¿Instalar Node.js?" y; then
        TO_INSTALL="${TO_INSTALL}Node.js "
    else
        TO_SKIP="${TO_SKIP}Node.js "
    fi
fi

# — Python —
echo ""
echo -e "${MINT}═══ Python ═══${NC}"
if command -v python3 >/dev/null 2>&1; then
    local_ver=$(python3 --version 2>/dev/null)
    echo -e "  ${GRAY}○ Python ya instalado (${local_ver})${NC}"
else
    if ask "¿Instalar Python?" y; then
        TO_INSTALL="${TO_INSTALL}Python "
    else
        TO_SKIP="${TO_SKIP}Python "
    fi
fi

# — pip (viene con python, pero por si acaso) —
echo ""
echo -e "${MINT}═══ pip ═══${NC}"
if command -v pip3 >/dev/null 2>&1; then
    echo -e "  ${GRAY}○ pip ya disponible${NC}"
else
    if ask "¿Instalar pip?" y; then
        TO_INSTALL="${TO_INSTALL}pip "
    else
        TO_SKIP="${TO_SKIP}pip "
    fi
fi

# — Resumen —
summary "Node.js + Python" "$TO_INSTALL" "$TO_SKIP"

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

if echo "$TO_INSTALL" | grep -q "Node.js"; then
    install_pkg "nodejs" "Node.js"
    command -v node >/dev/null 2>&1 || ERRORS=$((ERRORS + 1))
fi

if echo "$TO_INSTALL" | grep -q "Python"; then
    install_pkg "python" "Python"
    command -v python3 >/dev/null 2>&1 || ERRORS=$((ERRORS + 1))
fi

if echo "$TO_INSTALL" | grep -q "pip"; then
    # pip ya viene con python en Termux, pero aseguramos
    if ! command -v pip3 >/dev/null 2>&1; then
        install_pkg "python-pip" "pip"
    else
        echo -e "  ${GRAY}○ pip incluido con Python${NC}"
    fi
fi

# — Verificación —
echo ""
if [ "$ERRORS" -eq 0 ]; then
    echo -e "  ${LIME}✓ Todo instalado correctamente.${NC}"
    echo -e "  ${GRAY}Node: $(node -v 2>/dev/null || echo 'N/A')${NC}"
    echo -e "  ${GRAY}Python: $(python3 --version 2>/dev/null || echo 'N/A')${NC}"
    exit 0
else
    echo -e "  ${RED}✗ Algunas instalaciones fallaron.${NC}"
    exit 1
fi