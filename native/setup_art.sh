#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — GIMP + Audacity (Nativo Termux)
#  Ambos disponibles en tur-repo
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"

header "Suite Gráfica — Termux Nativo (tur-repo)"

RAM_GB=$(config_get RAM_GB)
TO_INSTALL=""
TO_SKIP=""

# — GIMP —
echo -e "${MINT}═══ GIMP ═══${NC}"
if command -v gimp >/dev/null 2>&1; then
    echo -e "  ${GRAY}○ GIMP ya instalado${NC}"
else
    echo -e "  ${GRAY}GIMP usa ~300-500MB de RAM al abrirse.${NC}"
    if [ "$RAM_GB" -le 3 ]; then
        ram_warning "GIMP" "500" "$RAM_GB"
        if ask "¿Instalar de todos modos?" n; then
            TO_INSTALL="${TO_INSTALL}GIMP "
        else
            TO_SKIP="${TO_SKIP}GIMP "
        fi
    else
        if ask "¿Instalar GIMP?" y; then
            TO_INSTALL="${TO_INSTALL}GIMP "
        else
            TO_SKIP="${TO_SKIP}GIMP "
        fi
    fi
fi

# — LibreSprite —
echo ""
echo -e "${MINT}═══ LibreSprite ═══${NC}"
echo -e "  ${GRAY}Editor de pixel art ligero (~50MB RAM).${NC}"
if command -v libresprite >/dev/null 2>&1; then
    echo -e "  ${GRAY}○ LibreSprite ya instalado${NC}"
else
    if ask "¿Instalar LibreSprite?" y; then
        TO_INSTALL="${TO_INSTALL}LibreSprite "
    else
        TO_SKIP="${TO_SKIP}LibreSprite "
    fi
fi

# — ImageMagick —
echo ""
echo -e "${MINT}═══ ImageMagick ═══${NC}"
echo -e "  ${GRAY}Herramientas CLI para manipular imágenes.${NC}"
if command -v convert >/dev/null 2>&1 || command -v magick >/dev/null 2>&1; then
    echo -e "  ${GRAY}○ ImageMagick ya instalado${NC}"
else
    if ask "¿Instalar ImageMagick?" y; then
        TO_INSTALL="${TO_INSTALL}ImageMagick "
    else
        TO_SKIP="${TO_SKIP}ImageMagick "
    fi
fi

# — Audacity —
echo ""
echo -e "${MINT}═══ Audacity ═══${NC}"
if command -v audacity >/dev/null 2>&1; then
    echo -e "  ${GRAY}○ Audacity ya instalado${NC}"
else
    echo -e "  ${GRAY}Audacity usa ~200-400MB de RAM al abrirse.${NC}"
    if [ "$RAM_GB" -le 3 ]; then
        ram_warning "Audacity" "400" "$RAM_GB"
        if ask "¿Instalar de todos modos?" n; then
            TO_INSTALL="${TO_INSTALL}Audacity "
        else
            TO_SKIP="${TO_SKIP}Audacity "
        fi
    else
        if ask "¿Instalar Audacity?" y; then
            TO_INSTALL="${TO_INSTALL}Audacity "
        else
            TO_SKIP="${TO_SKIP}Audacity "
        fi
    fi
fi

# — Resumen —
summary "Suite Gráfica" "$TO_INSTALL" "$TO_SKIP"

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

if echo "$TO_INSTALL" | grep -q "GIMP"; then
    install_pkg "gimp" "GIMP"
    command -v gimp >/dev/null 2>&1 || ERRORS=$((ERRORS + 1))
fi

if echo "$TO_INSTALL" | grep -q "LibreSprite"; then
    install_pkg "libresprite" "LibreSprite"
    command -v libresprite >/dev/null 2>&1 || ERRORS=$((ERRORS + 1))
fi

if echo "$TO_INSTALL" | grep -q "ImageMagick"; then
    install_pkg "imagemagick" "ImageMagick"
    command -v convert >/dev/null 2>&1 || command -v magick >/dev/null 2>&1 || ERRORS=$((ERRORS + 1))
fi

if echo "$TO_INSTALL" | grep -q "Audacity"; then
    install_pkg "audacity" "Audacity"
    command -v audacity >/dev/null 2>&1 || ERRORS=$((ERRORS + 1))
fi

# — Verificación —
echo ""
if [ "$ERRORS" -eq 0 ]; then
    echo -e "  ${LIME}✓ Suite gráfica instalada correctamente.${NC}"
    exit 0
else
    echo -e "  ${RED}✗ Algunas instalaciones fallaron.${NC}"
    exit 1
fi