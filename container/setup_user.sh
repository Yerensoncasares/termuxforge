#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Crear usuario en Arch
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"
source "$HOME/scripts/container/proot_helper.sh"

header "Configuración de Usuario en Arch"

arch_check || exit 1

FORGE_USER="forge"
FORGE_GROUP="users"

# Verificar si ya existe
if arch_cmd "id $FORGE_USER &>/dev/null"; then
    echo -e "  ${GRAY}○ Usuario '${FORGE_USER}' ya existe.${NC}"
    exit 0
fi

# Crear usuario
echo -e "${MINT}Creando usuario '${FORGE_USER}'...${NC}"
arch_root "
    useradd -m -s /bin/bash $FORGE_USER 2>/dev/null
    echo '${FORGE_USER}:forge' | chpasswd
    echo '$FORGE_USER ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
    mkdir -p /home/$FORGE_USER
    chown -R $FORGE_USER:$FORGE_GROUP /home/$FORGE_USER
" 2>&1

if arch_cmd "id $FORGE_USER &>/dev/null"; then
    echo -e "  ${LIME}✓${NC} Usuario '${FORGE_USER}' creado."
    echo -e "  ${GRAY}Password: forge${NC}"
    echo -e "  ${GRAY}Sudo: sin contraseña${NC}"
else
    echo -e "  ${RED}✗ Falló la creación del usuario.${NC}"
    exit 1
fi