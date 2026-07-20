#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════════════════════
#  ██╗  ██╗ █████╗  ██████╗██╗  ██╗███████╗██████╗
#  ██║  ██║██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗
#  ███████║███████║██║     █████╔╝ █████╗  ██║  ██║
#  ██╔══██║██╔══██║██║     ██╔═██╗ ██╔══╝  ██║  ██║
#  ██║  ██║██║  ██║╚██████╗██║  ██╗███████╗██████╔╝
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝
#
#  Instalador Modular para Entorno Linux en Termux
#  Compatible con Termux Nativo y Arch Linux (proot-distro)
#
#  Uso: bash setup.sh
# ═══════════════════════════════════════════════════════════════

set -u

# — Cargar librerías —
SCRIPT_DIR="$HOME/scripts"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/detect.sh"
config_init

# — Banner —
show_banner() {
    clear
    echo -e "${LIME}"
    cat << 'ART'
     ██████╗ ██████╗  █████╗ ███╗   ██╗██╗  ██╗███████╗
    ██╔════╝ ██╔══██╗██╔══██╗████╗  ██║██║ ██╔╝██╔════╝
    ██║  ███╗██████╔╝███████║██╔██╗ ██║█████╔╝ █████╗
    ██║   ██║██╔══██╗██╔══██║██║╚██╗██║██╔═██╗ ██╔══╝
    ╚██████╔╝██║  ██║██║  ██║██║ ╚████║██║  ██╗███████╗
     ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝
ART
    echo -e "${NC}"
    echo -e "${GRAY}  Instalador Modular — v1.0${NC}"
    echo ""
}

# — Preguntar camino por primera vez —
ask_path() {
    echo -e "${MINT}¿Qué entorno quieres instalar?${NC}"
    echo ""
    echo -e "  ${LIME}1)${NC} ${WHITE}Termux Nativo${NC}"
    echo -e "     ${GRAY}Todo corre directamente en Termux. Sin contenedores.${NC}"
    echo -e "     ${GRAY}Más rápido, menos capas, más simple.${NC}"
    echo ""
    echo -e "  ${LIME}2)${NC} ${WHITE}Termux + Arch Linux${NC}"
    echo -e "     ${GRAY}Termux como anfitrión ligero + Arch como escritorio.${NC}"
    echo -e "     ${GRAY}Más paquetes disponibles. VS Code y Godot corren${NC}"
    echo -e "     ${GRAY}en Termux pero se usan desde dentro de Arch.${NC}"
    echo ""

    local choice
    choice=$(ask_number "Elige camino" 1 2)

    if [ "$choice" = "1" ]; then
        config_set FORGE_PATH "native"
    else
        config_set FORGE_PATH "container"
    fi
}

# — Preguntar modo de display —
ask_display() {
    local current
    current=$(config_get DISPLAY_MODE)
    if [ "$current" = "x11" ] || [ "$current" = "vnc" ] || [ "$current" = "both" ]; then
        echo -e "  ${GRAY}Display ya configurado: ${current}${NC}"
        if ! ask "¿Cambiar modo de display?" n; then
            return 0
        fi
    fi

    echo ""
    echo -e "${MINT}¿Cómo quieres visualizar el escritorio?${NC}"
    echo ""
    echo -e "  ${LIME}1)${NC} ${WHITE}X11 Local${NC}"
    echo -e "     ${GRAY}Sin latencia, en la pantalla de tu teléfono.${NC}"
    echo -e "     ${GRAY}Requiere la app Termux:X11 instalada.${NC}"
    echo ""
    echo -e "  ${LIME}2)${NC} ${WHITE}VNC Remoto${NC}"
    echo -e "     ${GRAY}Por red local (WiFi), conecta desde TV o PC.${NC}"
    echo -e "     ${GRAY}Usa cualquier VNC Viewer en el puerto 5901.${NC}"
    echo ""
    echo -e "  ${LIME}3)${NC} ${WHITE}Ambos${NC}"
    echo -e "     ${GRAY}Instala los dos. Al arrancar eliges cuál usar.${NC}"
    echo ""

    local choice
    choice=$(ask_number "Elige display" 1 3)

    case "$choice" in
        1) config_set DISPLAY_MODE "x11"  ;;
        2) config_set DISPLAY_MODE "vnc"  ;;
        3) config_set DISPLAY_MODE "both" ;;
    esac
    echo -e "  ${LIME}✓ Display configurado: $(config_get DISPLAY_MODE)${NC}"
}

