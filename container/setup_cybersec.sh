#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Ciberseguridad dentro de Arch
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"
source "$HOME/scripts/container/proot_helper.sh"

header "Ciberseguridad — Dentro de Arch"

arch_check || exit 1
RAM_GB=$(config_get RAM_GB)
TO_INSTALL=""
TO_SKIP=""

CYBER_ITEMS=(
    "nmap:Nmap:opt"
    "wireshark-qt:Wireshark:heavy"
    "tcpdump:tcpdump:opt"
    "aircrack-ng:Aircrack-ng:opt"
    "john:John the Ripper:opt"
    "hydra:Hydra:opt"
    "sqlmap:SQLMap:opt"
    "hashcat:Hashcat:heavy"
    "nikto:Nikto:opt"
)

for item in "${CYBER_ITEMS[@]}"; do
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

summary "Ciberseguridad (Arch)" "$TO_INSTALL" "$TO_SKIP"

if [ -z "$TO_INSTALL" ]; then
    echo -e "  ${GRAY}Nada que instalar.${NC}"
    exit 0
fi

if ! ask "¿Proceder?" y; then exit 0; fi

echo ""
arch_wait_lock || exit 1
arch_install "$TO_INSTALL"

# Wireshark: agregar usuario al grupo
if echo "$TO_INSTALL" | grep -q "wireshark"; then
    arch_root "usermod -aG wireshark forge 2>/dev/null" || true
fi

echo ""
echo -e "  ${LIME}✓ Ciberseguridad instalada en Arch.${NC}"
echo -e "  ${GRAY}Nota: Wireshark puede necesitar sudo para captura de paquetes.${NC}"