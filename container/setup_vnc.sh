#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — TigerVNC dentro de Arch
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"
source "$HOME/scripts/container/proot_helper.sh"

header "TigerVNC — Dentro de Arch Linux"

arch_check || exit 1

DISPLAY_MODE=$(config_get DISPLAY_MODE)
if [ "$DISPLAY_MODE" = "x11" ]; then
    echo -e "  ${YELLOW}Modo actual: X11 exclusivo.${NC}"
    if ! ask "¿Instalar VNC de todos modos?" n; then exit 0; fi
fi

TO_INSTALL=""
TO_SKIP=""

if arch_has "tigervnc"; then
    echo -e "  ${GRAY}○ TigerVNC ya instalado en Arch${NC}"
else
    if ask "¿Instalar TigerVNC en Arch?" y; then
        TO_INSTALL="${TO_INSTALL}tigervnc "
    else
        TO_SKIP="${TO_SKIP}TigerVNC "
    fi
fi

if arch_has "xorg-xrandr"; then
    echo -e "  ${GRAY}○ xorg-xrandr ya instalado${NC}"
else
    if ask "¿Instalar xorg-xrandr?" y; then
        TO_INSTALL="${TO_INSTALL}xorg-xrandr "
    else
        TO_SKIP="${TO_SKIP}xorg-xrandr "
    fi
fi

summary "TigerVNC en Arch" "$TO_INSTALL" "$TO_SKIP"

if [ -z "$TO_INSTALL" ]; then
    echo -e "  ${GRAY}Nada que instalar.${NC}"
    exit 0
fi

if ! ask "¿Proceder?" y; then exit 0; fi

echo ""
arch_wait_lock || exit 1
arch_install "$TO_INSTALL"

# — xstartup —
arch_write "/home/forge/.vnc/xstartup" << 'VNCEOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export PULSE_SERVER=127.0.0.1

export GALLIUM_DRIVER=llvmpipe
export MESA_LOADER_DRIVER_OVERRIDE=swrast
export LIBGL_ALWAYS_SOFTWARE=1
export MESA_GL_VERSION_OVERRIDE=3.1

startxfce4 >/dev/null 2>&1 &
VNCEOF

arch_root "chmod +x /home/forge/.vnc/xstartup && chown -R forge:users /home/forge/.vnc"

# — Resolución —
VNC_RES=$(config_get VNC_RESOLUTION)
if [ -z "$VNC_RES" ]; then
    echo ""
    echo -e "${MINT}Resolución VNC:${NC}"
    echo -e "  ${LIME}1)${NC} 1280x720  ${LIME}2)${NC} 1920x1080  ${LIME}3)${NC} 1024x768"
    rc=$(ask_number "Elige" 1 3)
    case "$rc" in
        2) VNC_RES="1920x1080" ;;
        3) VNC_RES="1024x768" ;;
        *) VNC_RES="1280x720" ;;
    esac
    config_set VNC_RESOLUTION "$VNC_RES"
fi

echo ""
echo -e "  ${LIME}✓ TigerVNC configurado en Arch.${NC}"
echo -e "  ${GRAY}Resolución: ${VNC_RES} | Puerto: 5901${NC}"