# — Menú: Camino Nativo —
menu_native() {
    local tier
    tier=$(config_get RAM_TIER)

    echo ""
    header "Termux Nativo — Módulos"
    echo ""

    badge "done"  "Base Termux + repositorios"            || badge "$(recommend req)"    "Base Termux + repositorios"
    is_done "native_base" && true || badge "$(recommend req)"    "Base Termux + repositorios"
    is_done "native_xfce"  && badge done "Escritorio XFCE4"     || badge "$(recommend req)"    "Escritorio XFCE4"
    is_done "native_display" && badge done "Elegir display (X11/VNC)" || badge "$(recommend req)" "Elegir display (X11/VNC)"
    echo ""
    is_done "native_nodepy" && badge done "Node.js + Python"    || badge "$(recommend rec)"    "Node.js + Python"
    is_done "native_dev"    && badge done "VS Code + Godot"      || badge "$(recommend rec)"    "VS Code + Godot (tur-repo)"
    echo ""
    is_done "native_art"    && badge done "GIMP + Audacity"     || badge "$(recommend heavy)"  "GIMP + Audacity"
    echo ""
    is_done "native_theme"  && badge done "Temas, iconos, fuentes" || badge "$(recommend opt)" "Temas, iconos, fuentes, panel"
    is_done "native_tweaks" && badge done "Tweaks de terminal"  || badge "$(recommend opt)"    "Tweaks de terminal (Zsh, OhMyZsh)"
    is_done "native_ai"     && badge done "IA local (Ollama)"   || badge "$(recommend heavy)"  "IA local (Ollama + modelo)"
    echo ""
    separator
    echo -e "  ${CYAN}⚙  Control${NC}"
    echo -e "  ${WHITE}[$((10+1))]${NC}  Iniciar entorno"
    echo -e "  ${WHITE}[$((10+2))]${NC}  Detener entorno"
    echo -e "  ${WHITE}[$((10+3))]${NC}  Cambiar display (X11 ↔ VNC)"
    echo ""
    echo -e "  ${GRAY}[0]  Salir${NC}"
    separator
}

# — Menú: Camino Contenedor —
menu_container() {
    local tier
    tier=$(config_get RAM_TIER)

    echo ""
    header "Termux + Arch Linux — Módulos"
    echo ""

    echo -e "  ${CYAN}📦 BASE${NC}"
    is_done "container_base"    && badge done "Base Termux (anfitrión)"        || badge "$(recommend req)"    "Base Termux (anfitrión)"
    is_done "container_proot"   && badge done "Instalar Arch Linux (proot)"    || badge "$(recommend req)"    "Instalar Arch Linux (proot)"
    is_done "container_xfce"    && badge done "Escritorio XFCE4 en Arch"      || badge "$(recommend req)"    "Escritorio XFCE4 en Arch"
    is_done "container_display" && badge done "Elegir display (X11/VNC)"       || badge "$(recommend req)"    "Elegir display (X11/VNC)"
    echo ""
    echo -e "  ${CYAN}🛠 DESARROLLO${NC}"
    is_done "container_nodepy"  && badge done "Node.js + Python (Termux)"     || badge "$(recommend rec)"    "Node.js + Python (Termux)"
    is_done "container_dev"     && badge done "VS Code + Godot (Termux)"      || badge "$(recommend rec)"    "VS Code + Godot (nativo Termux, usados desde Arch)"
    is_done "container_webdev"  && badge done "Desarrollo Web (Arch)"         || badge "$(recommend rec)"    "Desarrollo Web en Arch (Firefox, Node, Python)"
    is_done "container_gamedev" && badge done "Desarrollo de Juegos (Arch)"   || badge "$(recommend rec)"    "Desarrollo de Juegos en Arch (Ren'Py, LÖVE, Raylib)"
    echo ""
    echo -e "  ${CYAN}🎨 EXTRA${NC}"
    is_done "container_art"     && badge done "Suite gráfica (Arch)"           || badge "$(recommend heavy)"  "Suite gráfica (GIMP, Audacity en Arch)"
    is_done "container_media"   && badge done "Multimedia (Arch)"             || badge "$(recommend heavy)"  "Multimedia (MPV, FFmpeg en Arch)"
    is_done "container_office"  && badge done "Ofimática (Arch)"              || badge "$(recommend very_heavy)" "Ofimática (LibreOffice, Thunderbird)"
    is_done "container_cyber"   && badge done "Ciberseguridad (Arch)"         || badge "$(recommend very_heavy)" "Ciberseguridad (Nmap, Wireshark, Metasploit)"
    echo ""
    echo -e "  ${CYAN}✨ PERSONALIZACIÓN${NC}"
    is_done "container_theme"   && badge done "Temas, iconos, fuentes"         || badge "$(recommend opt)"    "Temas, iconos, fuentes, panel"
    is_done "container_tweaks"  && badge done "Tweaks de terminal"            || badge "$(recommend opt)"    "Tweaks de terminal (Zsh, OhMyZsh)"
    is_done "container_ai"      && badge done "IA local (Ollama)"             || badge "$(recommend heavy)"  "IA local (Ollama + modelo)"
    echo ""
    separator
    echo -e "  ${CYAN}⚙  Control${NC}"
    echo -e "  ${WHITE}[$((15+1))]${NC}  Iniciar entorno"
    echo -e "  ${WHITE}[$((15+2))]${NC}  Detener entorno"
    echo -e "  ${WHITE}[$((15+3))]${NC}  Cambiar display (X11 ↔ VNC)"
    echo ""
    echo -e "  ${GRAY}[0]  Salir${NC}"
    separator
}

