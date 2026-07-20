#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — UI Library
#  Colores, spinners, barras, helpers de prompt
# ═══════════════════════════════════════════════

# — Colores Verdant Cyberpunk —
LIME='\033[1;32m'
FOREST='\033[0;32m'
MINT='\033[1;36m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# — Directorio de configuración —
FORGE_DIR="$HOME/.termuxforge"
TERMUX_PREFIX="/data/data/com.termux/files/usr"

# — Config helpers —
config_init() {
    mkdir -p "$FORGE_DIR/done"
    [ -f "$FORGE_DIR/config" ] || touch "$FORGE_DIR/config"
}

config_set() {
    config_init
    # Elimina la clave si ya existe y la reescribe
    if grep -q "^$1=" "$FORGE_DIR/config" 2>/dev/null; then
        sed -i "s/^$1=.*/$1=$2/" "$FORGE_DIR/config"
    else
        echo "$1=$2" >> "$FORGE_DIR/config"
    fi
}

config_get() {
    grep "^$1=" "$FORGE_DIR/config" 2>/dev/null | cut -d= -f2-
}

mark_done() {
    mkdir -p "$FORGE_DIR/done"
    touch "$FORGE_DIR/done/$1"
}

is_done() {
    [ -f "$FORGE_DIR/done/$1" ]
}

# — Spinner —
spinner() {
    local pid=$1
    local msg="$2"
    local spin='☰/{}/|/\'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i + 1) % 4 ))
        printf "\r  ${YELLOW}⚡${NC} ${msg} ${LIME}${spin:$i:1}${NC}  "
        sleep 0.12
    done
    wait "$pid" 2>/dev/null
    local ec=$?
    if [ "$ec" -eq 0 ]; then
        printf "\r  ${LIME}✓${NC} ${msg}                    \n"
    else
        printf "\r  ${RED}✗${NC} ${msg} ${RED}(falló)${NC}     \n"
    fi
    return "$ec"
}

# — Instalador con spinner —
install_pkg() {
    local pkg="$1"
    local name="${2:-$pkg}"
    (yes | pkg install "$pkg" -y > /dev/null 2>&1) &
    spinner $! "Instalando ${name}..."
}

# — Preguntas interactivas —
# ask "¿Texto?" [S/n]  → por defecto Sí
# ask "¿Texto?" [s/N]  → por defecto No
ask() {
    local prompt="$1"
    local default="${2:-y}"
    local opts
    case "$default" in
        y|Y|s|S) opts="${WHITE}[${LIME}S${WHITE}/${GRAY}n${WHITE}]${NC}" ;;
        *)       opts="${WHITE}[${GRAY}s${WHITE}/${RED}N${WHITE}]${NC}" ;;
    esac
    printf "  ${MINT}?${NC} ${prompt} ${opts}: "
    local ans
    read -r ans
    case "$ans" in
        y|Y|s|S) return 0 ;;
        n|N)     return 1 ;;
        *)       [ "$default" = "y" ] || [ "$default" = "s" ] && return 0 || return 1 ;;
    esac
}

# ask_number "Elige" min max
ask_number() {
    local prompt="$1"
    local min="$2"
    local max="$3"
    local ans
    while true; do
        printf "  ${MINT}▸${NC} ${prompt} [${min}-${max}]: "
        read -r ans
        if [[ "$ans" =~ ^[0-9]+$ ]] && [ "$ans" -ge "$min" ] && [ "$ans" -le "$max" ]; then
            echo "$ans"
            return 0
        fi
        echo -e "  ${RED}Valor inválido.${NC}"
    done
}

# — Badges de recomendación —
badge() {
    local level="$1"
    local label="$2"
    case "$level" in
        done)   echo -e "  ${GRAY}✅ ${label} — ya instalado${NC}" ;;
        req)    echo -e "  ${LIME}● ${label}${NC} ${GRAY}(requerido)${NC}" ;;
        rec)    echo -e "  ${FOREST}● ${label}${NC} ${GRAY}(recomendado)${NC}" ;;
        opt)    echo -e "  ${GRAY}○ ${label}${NC} ${GRAY}(opcional)${NC}" ;;
        warn)   echo -e "  ${YELLOW}▲ ${label}${NC} ${YELLOW}(pesado para tu RAM)${NC}" ;;
        no)     echo -e "  ${RED}✕ ${label}${NC} ${RED}(no recomendado)${NC}" ;;
    esac
}

# — Separadores —
separator() {
    echo -e "${GRAY}─────────────────────────────────────────${NC}"
}

header() {
    echo ""
    echo -e "${FOREST}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${MINT}$1${NC}"
    echo -e "${FOREST}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# — Resumen de instalación —
# Uso: summary "Módulo" "tool1,tool2,tool3" "tool4,tool5"
# $2 = se instalan, $3 = se omiten
summary() {
    local module="$1"
    local install_list="$2"
    local skip_list="$3"
    echo ""
    echo -e "  ${MINT}═══ Resumen: ${module} ═══${NC}"
    if [ -n "$install_list" ]; then
        echo -e "  ${LIME}Instalar:${NC} ${install_list}"
    fi
    if [ -n "$skip_list" ]; then
        echo -e "  ${GRAY}Omitir:${NC}   ${skip_list}"
    fi
    echo ""
}

# — Mensajes de advertencia RAM —
ram_warning() {
    local tool="$1"
    local ram_needed="$2"
    local ram_have="$3"
    echo -e "  ${YELLOW}⚠ Tu dispositivo tiene ${ram_have}GB RAM.${NC}"
    echo -e "  ${YELLOW}  ${tool} usa ~${ram_needed}MB adicionales.${NC}"
    echo -e "  ${YELLOW}  Puede funcionar lento. Continuar de todos modos?${NC}"
}

# — Proot helper (para scripts container) —
proot_run() {
    proot-distro login archlinuxarm -- bash -c "$1"
}

proot_run_script() {
    local script_path="$1"
    shift
    proot-distro login archlinuxarm -- bash "$script_path" "$@"
}