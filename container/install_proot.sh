#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Instalar Arch Linux (proot-distro)
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"
source "$HOME/scripts/container/proot_helper.sh"

header "Instalación de Arch Linux"

if proot-distro list 2>/dev/null | grep -q "archlinuxarm"; then
    echo -e "  ${GRAY}○ Arch Linux ya está instalado.${NC}"
    if ! ask "¿Reinstalar desde cero? (borra todo)" n; then
        echo -e "  ${GRAY}Omitido.${NC}"
        exit 0
    fi
    echo ""
    echo -e "${YELLOW}Eliminando instalación anterior...${NC}"
    proot-distro remove archlinuxarm --force 2>/dev/null
    echo -e "  ${LIME}✓${NC} Eliminado"
fi

echo ""
echo -e "${MINT}Descargando e instalando Arch Linux ARM...${NC}"
echo -e "${YELLOW}Esto puede tardar 5-15 minutos según tu conexión.${NC}"
echo ""

if proot-distro install danhunsaker/archlinuxarm:latest 2>&1; then
    echo ""
    echo -e "  ${LIME}✓ Arch Linux instalado correctamente.${NC}"
    echo -e "  ${GRAY}Ahora optimiza pacman y crea el usuario.${NC}"
    exit 0
else
    echo ""
    echo -e "  ${RED}✗ La instalación falló.${NC}"
    echo -e "  ${GRAY}Verifica tu conexión a internet e inténtalo de nuevo.${NC}"
    exit 1
fi