# — Ejecutar módulo —
run_module() {
    local marker="$1"
    local script="$2"
    local desc="$3"

    if is_done "$marker"; then
        echo ""
        if ask "✅ '${desc}' ya está instalado. ¿Reinstalar?" n; then
            rm -f "$FORGE_DIR/done/$marker"
        else
            return 0
        fi
    fi

    echo ""
    if [ -f "$script" ]; then
        bash "$script"
        if [ $? -eq 0 ]; then
            mark_done "$marker"
            echo -e "  ${LIME}✓ ${desc} completado.${NC}"
        else
            echo -e "  ${RED}✗ ${desc} falló. Revisa los errores arriba.${NC}"
        fi
    else
        echo -e "  ${RED}✗ Script no encontrado: ${script}${NC}"
    fi
    echo ""
    sleep 1
}

# — Loop principal: Nativo —
loop_native() {
    while true; do
        show_banner
        show_hardware_info
        menu_native

        local max=13
        local choice
        choice=$(ask_number "Selecciona opción" 0 "$max")

        case "$choice" in
            1) run_module "native_base"    "$SCRIPT_DIR/native/install_base.sh"    "Base Termux" ;;
            2) run_module "native_xfce"     "$SCRIPT_DIR/native/setup_xfce.sh"     "Escritorio XFCE4" ;;
            3) ask_display; mark_done "native_display" ;;
            4) run_module "native_nodepy"   "$SCRIPT_DIR/native/setup_nodepy.sh"   "Node.js + Python" ;;
            5) run_module "native_dev"      "$SCRIPT_DIR/native/setup_dev.sh"      "VS Code + Godot" ;;
            6) run_module "native_art"      "$SCRIPT_DIR/native/setup_art.sh"      "GIMP + Audacity" ;;
            7) run_module "native_theme"    "$SCRIPT_DIR/native/setup_theme.sh"    "Tematización" ;;
            8) run_module "native_tweaks"   "$SCRIPT_DIR/native/termux_tweaks.sh"  "Tweaks de terminal" ;;
            9) run_module "native_ai"       "$SCRIPT_DIR/native/setup_ai.sh"       "IA local" ;;
            11) bash "$HOME/start-forge.sh" ;;
            12) bash "$HOME/stop-forge.sh" ;;
            13) bash "$HOME/switch-display.sh" ;;
            0) echo -e "\n  ${LIME}Hasta luego.${NC}\n"; exit 0 ;;
        esac
    done
}

