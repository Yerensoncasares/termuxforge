#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Multimedia dentro de Arch
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"
source "$HOME/scripts/container/proot_helper.sh"

header "Multimedia — Dentro de Arch"

arch_check || exit 1
TO_INSTALL=""
TO_SKIP=""

MEDIA_ITEMS=(
    "mpv:MPV Player:opt"
    "ffmpeg:FFmpeg:opt"
    "tenacity:Tenacity (Audio):heavy"
)

for item in "${MEDIA_ITEMS[@]}"; do
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
        else
            if ask "¿Instalar ${desc}?" y; then
                TO_INSTALL="${TO_INSTALL}${pkg} "
            else
                TO_SKIP="${TO_SKIP}${desc} "
            fi
        fi
    fi
done

summary "Multimedia (Arch)" "$TO_INSTALL" "$TO_SKIP"

if [ -z "$TO_INSTALL" ]; then
    echo -e "  ${GRAY}Nada que instalar.${NC}"
    exit 0
fi

if ! ask "¿Proceder?" y; then exit 0; fi

echo ""
arch_wait_lock || exit 1
arch_install "$TO_INSTALL"

echo ""
echo -e "  ${LIME}✓ Multimedia instalada en Arch.${NC}"