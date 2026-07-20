#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Suite Gráfica dentro de Arch
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"
source "$HOME/scripts/container/proot_helper.sh"

header "Suite Gráfica — Dentro de Arch"

arch_check || exit 1
RAM_GB=$(config_get RAM_GB)
TO_INSTALL=""
TO_SKIP=""

ART_ITEMS=(
    "gimp:GIMP:heavy"
    "libresprite:LibreSprite:opt"
    "imagemagick:ImageMagick:opt"
    "audacity:Audacity:heavy"
)

for item in "${ART_ITEMS[@]}"; do
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
            if ask "¿Instalar de todos modos?" n; then
                TO_INSTALL="${TO_INSTALL}${pkg} "
            else
                TO_SKIP="${TO_SKIP}${desc} "
            fi
        elif [ "$level" = "warn" ]; then
            ram_warning "$desc" "400" "$RAM_GB"
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

summary "Suite Gráfica (Arch)" "$TO_INSTALL" "$TO_SKIP"

if [ -z "$TO_INSTALL" ]; then
    echo -e "  ${GRAY}Nada que instalar.${NC}"
    exit 0
fi

if ! ask "¿Proceder?" y; then exit 0; fi

echo ""
arch_wait_lock || exit 1
arch_install "$TO_INSTALL"

echo ""
echo -e "  ${LIME}✓ Suite gráfica instalada en Arch.${NC}"