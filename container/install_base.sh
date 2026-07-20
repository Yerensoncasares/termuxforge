#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Base Termux (Anfitrión para Arch)
#  Versión ligera: solo lo necesario como host
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"

header "Base Termux — Modo Anfitrión"

# — Paso 1: Limpieza —
echo -e "${MINT}[1/4]${NC} Limpiando..."
pkill -9 apt 2>/dev/null || true
pkill -9 dpkg 2>/dev/null || true
rm -f "$PREFIX/var/lib/dpkg/lock" "$PREFIX/var/lib/dpkg/lock-frontend"
rm -f "$PREFIX/var/cache/apt/archives/lock"
dpkg --configure -a 2>/dev/null || true
echo -e "  ${LIME}✓${NC} Limpio"

# — Paso 2: Actualizar —
echo ""
echo -e "${MINT}[2/4]${NC} Actualizando sistema..."
(yes | pkg update -y > /dev/null 2>&1) & spinner $! "Actualizando índices..."
(yes | pkg upgrade -y > /dev/null 2>&1) & spinner $! "Actualizando paquetes..."

# — Paso 3: Repos + proot-distro —
echo ""
echo -e "${MINT}[3/4]${NC} Instalando repositorios y proot-distro..."

if ! pkg list-installed 2>/dev/null | grep -q "x11-repo"; then
    install_pkg "x11-repo" "X11 Repository"
else
    echo -e "  ${GRAY}○ x11-repo ya instalado${NC}"
fi

if ! pkg list-installed 2>/dev/null | grep -q "tur-repo"; then
    install_pkg "tur-repo" "TUR Repository"
else
    echo -e "  ${GRAY}○ tur-repo ya instalado${NC}"
fi

if ! command -v proot-distro >/dev/null 2>&1; then
    install_pkg "proot-distro" "proot-distro"
else
    echo -e "  ${GRAY}○ proot-distro ya instalado${NC}"
fi

# — Paso 4: Host tools mínimos —
echo ""
echo -e "${MINT}[4/4]${NC} Herramientas del anfitrión..."

HOST_PKGS=(
    "git:Git"
    "wget:Wget"
    "curl:cURL"
    "pulseaudio:PulseAudio"
    "termux-api:Termux API"
    "unzip:Unzip"
    "file:File"
)

for item in "${HOST_PKGS[@]}"; do
    pkg="${item%%:*}"
    desc="${item##*:}"
    if pkg list-installed 2>/dev/null | grep -q "$pkg"; then
        echo -e "  ${GRAY}○ ${desc}${NC}"
    else
        install_pkg "$pkg" "$desc"
    fi
done

# — Estructura —
mkdir -p "$HOME"/{Desktop,Projects,Automation,Apps_Linux,Godot/Templates,Godot/Workspace}

echo ""
echo -e "  ${LIME}✓ Base anfitrión lista. Ahora instala Arch Linux.${NC}"