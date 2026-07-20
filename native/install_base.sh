#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Base Termux Nativo
#  Repositorios, limpieza, estructura de directorios
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"

header "Base Termux — Instalación"

# — Paso 1: Limpiar locks y reparar —
echo -e "${MINT}[1/5]${NC} Limpiando instalaciones previas..."
pkill -9 apt 2>/dev/null || true
pkill -9 dpkg 2>/dev/null || true
rm -f "$PREFIX/var/lib/dpkg/lock" "$PREFIX/var/lib/dpkg/lock-frontend"
rm -f "$PREFIX/var/cache/apt/archives/lock"
dpkg --configure -a 2>/dev/null || true
echo -e "  ${LIME}✓${NC} Limpieza completada"

# — Paso 2: Actualizar sistema —
echo ""
echo -e "${MINT}[2/5]${NC} Actualizando sistema base..."
(yes | pkg update -y > /dev/null 2>&1) & spinner $! "Actualizando índices..."
(yes | pkg upgrade -y > /dev/null 2>&1) & spinner $! "Actualizando paquetes..."

# — Paso 3: Repositorios —
echo ""
echo -e "${MINT}[3/5]${NC} Activando repositorios..."
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

# — Paso 4: Herramientas base —
echo ""
echo -e "${MINT}[4/5]${NC} Instalando herramientas base..."
BASE_PKGS=(
    "git:Git"
    "wget:Wget"
    "curl:cURL"
    "file:File"
    "unzip:Unzip"
    "p7zip:7-Zip"
    "termux-api:Termux API"
    "pulseaudio:PulseAudio"
)

for item in "${BASE_PKGS[@]}"; do
    pkg_name="${item%%:*}"
    pkg_desc="${item##*:}"
    if pkg list-installed 2>/dev/null | grep -q "$pkg_name"; then
        echo -e "  ${GRAY}○ ${pkg_desc} ya instalado${NC}"
    else
        install_pkg "$pkg_name" "$pkg_desc"
    fi
done

# — Paso 5: Estructura de directorios —
echo ""
echo -e "${MINT}[5/5]${NC} Creando estructura de directorios..."
DIRS=(
    "$HOME/Desktop"
    "$HOME/Projects"
    "$HOME/Automation"
    "$HOME/Apps_Linux"
    "$HOME/Godot/Templates"
    "$HOME/Godot/Workspace"
)
for d in "${DIRS[@]}"; do
    mkdir -p "$d"
done
echo -e "  ${LIME}✓${NC} Directorios creados"

# — Verificación —
echo ""
echo -e "${MINT}Verificación:${NC}"
ERRORS=0
for cmd in git wget curl unzip pulseaudio; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "  ${LIME}✓${NC} ${cmd}"
    else
        echo -e "  ${RED}✗${NC} ${cmd} faltante"
        ERRORS=$((ERRORS + 1))
    fi
done

if [ "$ERRORS" -eq 0 ]; then
    echo ""
    echo -e "  ${LIME}✓ Base Termux instalada correctamente.${NC}"
    exit 0
else
    echo ""
    echo -e "  ${RED}✗ ${ERRORS} herramientas faltantes. Revisa los errores.${NC}"
    exit 1
fi