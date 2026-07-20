#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Desarrollo Web dentro de Arch
#  Firefox (repo Mozilla), Node.js, Python, Geany
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"
source "$HOME/scripts/container/proot_helper.sh"

header "Desarrollo Web — Dentro de Arch"

arch_check || exit 1

TO_INSTALL=""
TO_SKIP=""

# — Firefox (repo Mozilla) —
echo -e "${MINT}═══ Firefox ═══${NC}"
if arch_has "firefox"; then
    echo -e "  ${GRAY}○ Firefox ya instalado${NC}"
else
    if ask "¿Instalar Firefox (repo oficial Mozilla)?" y; then
        TO_INSTALL="${TO_INSTALL}firefox-setup "
    else
        TO_SKIP="${TO_SKIP}Firefox "
    fi
fi

# — Node.js en Arch —
echo ""
echo -e "${MINT}═══ Node.js (en Arch) ═══${NC}"
if arch_has "nodejs"; then
    echo -e "  ${GRAY}○ Node.js ya instalado en Arch${NC}"
else
    if ask "¿Instalar Node.js dentro de Arch?" y; then
        TO_INSTALL="${TO_INSTALL}nodejs "
    else
        TO_SKIP="${TO_SKIP}Node.js "
    fi
fi

# — Python en Arch —
echo ""
echo -e "${MINT}═══ Python (en Arch) ═══${NC}"
if arch_has "python"; then
    echo -e "  ${GRAY}○ Python ya instalado en Arch${NC}"
else
    if ask "¿Instalar Python dentro de Arch?" y; then
        TO_INSTALL="${TO_INSTALL}python "
    else
        TO_SKIP="${TO_SKIP}Python "
    fi
fi

# — Geany —
echo ""
echo -e "${MINT}═══ Geany ═══${NC}"
echo -e "  ${GRAY}Editor ligero (~30MB RAM), alternativa a VS Code.${NC}"
if arch_has "geany"; then
    echo -e "  ${GRAY}○ Geany ya instalado${NC}"
else
    if ask "¿Instalar Geany?" y; then
        TO_INSTALL="${TO_INSTALL}geany "
    else
        TO_SKIP="${TO_SKIP}Geany "
    fi
fi

# — live-server (si Node.js se instala) —
if echo "$TO_INSTALL" | grep -q "nodejs"; then
    echo ""
    if ask "¿Instalar live-server (previsualización web)?" y; then
        TO_INSTALL="${TO_INSTALL}live-server "
    fi
fi

summary "Desarrollo Web (Arch)" "$TO_INSTALL" "$TO_SKIP"

if [ -z "$TO_INSTALL" ]; then
    echo -e "  ${GRAY}Nada que instalar.${NC}"
    exit 0
fi

if ! ask "¿Proceder?" y; then exit 0; fi

echo ""
arch_wait_lock || exit 1
ERRORS=0

# — Firefox con repo Mozilla —
if echo "$TO_INSTALL" | grep -q "firefox-setup"; then
    echo -e "${MINT}Configurando repo Mozilla...${NC}"
    arch_root "
        mkdir -p /etc/pacman.d/gnupg
        gpg --keyserver keyserver.ubuntu.com --recv-keys 0xABED10F5B0F25E01 2>/dev/null
        gpg --export 0xABED10F5B0F25E01 | pacman-key -a - 2>/dev/null
        echo -e '\n[firefox]\nServer = https://repo.archlinux.org/\$arch/\nSigLevel = Required TrustedOnly' >> /etc/pacman.conf
    " 2>&1 | tail -2

    echo -e "${MINT}Instalando Firefox...${NC}"
    if arch_install "firefox"; then
        # Crear wrapper para proot (deshabilitar sandbox)
        arch_write "/usr/local/bin/firefox" << 'FEOF'
#!/bin/bash
export MOZ_DISABLE_CONTENT_SANDBOX=1
export MOZ_DISABLE_GMP_SANDBOX=1
export MOZ_DISABLE_RDD_SANDBOX=1
export MOZ_DISABLE_SOCKET_PROCESS_SANDBOX=1
exec /usr/bin/firefox "\$@"
FEOF
        arch_root "chmod +x /usr/local/bin/firefox"

        # Actualizar .desktop para usar wrapper
        arch_write "/usr/share/applications/firefox.desktop" << 'DEOF'
[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=/usr/local/bin/firefox %u
Icon=firefox
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;
StartupNotify=true
DEOF
        echo -e "  ${LIME}✓${NC} Firefox instalado con fix de proot"
    else
        ERRORS=$((ERRORS + 1))
        echo -e "  ${RED}✗ Firefox falló${NC}"
    fi
fi

# — Paquetes simples de pacman —
SIMPLE_PKGS=""
for pkg in nodejs python geany; do
    if echo "$TO_INSTALL" | grep -q "^${pkg} \| ${pkg} \|${pkg}$"; then
        SIMPLE_PKGS="${SIMPLE_PKGS}${pkg} "
    fi
done

if [ -n "$SIMPLE_PKGS" ]; then
    arch_install "$SIMPLE_PKGS"
    for pkg in $SIMPLE_PKGS; do
        arch_has "$pkg" || ERRORS=$((ERRORS + 1))
    done
fi

# — live-server —
if echo "$TO_INSTALL" | grep -q "live-server"; then
    echo -e "${MINT}Instalando live-server...${NC}"
    arch_root "npm install -g live-server" 2>&1 | tail -1
fi

echo ""
if [ "$ERRORS" -eq 0 ]; then
    echo -e "  ${LIME}✓ Desarrollo Web instalado en Arch.${NC}"
else
    echo -e "  ${RED}✗ Algunas instalaciones fallaron.${NC}"
    exit 1
fi