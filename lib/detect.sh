#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Hardware Detection
# ═══════════════════════════════════════════════

detect_ram_mb() {
    # Lee RAM total desde /proc/meminfo
    local ram_kb
    ram_kb=$(grep "^MemTotal:" /proc/meminfo 2>/dev/null | awk '{print $2}')
    if [ -n "$ram_kb" ] && [ "$ram_kb" -gt 0 ]; then
        echo $(( ram_kb / 1024 ))
    else
        echo "4096"  # fallback
    fi
}

detect_ram_gb() {
    local mb
    mb=$(detect_ram_mb)
    echo $(( mb / 1024 ))
}

detect_cpu_cores() {
    local cores
    cores=$(nproc 2>/dev/null || grep -c "^processor" /proc/cpuinfo 2>/dev/null)
    echo "${cores:-4}"
}

detect_storage_free_mb() {
    local free_kb
    free_kb=$(df "$HOME" 2>/dev/null | awk 'NR==2 {print $4}')
    if [ -n "$free_kb" ] && [ "$free_kb" -gt 0 ]; then
        echo $(( free_kb / 1024 ))
    else
        echo "0"
    fi
}

detect_arch() {
    uname -m 2>/dev/null || echo "aarch64"
}

detect_android_version() {
    getprop ro.build.version.release 2>/dev/null || echo "Desconocido"
}

# — Clasificación por tier de RAM —
# Retorna: low | mid | high | ultra
get_ram_tier() {
    local gb
    gb=$(detect_ram_gb)
    if [ "$gb" -le 3 ]; then
        echo "low"
    elif [ "$gb" -le 6 ]; then
        echo "mid"
    elif [ "$gb" -le 11 ]; then
        echo "high"
    else
        echo "ultra"
    fi
}

# — Badge level basado en tier + peso del módulo —
# $1 = peso: "req" | "rec" | "opt" | "heavy" | "very_heavy"
# Retorna: req | rec | opt | warn | no
recommend() {
    local weight="$1"
    local tier
    tier=$(get_ram_tier)

    case "$weight" in
        req)
            echo "req"
            ;;
        rec)
            case "$tier" in
                low)  echo "warn" ;;
                *)    echo "rec"  ;;
            esac
            ;;
        opt)
            case "$tier" in
                low)   echo "no"   ;;
                mid)   echo "opt"  ;;
                *)     echo "opt"  ;;
            esac
            ;;
        heavy)
            case "$tier" in
                low)   echo "no"   ;;
                mid)   echo "warn" ;;
                high)  echo "opt"  ;;
                ultra) echo "opt"  ;;
            esac
            ;;
        very_heavy)
            case "$tier" in
                low|mid)  echo "no"   ;;
                high)     echo "warn" ;;
                ultra)    echo "opt"  ;;
            esac
            ;;
        *)
            echo "opt"
            ;;
    esac
}

# — Muestra información detectada —
show_hardware_info() {
    local ram_gb ram_mb cores storage_mb arch android
    ram_gb=$(detect_ram_gb)
    ram_mb=$(detect_ram_mb)
    cores=$(detect_cpu_cores)
    storage_mb=$(detect_storage_free_mb)
    arch=$(detect_arch)
    android=$(detect_android_version)

    echo -e "${MINT}"
    cat << 'BANNER'
     ╔══════════════════════════════════════════╗
     ║          DETECCIÓN DE HARDWARE            ║
     ╚══════════════════════════════════════════╝
BANNER
    echo -e "${NC}"
    echo -e "  ${LIME}🧠${NC}  RAM física:       ${WHITE}${ram_mb} MB (${ram_gb} GB)${NC}"
    echo -e "  ${LIME}⚙️${NC}   CPU núcleos:      ${WHITE}${cores}${NC}"
    echo -e "  ${LIME}💾${NC}  Almacen. libre:   ${WHITE}$(( storage_mb / 1024 )) GB (${storage_mb} MB)${NC}"
    echo -e "  ${LIME}📐${NC}  Arquitectura:     ${WHITE}${arch}${NC}"
    echo -e "  ${LIME}🤖${NC}  Android:          ${WHITE}${android}${NC}"
    echo ""

    # Guardar en config
    config_set RAM_GB "$ram_gb"
    config_set RAM_MB "$ram_mb"
    config_set CPU_CORES "$cores"
    config_set STORAGE_FREE "$storage_mb"
    config_set ARCH "$arch"
    config_set RAM_TIER "$(get_ram_tier)"
}

# — Verificación de requisitos —
check_requirements() {
    local errors=0

    # Verificar conexión a internet
    if ! ping -c 1 -W 3 google.com > /dev/null 2>&1; then
        if ! ping -c 1 -W 3 cloudflare.com > /dev/null 2>&1; then
            echo -e "  ${RED}✗ Sin conexión a internet detectada.${NC}"
            echo -e "  ${RED}  El instalador necesita internet para descargar paquetes.${NC}"
            errors=$((errors + 1))
        fi
    fi

    # Verificar almacenamiento mínimo (2 GB libres)
    local storage
    storage=$(detect_storage_free_mb)
    if [ "$storage" -lt 2048 ]; then
        echo -e "  ${RED}✗ Solo ${storage}MB libres. Se necesitan al menos 2 GB.${NC}"
        errors=$((errors + 1))
    fi

    # Verificar que sea ARM64
    local arch
    arch=$(detect_arch)
    if [ "$arch" != "aarch64" ]; then
        echo -e "  ${YELLOW}⚠ Arquitectura ${arch} detectada.${NC}"
        echo -e "  ${YELLOW}  TermuxForge está optimizado para ARM64. Puede haber problemas.${NC}"
    fi

    return "$errors"
}