#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Generador de Scripts de Control
#  Crea start-forge.sh, stop-forge.sh, switch-display.sh
#  Se ejecuta automáticamente al completar la base
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"

header "Generando Scripts de Control"

FORGE_PATH=$(config_get FORGE_PATH)
DISPLAY_MODE=$(config_get DISPLAY_MODE)
VNC_RES=$(config_get VNC_RESOLUTION)
VNC_RES="${VNC_RES:-1280x720}"
TERMUX_BIN="/data/data/com.termux/files/usr/bin"

# ═══════════════════════════════════════
#  start-forge.sh
# ═══════════════════════════════════════

cat > "$HOME/start-forge.sh" << STARTEOF
#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Iniciar Entorno
#  Auto-detecta el camino y el modo de display
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"

FORGE_PATH="\$(config_get FORGE_PATH)"
DISPLAY_MODE="\$(config_get DISPLAY_MODE)"
VNC_RES="\$(config_get VNC_RESOLUTION)"
VNC_RES="\${VNC_RES:-1280x720}"
TERMUX_BIN="/data/data/com.termux/files/usr/bin"

echo ""
echo -e "\${LIME}🚀 TermuxForge — Iniciando...\${NC}"

# — Lock de pantalla —
termux-wake-lock

# — Preguntar modo si es "both" —
USE_MODE="\$DISPLAY_MODE"
if [ "\$DISPLAY_MODE" = "both" ]; then
    echo ""
    echo -e "\${MINT}¿Iniciar en qué modo?\${NC}"
    echo -e "  \${LIME}1)\${NC} 📱 X11 Local"
    echo -e "  \${LIME}2)\${NC} 📺 VNC Remoto"
    echo ""
    read -p "  Elige [1-2]: " mode_choice
    case "\$mode_choice" in
        2) USE_MODE="vnc" ;;
        *) USE_MODE="x11" ;;
    esac
fi

# ═════════════════════════════════════
#  LIMPIEZA PREVIA
# ═════════════════════════════════════
echo -e "\${MINT}Limpiando sesiones anteriores...\${NC}"

if [ "\$FORGE_PATH" = "container" ]; then
    # Detener sesiones dentro de Arch
    proot-distro login archlinuxarm -- bash -c "
        pkill -TERM -f xfce4-session 2>/dev/null
        pkill -TERM -f xfwm4 2>/dev/null
        pkill -TERM -f xfdesktop 2>/dev/null
        pkill -TERM -f xfce4-panel 2>/dev/null
        pkill -TERM -f Thunar 2>/dev/null
        sleep 1
        pkill -9 -f xfce4 2>/dev/null
        vncserver -kill :1 >/dev/null 2>&1
    " 2>/dev/null
fi

# Detener servicios de Termux
pkill -TERM -f xfce4-session 2>/dev/null
pkill -TERM -f xfwm4 2>/dev/null
pkill -TERM -f xfdesktop 2>/dev/null
pkill -TERM -f xfce4-panel 2>/dev/null
pkill -TERM -f termux-x11 2>/dev/null
pkill -TERM -f virgl_test_server 2>/dev/null
vncserver -kill :1 >/dev/null 2>&1
sleep 1

# ═══════════════════════════════════════
#  AUDIO (siempre en Termux nativo)
# ═════════════════════════════════════
echo -e "\${MINT}Iniciando PulseAudio...\${NC}"
pulseaudio --kill 2>/dev/null
sleep 0.5
pulseaudio --start \\
    --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \\
    --exit-idle-time=-1 2>/dev/null
export PULSE_SERVER=127.0.0.1

# ═════════════════════════════════════
#  OLLAMA (si está instalado)
# ═════════════════════════════════════
if command -v ollama >/dev/null 2>&1; then
    echo -e "\${MINT}Iniciando Ollama...\${NC}"
    pkill -f "ollama serve" 2>/dev/null
    sleep 0.5
    ollama serve > /dev/null 2>&1 &
fi

# ═════════════════════════════════════
#  INICIAR SEGÚN MODO
# ═════════════════════════════════════