# — Loop principal: Contenedor —
loop_container() {
    while true; do
        show_banner
        show_hardware_info
        menu_container

        local max=18
        local choice
        choice=$(ask_number "Selecciona opción" 0 "$max")

        case "$choice" in
            1)  run_module "container_base"    "$SCRIPT_DIR/container/install_base.sh"    "Base Termux" ;;
            2)  run_module "container_proot"   "$SCRIPT_DIR/container/install_proot.sh"   "Arch Linux" ;;
            3)  run_module "container_xfce"    "$SCRIPT_DIR/container/setup_xfce.sh"     "XFCE4 en Arch" ;;
            4)  ask_display; mark_done "container_display" ;;
            5)  run_module "container_nodepy"  "$SCRIPT_DIR/container/setup_nodepy.sh"   "Node.js + Python (Termux)" ;;
            6)  run_module "container_dev"     "$SCRIPT_DIR/container/setup_dev.sh"      "VS Code + Godot (Termux)" ;;
            7)  run_module "container_webdev"  "$SCRIPT_DIR/container/setup_webdev.sh"   "Desarrollo Web (Arch)" ;;
            8)  run_module "container_gamedev" "$SCRIPT_DIR/container/setup_gamedev.sh"  "Desarrollo de Juegos (Arch)" ;;
            9)  run_module "container_art"     "$SCRIPT_DIR/container/setup_art.sh"      "Suite gráfica (Arch)" ;;
            10) run_module "container_media"   "$SCRIPT_DIR/container/setup_media.sh"    "Multimedia (Arch)" ;;
            11) run_module "container_office"  "$SCRIPT_DIR/container/setup_office.sh"   "Ofimática (Arch)" ;;
            12) run_module "container_cyber"   "$SCRIPT_DIR/container/setup_cybersec.sh" "Ciberseguridad (Arch)" ;;
            13) run_module "container_theme"   "$SCRIPT_DIR/container/setup_theme.sh"    "Tematización" ;;
            14) run_module "container_tweaks"  "$SCRIPT_DIR/container/termux_tweaks.sh"  "Tweaks de terminal" ;;
            15) run_module "container_ai"      "$SCRIPT_DIR/container/setup_ai.sh"       "IA local" ;;
            16) bash "$HOME/start-forge.sh" ;;
            17) bash "$HOME/stop-forge.sh" ;;
            18) bash "$HOME/switch-display.sh" ;;
            0)  echo -e "\n  ${LIME}Hasta luego.${NC}\n"; exit 0 ;;
        esac
    done
}

# ═══════════════════════════════════════════════
#  PUNTO DE ENTRADA
# ═══════════════════════════════════════════════
main() {
    # Verificar que las librerías se cargaron
    if [ -z "${FORGE_DIR:-}" ]; then
        echo "Error: No se pudieron cargar las librerías."
        echo "Asegúrate de ejecutar: bash $0"
        exit 1
    fi

    show_banner

    # ¿Primera vez?
    local saved_path
    saved_path=$(config_get FORGE_PATH)

    if [ -z "$saved_path" ]; then
        # — Primera ejecución —
        echo -e "${MINT}Bienvenido a TermuxForge.${NC}"
        echo -e "${GRAY}Primero necesito conocer tu hardware.${NC}"
        echo ""

        if ! check_requirements; then
            echo ""
            echo -e "${RED}Corrige los problemas arriba y vuelve a ejecutar el script.${NC}"
            exit 1
        fi

        show_hardware_info
        echo ""
        ask_path
        echo ""
    else
        # — Ejecución posterior —
        show_hardware_info
    fi

    # Crear estructura de directorios
    mkdir -p "$SCRIPT_DIR"/{lib,native,container,utils}
    mkdir -p "$HOME"/{Desktop,Projects,Automation,Apps_Linux,Godot/Templates,Godot/Workspace}

    # Entrar al loop del camino correspondiente
    case "$(config_get FORGE_PATH)" in
        native)    loop_native    ;;
        container) loop_container ;;
        *)
            echo -e "${RED}Error: Camino no reconocido. Borra ${FORGE_DIR}/config e intenta de nuevo.${NC}"
            exit 1
            ;;
    esac
}

main