#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — TigerVNC (Nativo Termux)
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"

header "TigerVNC — Servidor de Display Remoto"

DISPLAY_MODE=$(config_get DISPLAY_MODE)

# Si el modo es solo X11, preguntar si de todos modos quiere VNC
if [ "$DISPLAY_MODE" = "x11" ]; then
    echo -e "  ${YELLOW}Tu modo de display actual es X11 exclusivo.${NC}"
    if ! ask "¿Instalar VNC de todos modos?" n; then
        echo -e "  ${GRAY}Omitido.${NC}"
        exit 0
    fi
fi

TO_INSTALL=""
TO_SKIP=""

# TigerVNC
echo -e "${MINT}═══ TigerVNC ═══${NC}"
if command -v vncserver >/dev/null 2>&1; then
    echo -e "  ${GRAY}○ TigerVNC ya instalado${NC}"
else
    if ask "¿Instalar TigerVNC?" y; then
        TO_INSTALL="${TO_INSTALL}TigerVNC "
    else
        TO_SKIP="${TO_SKIP}TigerVNC "
    fi
fi

# xorg-xrandr (útil para cambiar resolución en VNC)
echo ""
echo -e "${MINT}═══ xorg-xrandr ═══${NC}"
if command -v xrandr >/dev/null 2>&1; then
    echo -e "  ${GRAY}○ xrandr ya instalado${NC}"
else
    if ask "¿Instalar xorg-xrandr (cambio de resolución)?" y; then
        TO_INSTALL="${TO_INSTALL}xrandr "
    else
        TO_SKIP="${TO_SKIP}xrandr "
    fi
fi

summary "TigerVNC" "$TO_INSTALL" "$TO_SKIP"

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

if echo "$TO_INSTALL" | grep -q "TigerVNC"; then
    install_pkg "tigervnc" "TigerVNC"
    command -v vncserver >/dev/null 2>&1 || ERRORS=$((ERRORS + 1))
fi

if echo "$TO_INSTALL" | grep -q "xrandr"; then
    install_pkg "xorg-xrandr" "xorg-xrandr"
    command -v xrandr >/dev/null 2>&1 || ERRORS=$((ERRORS + 1))
fi

# — Generar xstartup —
mkdir -p "$HOME/.vnc"
cat > "$HOME/.vnc/xstartup" << 'VNCEOF'
#!/data/data/com.termux/files/usr/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export PULSE_SERVER=127.0.0.1

# GPU software rendering para VNC (estable en todos los dispositivos)
export GALLIUM_DRIVER=llvmpipe
export MESA_LOADER_DRIVER_OVERRIDE=swrast
export LIBGL_ALWAYS_SOFTWARE=1
export MESA_GL_VERSION_OVERRIDE=3.1

startxfce4 >/dev/null 2>&1 &
VNCEOF
chmod +x "$HOME/.vnc/xstartup"
echo -e "  ${LIME}✓${NC} xstartup generado en ~/.vnc/"

# — Preguntar resolución —
echo ""
echo -e "${MINT}Resolución del servidor VNC:${NC}"
echo -e "  ${LIME}1)${NC} 1280x720  ${GRAY}(recomendado para TV HD)${NC}"
echo -e "  ${LIME}2)${NC} 1920x1080 ${GRAY}(Full HD, más pesado)${NC}"
echo -e "  ${LIME}3)${NC} 1024x768  ${GRAY}(más ligero)${NC}"
echo -e "  ${LIME}4)${NC} 800x600   ${GRAY}(muy ligero)${NC}"

res_choice=$(ask_number "Elige resolución" 1 4)
case "$res_choice" in
    1) VNC_RES="1280x720"  ;;
    2) VNC_RES="1920x1080" ;;
    3) VNC_RES="1024x768"  ;;
    4) VNC_RES="800x600"   ;;
esac
config_set VNC_RESOLUTION "$VNC_RES"

# — Verificación —
echo ""
if [ "$ERRORS" -eq 0 ]; then
    echo -e "  ${LIME}✓ TigerVNC configurado.${NC}"
    echo -e "  ${GRAY}Resolución: ${VNC_RES}${NC}"
    echo -e "  ${GRAY}Puerto: 5901 (display :1)${NC}"
    echo -e "  ${GRAY}Para iniciar: bash ~/start-forge.sh${NC}"
    exit 0
else
    echo -e "  ${RED}✗ La instalación falló.${NC}"
    exit 1
fi