if [ "\$USE_MODE" = "vnc" ]; then
    # ─── MODO VNC ───
    echo -e "\${MINT}Iniciando servidor VNC (\${VNC_RES})...\${NC}"

    if [ "\$FORGE_PATH" = "container" ]; then
        # VNC dentro de Arch
        proot-distro login archlinuxarm -- bash -c "
            export PULSE_SERVER=127.0.0.1
            export GALLIUM_DRIVER=llvmpipe
            export MESA_LOADER_DRIVER_OVERRIDE=swrast
            export LIBGL_ALWAYS_SOFTWARE=1
            export MESA_GL_VERSION_OVERRIDE=3.1
            vncserver :1 -geometry \${VNC_RES} -depth 24 -localhost no
        " 2>&1 | grep -v "Password"
    else
        # VNC nativo en Termux
        export GALLIUM_DRIVER=llvmpipe
        export MESA_LOADER_DRIVER_OVERRIDE=swrast
        export LIBGL_ALWAYS_SOFTWARE=1
        export MESA_GL_VERSION_OVERRIDE=3.1
        vncserver :1 -geometry "\$VNC_RES" -depth 24 -localhost no 2>&1 | grep -v "Password"
    fi

    echo ""
    echo -e "\${LIME}═══════════════════════════════════════\${NC}"
    echo -e "\${LIME}  📺 TermuxForge activo — Modo VNC\${NC}"
    echo -e "\${LIME}═══════════════════════════════════════\${NC}"
    echo -e "\${WHITE}  Conecta desde tu TV/PC:\${NC}"
    echo -e "\${WHITE}  IP de tu teléfono + puerto 5901\${NC}"
    echo -e "\${GRAY}  (Primera vez: te pedirá crear una clave)\${NC}"
    echo -e "\${LIME}═══════════════════════════════════════\${NC}"

else
    # ─── MODO X11 ───
    echo -e "\${MINT}Iniciando Termux:X11...\${NC}"

    if ! command -v termux-x11 >/dev/null 2>&1; then
        echo -e "\${RED}✗ Termux:X11 no está instalado.\${NC}"
        echo -e "\${GRAY}Instálalo desde el menú principal.\${NC}"
        exit 1
    fi

    # GPU para X11
    export GALLIUM_DRIVER=virpipe
    export LIBGL_ALWAYS_INDIRECT=1
    export MESA_GL_VERSION_OVERRIDE=4.3COMPAT
    export MESA_GLES_VERSION_OVERRIDE=3.2

    # Iniciar VirGL si está disponible
    if command -v virgl_test_server_android >/dev/null 2>&1; then
        echo -e "\${MINT}Iniciando VirGL...\${NC}"
        pkill -f virgl_test_server 2>/dev/null
        sleep 0.5
        virgl_test_server_android &
        sleep 2
    elif command -v virgl_test_server >/dev/null 2>&1; then
        echo -e "\${MINT}Iniciando VirGL (surfaceless)...\${NC}"
        pkill -f virgl_test_server 2>/dev/null
        sleep 0.5
        MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.3COMPAT \\
            GALLIUM_DRIVER=zink MESA_LOADER_DRIVER_OVERRIDE=zink \\
            virgl_test_server --use-egl-surfaceless --use-gles &
        sleep 2
    fi

    # Iniciar X11 server
    termux-x11 :0 &
    sleep 2

    # Auto-abrir la app de X11
    am start -n com.termux.x11/.MainActivity 2>/dev/null || \\
        echo -e "\${YELLOW}⚠ Abre la app Termux:X11 manualmente\${NC}"

    export DISPLAY=:0

    # D-Bus
    if [ -z "\$DBUS_SESSION_BUS_ADDRESS" ]; then
        eval "\$(dbus-launch --sh-syntax)" 2>/dev/null
    fi

    # Iniciar XFCE4
    echo -e "\${MINT}Iniciando XFCE4...\${NC}"

    if [ "\$FORGE_PATH" = "container" ]; then
        # XFCE4 dentro de Arch con DISPLAY pasado
        proot-distro login archlinuxarm -- bash -c "
            export DISPLAY=:0
            export PULSE_SERVER=127.0.0.1
            export GALLIUM_DRIVER=virpipe
            export LIBGL_ALWAYS_INDIRECT=1
            export MESA_GL_VERSION_OVERRIDE=4.3COMPAT
            export XDG_RUNTIME_DIR=/tmp
            eval \\\$(dbus-launch --sh-syntax) 2>/dev/null
            startxfce4 &
        " 2>/dev/null &
    else
        startxfce4 &
    fi

    # Desactivar compositor
    sleep 3
    if command -v xfconf-query >/dev/null 2>&1; then
        xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null
    fi

    echo ""
    echo -e "\${LIME}═══════════════════════════════════════\${NC}"
    echo -e "\${LIME}  📱 TermuxForge activo — Modo X11\${NC}"
    echo -e "\${LIME}═══════════════════════════════════════\${NC}"
    echo -e "\${WHITE}  Cambia a la app Termux:X11 para ver\${NC}"
    echo -e "\${WHITE}  el escritorio en tu teléfono.\${NC}"
    echo -e "\${LIME}═══════════════════════════════════════\${NC}"
