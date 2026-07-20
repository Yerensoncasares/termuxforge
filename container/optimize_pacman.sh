#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Optimizar Pacman en Arch
#  Mirror speed test + ParallelDownloads
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"
source "$HOME/scripts/container/proot_helper.sh"

header "Optimización de Pacman"

arch_check || exit 1

# — Activar ParallelDownloads —
echo -e "${MINT}[1/2]${NC} Activando descargas paralelas..."
arch_root "sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf"
echo -e "  ${LIME}✓${NC} ParallelDownloads activado"

# — Test de velocidad de mirrors —
echo ""
echo -e "${MINT}[2/2]${NC} Buscando mirror más rápido..."
echo -e "  ${GRAY}(probando 8 mirrors, espera un momento...)${NC}"

MIRRORS=(
    "http://mirror.archlinuxarm.org"
    "http://mirror.leaseweb.com/archlinuxarm"
    "http://mirrors.dotsrc.org/archlinuxarm"
    "http://ftp.halifax.rwth-aachen.de/archlinuxarm"
    "http://mirrors.ustc.edu.cn/archlinuxarm"
    "http://mirror.umd.edu/archlinuxarm"
    "http://ftp.jaist.ac.jp/pub/archlinuxarm"
    "http://mirror.csclub.uwaterloo.ca/archlinuxarm"
)

BEST_MIRROR=""
BEST_TIME=9999

for url in "${MIRRORS[@]}"; do
    ttime=$(curl -o /dev/null -s -w "%{time_total}" --connect-timeout 3 --head "${url}/aarch64/core/core.db" 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$ttime" ]; then
        is_faster=$(echo "$ttime < $BEST_TIME" | bc -l 2>/dev/null)
        if [ "${is_faster:-0}" -eq 1 ]; then
            BEST_TIME="$ttime"
            BEST_MIRROR="$url"
        fi
    fi
done

if [ -n "$BEST_MIRROR" ]; then
    echo -e "  ${LIME}✓${NC} Mejor mirror: ${BEST_MIRROR} (${BEST_TIME}s)"
    arch_root "echo 'Server = ${BEST_MIRROR}/\$arch/\$repo' > /etc/pacman.d/mirrorlist"
    arch_root "echo 'Server = http://mirror.archlinuxarm.org/\$arch/\$repo' >> /etc/pacman.d/mirrorlist"
else
    echo -e "  ${YELLOW}⚠ No se pudo testear. Usando mirror por defecto.${NC}"
    arch_root "echo 'Server = http://mirror.archlinuxarm.org/\$arch/\$repo' > /etc/pacman.d/mirrorlist"
fi

# — Actualizar —
echo ""
echo -e "${MINT}Actualizando base de Arch...${NC}"
arch_root "pacman -Sy --noconfirm" 2>&1 | tail -3

echo ""
echo -e "  ${LIME}✓ Pacman optimizado.${NC}"