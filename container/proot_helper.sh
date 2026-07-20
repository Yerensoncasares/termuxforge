#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Proot Helper
#  Funciones para ejecutar comandos dentro de Arch
# ═══════════════════════════════════════════════

DISTRO_NAME="archlinuxarm"
TERMUX_TMP="/data/data/com.termux/files/usr/tmp"

# Ejecutar comando dentro de Arch
arch_cmd() {
    proot-distro login "$DISTRO_NAME" -- bash -c "$1" 2>&1
}

# Ejecutar comando como root dentro de Arch
arch_root() {
    proot-distro login "$DISTRO_NAME" -- bash -c "$1" 2>&1
}

# Verificar si paquete está instalado en Arch
arch_has() {
    proot-distro login "$DISTRO_NAME" -- bash -c "pacman -Q '$1' >/dev/null 2>&1"
}

# Instalar paquetes en Arch (silencioso)
arch_install() {
    echo -e "  ${YELLOW}↓${NC} Instalando en Arch: $1"
    proot-distro login "$DISTRO_NAME" -- bash -c "pacman -S --noconfirm $1" 2>&1 | tail -1
}

# Copiar archivo de Termux a Arch
# $1 = ruta origen (Termux), $2 = ruta destino (Arch)
arch_copy() {
    local src="$1"
    local dst="$2"
    proot-distro login "$DISTRO_NAME" -- bash -c "
        mkdir -p '$(dirname "$dst")'
        cp '$src' '$dst'
    " 2>/dev/null
}

# Escribir archivo dentro de Arch via heredoc
# Uso: arch_write "/ruta/destino" << 'EOF'
#        contenido
#        EOF
arch_write() {
    local dst="$1"
    local content
    content=$(cat)
    # Usar base64 para evitar problemas de escape
    local b64
    b64=$(echo "$content" | base64 -w0)
    proot-distro login "$DISTRO_NAME" -- bash -c "
        mkdir -p '$(dirname "$dst")'
        echo '$b64' | base64 -d > '$dst'
    " 2>/dev/null
}

# Verificar que Arch está instalado
arch_check() {
    if ! proot-distro list 2>/dev/null | grep -q "$DISTRO_NAME"; then
        echo -e "  ${RED}✗ Arch Linux no está instalado.${NC}"
        echo -e "  ${GRAY}Instálalo primero desde el menú principal (opción 2).${NC}"
        return 1
    fi
    return 0
}

# Esperar a que pacman no esté bloqueado
arch_wait_lock() {
    proot-distro login "$DISTRO_NAME" -- bash -c "
        for i in \$(seq 1 10); do
            if ! pidof pacman >/dev/null 2>&1; then
                rm -f /var/lib/pacman/db.lck
                exit 0
            fi
            sleep 2
        done
        echo 'LOCKED'
    " 2>/dev/null
    if [ "$?" -ne 0 ]; then
        echo -e "  ${YELLOW}⚠ Pacman está ocupado. Espera y reintenta.${NC}"
        return 1
    fi
    return 0
}