fi

echo ""
echo -e "\${GRAY}Para detener: bash ~/stop-forge.sh\${NC}"
echo ""

# Mantener vivo
wait
STARTEOF

chmod +x "$HOME/start-forge.sh"

# ═══════════════════════════════════════
#  stop-forge.sh
# ═══════════════════════════════════════

cat > "$HOME/stop-forge.sh" << STOPEOF
#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Detener Entorno
#  Apagado graceful: TERM → espera → KILL
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"

FORGE_PATH="\$(config_get FORGE_PATH)"

echo ""
echo -e "\${MINT}🔴 Deteniendo TermuxForge...\${NC}"

# — Graceful shutdown XFCE4 —
echo -e "\${GRAY}Cerrando XFCE4...\${NC}"

if [ "\$FORGE_PATH" = "container" ]; then
    proot-distro login archlinuxarm -- bash -c "
        xfce4-session-logout --logout 2>/dev/null
        sleep 2
        pkill -TERM -f xfce4-session 2>/dev/null
        pkill -TERM -f xfwm4 2>/dev/null
        pkill -TERM -f xfdesktop 2>/dev/null
        pkill -TERM -f xfce4-panel 2>/dev/null
        pkill -TERM -f Thunar 2>/dev/null
        pkill -TERM -f xfconfd 2>/dev/null
        sleep 1
        pkill -9 -f xfce4 2>/dev/null
        vncserver -kill :1 >/dev/null 2>&1
    " 2>/dev/null
fi

# — Nativo —
xfce4-session-logout --logout 2>/dev/null
sleep 2

pkill -TERM -f xfce4-session 2>/dev/null
pkill -TERM -f xfwm4 2>/dev/null
pkill -TERM -f xfdesktop 2>/dev/null
pkill -TERM -f xfce4-panel 2>/dev/null
pkill -TERM -f Thunar 2>/dev/null
pkill -TERM -f xfconfd 2>/dev/null
sleep 1

pkill -9 -f xfce4 2>/dev/null
pkill -9 -f xfwm4 2>/dev/null

# — X11 —
echo -e "\${GRAY}Deteniendo X11...\${NC}"
pkill -TERM -f termux-x11 2>/dev/null
sleep 1
pkill -9 -f termux-x11 2>/dev/null
pkill -9 -f Xwayland 2>/dev/null

# — VNC —
echo -e "\${GRAY}Deteniendo VNC...\${NC}"
vncserver -kill :1 >/dev/null 2>&1

# — VirGL —
echo -e "\${GRAY}Deteniendo VirGL...\${NC}"
pkill -TERM -f virgl_test_server 2>/dev/null
sleep 1
pkill -9 -f virgl_test_server 2>/dev/null

# — Ollama —
echo -e "\${GRAY}Deteniendo Ollama...\${NC}"
pkill -TERM -f "ollama" 2>/dev/null
sleep 1
pkill -9 -f "ollama" 2>/dev/null

# — Audio —
echo -e "\${GRAY}Deteniendo PulseAudio...\${NC}"
pulseaudio --kill 2>/dev/null

# — Limpiar sockets —
rm -f /tmp/.X0-lock 2>/dev/null
rm -f /tmp/.X11-unix/X0 2>/dev/null
rm -f /tmp/.X1-lock 2>/dev/null
rm -f /tmp/.X11-unix/X1 2>/dev/null

