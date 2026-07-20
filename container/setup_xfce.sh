#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — XFCE4 dentro de Arch
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"
source "$HOME/scripts/container/proot_helper.sh"

header "XFCE4 — Dentro de Arch Linux"

arch_check || exit 1

RAM_GB=$(config_get RAM_GB)

if [ "$RAM_GB" -le 2 ]; then
    echo -e "  ${RED}⚠ ${RAM_GB}GB RAM. XFCE4 en proot usará más recursos.${NC}"
    if ! ask "¿Continuar?" n; then exit 0; fi
elif [ "$RAM_GB" -le 3 ]; then
    ram_warning "XFCE4 en proot" "400" "$RAM_GB"
    if ! ask "¿Continuar?" n; then exit 0; fi
fi

TO_INSTALL=""
TO_SKIP=""

XFCE_ITEMS=(
    "xfce4:Escritorio XFCE4"
    "xfce4-terminal:Terminal XFCE4"
    "thunar:Gestor de archivos Thunar"
    "mousepad:Editor Mousepad"
    "ristretto:Visor de imágenes"
    "xfce4-taskmanager:Administrador de tareas"
    "tumbler:Miniaturas Thunar"
    "xdg-desktop-portal:Portal de escritorio"
)

for item in "${XFCE_ITEMS[@]}"; do
    pkg="${item%%:*}"
    desc="${item##*:}"
    if arch_has "$pkg"; then
        echo -e "  ${GRAY}○ ${desc} ya instalado${NC}"
    else
        if ask "¿Instalar ${desc}?" y; then
            TO_INSTALL="${TO_INSTALL}${pkg} "
        else
            TO_SKIP="${TO_SKIP}${desc} "
        fi
    fi
done

summary "XFCE4 en Arch" "$TO_INSTALL" "$TO_SKIP"

if [ -z "$TO_INSTALL" ]; then
    echo -e "  ${GRAY}Nada que instalar.${NC}"
    exit 0
fi

if ! ask "¿Proceder?" y; then
    echo -e "  ${GRAY}Cancelado.${NC}"
    exit 0
fi

echo ""
arch_wait_lock || exit 1
arch_install "$TO_INSTALL"

# Compositor OFF por defecto
arch_root "mkdir -p /home/forge/.config/xfce4/xfconf/xfce-perchannel-xml"
arch_write "/home/forge/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="use_compositing" type="bool" value="false"/>
  </property>
</channel>
EOF
arch_root "chown -R forge:users /home/forge/.config"

echo ""
echo -e "  ${LIME}✓ XFCE4 instalado en Arch.${NC}"