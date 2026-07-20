#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Terminal Enhancements
#  Zsh, OhMyZsh, plugins, Nerd Font, colores, fastfetch
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"

header "Tweaks de Terminal"

TO_INSTALL=""
TO_SKIP=""

# — Oh My Zsh —
echo -e "${MINT}═══ Oh My Zsh ═══${NC}"
if [ -d "$HOME/.oh-my-zsh" ] && [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    echo -e "  ${GRAY}○ Oh My Zsh ya instalado${NC}"
else
    if ask "¿Instalar Oh My Zsh?" y; then
        TO_INSTALL="${TO_INSTALL}OhMyZsh "
    else
        TO_SKIP="${TO_SKIP}OhMyZsh "
    fi
fi

# — Plugins Zsh —
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo ""
    echo -e "${MINT}═══ Plugins Zsh ═══${NC}"

    PLUGINS=(
        "zsh-autosuggestions:Autosugerencias"
        "zsh-syntax-highlighting:Syntax Highlighting"
    )

    for p in "${PLUGINS[@]}"; do
        pdir="${p%%:*}"
        pname="${p##*:}"
        if [ -d "$HOME/.oh-my-zsh/custom/plugins/${pdir}" ]; then
            echo -e "  ${GRAY}○ ${pname} ya instalado${NC}"
        else
            if ask "¿Instalar ${pname}?" y; then
                TO_INSTALL="${TO_INSTALL}${pname} "
            else
                TO_SKIP="${TO_SKIP}${pname} "
            fi
        fi
    done
fi

# — Nerd Font para Termux —
echo ""
echo -e "${MINT}═══ Fuente Nerd para Termux ═══${NC}"
echo -e "  ${GRAY}Se instalará en ~/.termux/font.ttf${NC}"
echo -e "  ${GRAY}Necesitas reiniciar Termux para ver el cambio.${NC}"
if [ -f "$HOME/.termux/font.ttf" ]; then
    echo -e "  ${GRAY}○ Ya tienes una fuente personalizada${NC}"
    if ask "¿Reemplazar con JetBrains Mono Nerd?" n; then
        TO_INSTALL="${TO_INSTALL}Font_Termux "
    else
        TO_SKIP="${TO_SKIP}Font_Termux "
    fi
else
    if ask "¿Instalar JetBrains Mono Nerd como fuente de Termux?" y; then
        TO_INSTALL="${TO_INSTALL}Font_Termux "
    else
        TO_SKIP="${TO_SKIP}Font_Termux "
    fi
fi

# — Colores de Termux —
echo ""
echo -e "${MINT}═══ Esquema de colores ═══${NC}"
if [ -f "$HOME/.termux/colors.properties" ]; then
    echo -e "  ${GRAY}○ Ya tienes colores personalizados${NC}"
    if ! ask "¿Reemplazar?" n; then
        TO_SKIP="${TO_SKIP}Colores "
    fi
else
    if ask "¿Elegir esquema de colores?" y; then
        TO_INSTALL="${TO_INSTALL}Colores "
    else
        TO_SKIP="${TO_SKIP}Colores "
    fi
fi

# — Fastfetch —
echo ""
echo -e "${MINT}═══ Fastfetch ═══${NC}"
if command -v fastfetch >/dev/null 2>&1; then
    echo -e "  ${GRAY}○ Fastfetch ya instalado${NC}"
else
    if ask "¿Instalar Fastfetch (info del sistema al abrir terminal)?" y; then
        TO_INSTALL="${TO_INSTALL}Fastfetch "
    else
        TO_SKIP="${TO_SKIP}Fastfetch "
    fi
fi

# — Resumen —
summary "Tweaks de Terminal" "$TO_INSTALL" "$TO_SKIP"

if [ -z "$TO_INSTALL" ]; then
    echo -e "  ${GRAY}Nada que instalar.${NC}"
    exit 0
fi

if ! ask "¿Proceder?" y; then
    echo -e "  ${GRAY}Cancelado.${NC}"
    exit 0
fi

# ═════════════════════════════════════════
#  EJECUCIÓN
# ═════════════════════════════════════════

# — Zsh —
install_pkg "zsh" "Zsh"

# — Oh My Zsh —
if echo "$TO_INSTALL" | grep -q "OhMyZsh"; then
    echo ""
    echo -e "${MINT}Instalando Oh My Zsh...${NC}"
    (RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended > /dev/null 2>&1) & spinner $! "Descargando Oh My Zsh..."
fi

# — Plugins —
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if echo "$TO_INSTALL" | grep -q "Autosugerencias"; then
    echo ""
    (git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" > /dev/null 2>&1) & spinner $! "Clonando zsh-autosuggestions..."
fi

if echo "$TO_INSTALL" | grep -q "Syntax Highlighting"; then
    echo ""
    (git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" > /dev/null 2>&1) & spinner $! "Clonando zsh-syntax-highlighting..."
fi

# — Configurar plugins en .zshrc —
if [ -f "$HOME/.zshrc" ]; then
    sed -i 's/^plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc" 2>/dev/null
fi

# — Fuente para Termux —
if echo "$TO_INSTALL" | grep -q "Font_Termux"; then
    echo ""
    mkdir -p "$HOME/.termux"
    TMPFONT="$HOME/tmpforge-font"
    mkdir -p "$TMPFONT" && cd "$TMPFONT" || exit 1

    echo -e "${MINT}═══ Elige fuente ═══${NC}"
    echo -e "  ${LIME}1)${NC} JetBrains Mono (recomendado)"
    echo -e "  ${LIME}2)${NC} FiraCode"
    echo -e "  ${LIME}3)${NC} Meslo"

    fchoice=$(ask_number "Elige" 1 3)
    case "$fchoice" in
        2) FONT_ZIP="FiraCode.zip" ;;
        3) FONT_ZIP="Meslo.zip" ;;
        *) FONT_ZIP="JetBrainsMono.zip" ;;
    esac

    (curl -fL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_ZIP}" -o font.zip > /dev/null 2>&1) & spinner $! "Descargando fuente..."
    unzip -q -o font.zip "*Regular.ttf" -d "$HOME/.termux" 2>/dev/null
    FONTFILE=$(ls "$HOME/.termux"/*Regular.ttf 2>/dev/null | head -n 1)
    if [ -n "$FONTFILE" ]; then
        mv -f "$FONTFILE" "$HOME/.termux/font.ttf"
        echo -e "  ${LIME}✓${NC} Fuente instalada como ~/.termux/font.ttf"
    fi
    rm -rf "$TMPFONT"
    cd "$HOME"
    termux-reload-settings 2>/dev/null
fi

# — Colores —
if echo "$TO_INSTALL" | grep -q "Colores"; then
    echo ""
    mkdir -p "$HOME/.termux"
    echo -e "${MINT}═══ Elige esquema ═══${NC}"
    echo -e "  ${LIME}1)${NC} GitHub Dark (recomendado)"
    echo -e "  ${LIME}2)${NC} Dracula"
    echo -e "  ${LIME}3)${NC} Gruvbox Dark"

    cchoice=$(ask_number "Elige" 1 3)
    case "$cchoice" in
        2) # Dracula
            cat > "$HOME/.termux/colors.properties" << 'EOF'
foreground=#f8f8f2
background=#282a36
cursor=#f8f8f2
color0=#21222c
color1=#ff5555
color2=#50fa7b
color3=#f1fa8c
color4=#bd93f9
color5=#ff79c6
color6=#8be9fd
color7=#f8f8f2
color8=#6272a4
color9=#ff6e6e
color10=#69ff94
color11=#ffffa5
color12=#d6acff
color13=#ff92df
color14=#a4ffff
color15=#ffffff
EOF
            ;;
        3) # Gruvbox
            cat > "$HOME/.termux/colors.properties" << 'EOF'
foreground=#ebdbb2
background=#282828
cursor=#ebdbb2
color0=#282828
color1=#cc241d
color2=#98971a
color3=#d79921
color4=#458588
color5=#b16286
color6=#689d6a
color7=#a89984
color8=#928374
color9=#fb4934
color10=#b8bb26
color11=#fabd2f
color12=#83a598
color13=#d3869b
color14=#8ec07c
color15=#ebdbb2
EOF
            ;;
        *) # GitHub Dark
            cat > "$HOME/.termux/colors.properties" << 'EOF'
foreground=#c9d1d9
background=#0d1117
cursor=#c9d1d9
color0=#484f58
color1=#ff7b72
color2=#3fb950
color3=#d29922
color4=#58a6ff
color5=#bc8cff
color6=#39c5cf
color7=#b1bac4
color8=#6e7681
color9=#ffa198
color10=#56d364
color11=#e3b341
color12=#79c0ff
color13=#d2a8ff
color14=#56d4dd
color15=#f0f6fc
EOF
            ;;
    esac
    echo -e "  ${LIME}✓${NC} Colores aplicados"
    termux-reload-settings 2>/dev/null
fi

# — Fastfetch —
if echo "$TO_INSTALL" | grep -q "Fastfetch"; then
    echo ""
    install_pkg "fastfetch" "Fastfetch"

    # Quitar MOTD por defecto
    rm -f "$PREFIX/etc/motd"

    # Agregar fastfetch al inicio de .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "fastfetch" "$HOME/.zshrc" 2>/dev/null; then
            sed -i '1ifastfetch' "$HOME/.zshrc"
        fi
    fi
fi

# — Cambiar shell a Zsh —
echo ""
if [ "$(basename "$SHELL")" != "zsh" ]; then
    if ask "¿Cambiar shell por defecto a Zsh?" y; then
        chsh -s zsh
        echo -e "  ${LIME}✓${NC} Shell cambiado a Zsh"
    fi
else
    echo -e "  ${GRAY}○ Zsh ya es tu shell por defecto${NC}"
fi

echo ""
echo -e "  ${LIME}✓ Tweaks de terminal aplicados.${NC}"
echo -e "  ${GRAY}Reinicia Termux para ver todos los cambios.${NC}"