# — Wake lock —
termux-wake-unlock

echo ""
echo -e "\${LIME}✅ TermuxForge detenido completamente.\${NC}"
echo ""
STOPEOF

chmod +x "$HOME/stop-forge.sh"

# ═══════════════════════════════════════
#  switch-display.sh
# ═══════════════════════════════════════

cat > "$HOME/switch-display.sh" << SWITCHEOF
#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Cambiar Modo de Display
#  Detiene todo y reconfigura sin reinstalar
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"

CURRENT="\$(config_get DISPLAY_MODE)"

echo ""
echo -e "\${MINT}Modo actual: \${WHITE}\${CURRENT}\${NC}"
echo ""
echo -e "  \${LIME}1)\${NC} X11 Local (teléfono)"
echo -e "  \${LIME}2)\${NC} VNC Remoto (TV/PC)"
echo -e "  \${LIME}3)\${NC} Ambos (pregunta al arrancar)"
echo ""

choice=\$(ask_number "Nuevo modo" 1 3)

case "\$choice" in
    1) config_set DISPLAY_MODE "x11"  ;;
    2) config_set DISPLAY_MODE "vnc"  ;;
    3) config_set DISPLAY_MODE "both" ;;
esac

echo ""
echo -e "\${LIME}✓ Modo cambiado a: \$(config_get DISPLAY_MODE)\${NC}"
echo -e "\${GRAY}Ejecuta ~/start-forge.sh para aplicar.\${NC}"
echo ""
SWITCHEOF

chmod +x "$HOME/switch-display.sh"

# ═══════════════════════════════════════
#  Atajos .desktop en ~/Desktop
# ═══════════════════════════════════════

echo -e "${MINT}Creando atajos en el escritorio...${NC}"

mkdir -p "$HOME/Desktop"

# — Atajos comunes —
create_desktop() {
    local file="$1" name="$2" exec="$3" icon="$4" cat="$5"
    cat > "$HOME/Desktop/${file}.desktop" << DEEOF
[Desktop Entry]
Name=${name}
Exec=${exec}
Icon=${icon}
Terminal=false
Type=Application
Categories=${cat};
DEEOF
    chmod +x "$HOME/Desktop/${file}.desktop"
}

create_desktop "Start_Forge" "Iniciar TermuxForge" "bash $HOME/start-forge.sh" "start-here" "System"
create_desktop "Stop_Forge" "Detener TermuxForge" "bash $HOME/stop-forge.sh" "process-stop" "System"
create_desktop "Switch_Display" "Cambiar Display" "bash $HOME/switch-display.sh" "display" "System"

# — Atajos de apps según lo instalado —
if [ -f "$TERMUX_BIN/code-oss" ]; then
    create_desktop "VS_Code" "VS Code" "$TERMUX_BIN/code-oss --no-sandbox --unity-launch %F" "code-oss" "Development"
fi

if [ -f "$TERMUX_BIN/godot" ]; then
    create_desktop "Godot" "Godot Engine" "$TERMUX_BIN/godot %f" "godot" "Development"
fi

if command -v firefox >/dev/null 2>&1; then
    create_desktop "Firefox" "Firefox" "firefox %u" "firefox" "Network"
fi

if command -v gimp >/dev/null 2>&1; then
    create_desktop "GIMP" "GIMP" "gimp" "gimp" "Graphics"
fi

if command -v audacity >/dev/null 2>&1; then
    create_desktop "Audacity" "Audacity" "audacity" "audacity" "AudioVideo"
fi

if command -v mpv >/dev/null 2>&1; then
    create_desktop "MPV" "MPV Player" "mpv %F" "mpv" "AudioVideo"
fi

echo ""
echo -e "  ${LIME}✓ Scripts de control generados:${NC}"
echo -e "     ~/start-forge.sh   — Iniciar entorno"
echo -e "     ~/stop-forge.sh    — Detener entorno"
echo -e "     ~/switch-display.sh — Cambiar X11/VNC"
echo -e "     ~/Desktop/*.desktop — Atajos en escritorio"