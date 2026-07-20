#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Desarrollo de Juegos dentro de Arch
#  Cada herramienta es opcional
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"
source "$HOME/scripts/container/proot_helper.sh"

header "Desarrollo de Juegos — Dentro de Arch"

arch_check || exit 1

RAM_GB=$(config_get RAM_GB)
TO_INSTALL=""
TO_SKIP=""

# Lista: "paquete:descripcion:peso"
GAME_ITEMS=(
    "renpy:Ren'Py (Visual Novels):opt"
    "love:LÖVE / Love2D:opt"
    "python-pygame:Pygame (Python):opt"
    "raylib:Raylib (C/C++):opt"
    "python-panda3d:Panda3D (Python 3D):heavy"
)

for item in "${GAME_ITEMS[@]}"; do
    pkg="${item%%:*}"
    rest="${item#*:}"
    desc="${rest%%:*}"
    weight="${rest##*:}"

    echo ""
    level=$(recommend "$weight")
    badge "$level" "${desc}"

    if arch_has "$pkg"; then
        echo -e "  ${GRAY}  ○ Ya instalado${NC}"
    else
        if [ "$level" = "no" ]; then
            echo -e "  ${RED}  ⚠ No recomendado para ${RAM_GB}GB RAM${NC}"
            if ask "¿Instalar de todos modos?" n; then
                TO_INSTALL="${TO_INSTALL}${pkg} "
            else
                TO_SKIP="${TO_SKIP}${desc} "
            fi
        elif [ "$level" = "warn" ]; then
            ram_warning "$desc" "200" "$RAM_GB"
            if ask "¿Instalar?" n; then
                TO_INSTALL="${TO_INSTALL}${pkg} "
            else
                TO_SKIP="${TO_SKIP}${desc} "
            fi
        else
            if ask "¿Instalar ${desc}?" y; then
                TO_INSTALL="${TO_INSTALL}${pkg} "
            else
                TO_SKIP="${TO_SKIP}${desc} "
            fi
        fi
    fi
done

# — Ren'Py necesita AUR en Arch —
# Usamos pip para instalar una versión alternativa si no está en pacman
echo ""
if echo "$TO_INSTALL" | grep -q "renpy"; then
    if ! arch_root "pacman -Si renpy >/dev/null 2>&1"; then
        echo -e "  ${YELLOW}⚠ Ren'Py no está en los repos oficiales de Arch ARM.${NC}"
        echo -e "  ${GRAY}Se intentará instalar via pip (python-renpy).${NC}"
        TO_INSTALL="${TO_INSTALL}renpy-pip "
        TO_INSTALL=$(echo "$TO_INSTALL" | sed 's/renpy //')
    fi
fi

summary "Desarrollo de Juegos" "$TO_INSTALL" "$TO_SKIP"

if [ -z "$TO_INSTALL" ]; then
    echo -e "  ${GRAY}Nada que instalar.${NC}"
    exit 0
fi

if ! ask "¿Proceder?" y; then exit 0; fi

echo ""
arch_wait_lock || exit 1
ERRORS=0

# Paquetes de pacman directos
PACMAN_PKGS=""
for pkg in love python-pygame; do
    if echo "$TO_INSTALL" | grep -q "$pkg"; then
        PACMAN_PKGS="${PACMAN_PKGS}${pkg} "
    fi
done

if [ -n "$PACMAN_PKGS" ]; then
    arch_install "$PACMAN_PKGS"
    for pkg in $PACMAN_PKGS; do
        arch_has "$pkg" || ERRORS=$((ERRORS + 1))
    done
fi

# Raylib (puede necesitar compilación)
if echo "$TO_INSTALL" | grep -q "raylib"; then
    if ! arch_install "raylib"; then
        echo -e "  ${YELLOW}⚠ raylib no encontrado en repos, compilando...${NC}"
        arch_root "
            pacman -S --noconfirm cmake git
            cd /tmp
            git clone --depth 1 https://github.com/raysan5/raylib.git raylib-build
            cd raylib-build
            mkdir build && cd build
            cmake -DBUILD_SHARED_LIBS=ON ..
            make -j\$(nproc)
            make install
            cd / && rm -rf /tmp/raylib-build
            ldconfig
        " 2>&1 | tail -3
        arch_has "raylib" || ERRORS=$((ERRORS + 1))
    fi
fi

# Ren'Py via pip
if echo "$TO_INSTALL" | grep -q "renpy-pip"; then
    echo -e "${MINT}Instalando Ren'Py via pip...${NC}"
    arch_root "pip install renpy" 2>&1 | tail -2
    arch_cmd "python -c 'import renpy' 2>/dev/null" || ERRORS=$((ERRORS + 1))
fi

# Panda3D via pip
if echo "$TO_INSTALL" | grep -q "python-panda3d"; then
    echo -e "${MINT}Instalando Panda3D via pip...${NC}"
    arch_root "pip install panda3d" 2>&1 | tail -2
    arch_cmd "python -c 'from panda3d.core import Window' 2>/dev/null" || ERRORS=$((ERRORS + 1))
fi

echo ""
if [ "$ERRORS" -eq 0 ]; then
    echo -e "  ${LIME}✓ Desarrollo de Juegos instalado en Arch.${NC}"
else
    echo -e "  ${RED}✗ Algunas instalaciones fallaron.${NC}"
    exit 1
fi