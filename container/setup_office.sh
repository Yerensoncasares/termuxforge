#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Ofimática dentro de Arch
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"
source "$HOME/scripts/container/proot_helper.sh"

header "Ofimática — Dentro de Arch"

arch_check || exit 1
RAM_GB=$(config_get RAM_GB)
TO_INSTALL=""
TO_SKIP=""

OFFICE_ITEMS=(
    "libreoffice-fresh:LibreOffice:very_heavy"
    "thunderbird:Thunderbird:heavy"
    "evince:Evince (PDF):opt"
    "xournalpp:Xournal++ (Notas PDF):opt"
)

for item in "${OFFICE_ITEMS[@]}"; do
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
            ram_warning "$desc" "500" "$RAM_GB"
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

summary "Ofimática (Arch)" "$TO_INSTALL" "$TO_SKIP"

if [ -z "$TO_INSTALL" ]; then
    echo -e "  ${GRAY}Nada que instalar.${NC}"
    exit 0
fi

if ! ask "¿Proceder?" y; then exit 0; fi

echo ""
arch_wait_lock || exit 1

# LibreOffice con --no-install-recommends para ahorrar espacio
if echo "$TO_INSTALL" | grep -q "libreoffice"; then
    echo -e "${MINT}Instalando LibreOffice (sin extras)...${NC}"
    arch_root "pacman -S --noconfirm --needed libreoffice-fresh" 2>&1 | tail -3
    arch_has "libreoffice-fresh" || ERRORS=$((ERRORS + 1))
    TO_INSTALL=$(echo "$TO_INSTALL" | sed 's/libreoffice-fresh //')
fi

if [ -n "$TO_INSTALL" ]; then
    arch_install "$TO_INSTALL"
fi

echo ""
echo -e "  ${LIME}✓ Ofimática instalada en Arch.${NC}"