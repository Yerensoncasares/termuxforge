#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Shared Theming Library
#  Descarga temas, iconos, fuentes, escribe XMLs
#  Se usa desde native/setup_theme.sh y
#  container/setup_theme.sh con TARGET=native|container
# ═══════════════════════════════════════════════

# Assets de FluxLinux (Space theme, Papirus, Vimix, JetBrains)
ASSET_REPO="abhay-byte/fluxlinux"
ASSET_TAG="debian-v1"
BASE_URL="https://github.com/$ASSET_REPO/releases/download/$ASSET_TAG"

# — Rutas según contexto —
# Si TARGET=container, se ejecuta DENTRO de proot
theme_set_paths() {
    local target="${1:-native}"
    case "$target" in
        container)
            THEME_DIR="/usr/share/themes"
            ICON_DIR="/usr/share/icons"
            FONT_DIR="/usr/share/fonts/truetype/jetbrains-mono-nerd"
            WALL_DIR="/home/forge/Pictures/Wallpapers"
            CONF_DIR="/home/forge/.config/xfce4/xfconf/xfce-perchannel-xml"
            GTK_DIR="/home/forge/.config/gtk-3.0"
            GTK4_DIR="/home/forge/.config/gtk-4.0"
            TERM_DIR="/home/forge/.config/xfce4/terminal"
            PANEL_DIR="/home/forge/.config/xfce4/panel"
            USER_HOME="/home/forge"
            FONT_CMD="fc-cache -fv"
            OWNER_CMD="chown -R forge:users"
            ;;
        *)
            THEME_DIR="$HOME/.themes"
            ICON_DIR="$HOME/.icons"
            FONT_DIR="$HOME/.fonts/JetBrainsMonoNerd"
            WALL_DIR="$HOME/Pictures/Wallpapers"
            CONF_DIR="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
            GTK_DIR="$HOME/.config/gtk-3.0"
            GTK4_DIR="$HOME/.config/gtk-4.0"
            TERM_DIR="$HOME/.config/xfce4/terminal"
            PANEL_DIR="$HOME/.config/xfce4/panel"
            USER_HOME="$HOME"
            FONT_CMD="fc-cache -fv $HOME/.fonts"
            OWNER_CMD="true"
            ;;
    esac
}

# — Descargar y extraer assets —
theme_download_extract() {
    local url="$1"
    local dest="$2"
    local name="${3:-$(basename "$url")}"
    local tmp="/tmp/forge-theme-$$"

    echo -e "  ${YELLOW}↓${NC} Descargando ${name}..."
    if command -v curl >/dev/null 2>&1; then
        curl -fL "$url" -o "$tmp" 2>/dev/null
    else
        wget -q "$url" -O "$tmp" 2>/dev/null
    fi

    if [ ! -f "$tmp" ] || [ ! -s "$tmp" ]; then
        echo -e "  ${RED}✗ Falló la descarga de ${name}${NC}"
        rm -f "$tmp"
        return 1
    fi

    mkdir -p "$dest"
    unzip -q -o "$tmp" -d "$dest" 2>/dev/null

    # Extraer tarballs anidados
    find "$dest" -maxdepth 1 -name "*.tar.xz" -exec tar -xf {} -C "$dest" \; 2>/dev/null
    find "$dest" -maxdepth 1 -name "*.tar.gz" -exec tar -xzf {} -C "$dest" \; 2>/dev/null
    rm -f "$dest"/*.tar.xz "$dest"/*.tar.gz 2>/dev/null
    rm -f "$tmp"

    # Si extrajo un solo subdirectorio, promover su contenido
    local top_files top_dirs inner_dir
    top_files=$(find "$dest" -maxdepth 1 -not -type d | wc -l)
    top_dirs=$(find "$dest" -maxdepth 1 -type d | wc -l)
    if [ "$top_files" -eq 0 ] && [ "$top_dirs" -eq 2 ]; then
        inner_dir=$(find "$dest" -maxdepth 1 -type d ! -path "$dest" | head -1)
        shopt -s dotglob nullglob
        for f in "$inner_dir"/*; do
            mv "$f" "$dest/" 2>/dev/null
        done
        shopt -u dotglob nullglob
        rmdir "$inner_dir" 2>/dev/null
    fi

    echo -e "  ${LIME}✓${NC} ${name} extraído en ${dest}"
    return 0
}

# — Selector de modo dark/light —
theme_ask_mode() {
    echo ""
    echo -e "${MINT}¿Qué estilo de tema prefieres?${NC}"
    echo -e "  ${LIME}1)${NC} ${WHITE}Dark (por defecto)${NC}"
    echo -e "  ${LIME}2)${NC} ${WHITE}Light${NC}"
    echo ""

    local choice
    choice=$(ask_number "Elige" 1 2)

    if [ "$choice" = "2" ]; then
        SEL_THEME="Space-light"
        SEL_ICON="Papirus"
        SEL_CURSOR="Vimix-cursors"
        SEL_WALL="fluxlinux-light.png"
    else
        SEL_THEME="Space-transparency"
        SEL_ICON="Papirus-Dark"
        SEL_CURSOR="Vimix-white-cursors"
        SEL_WALL="fluxlinux-dark.png"
    fi
}

# — Instalar temas, iconos, cursores —
theme_install_assets() {
    echo ""
    echo -e "${MINT}═══ Temas e Iconos ═══${NC}"
    mkdir -p "$THEME_DIR" "$ICON_DIR"
    theme_download_extract "$BASE_URL/theme.zip" "$THEME_DIR" "Tema Space"
    theme_download_extract "$BASE_URL/icons.zip"  "$ICON_DIR" "Iconos Papirus"
    theme_download_extract "$BASE_URL/cursor.zip" "$ICON_DIR" "Cursores Vimix"
}

# — Instalar wallpaper —
theme_install_wallpaper() {
    echo ""
    echo -e "${MINT}═══ Wallpaper ═══${NC}"
    mkdir -p "$WALL_DIR"
    local tmp="/tmp/forge-wp-$$"
    curl -fL "$BASE_URL/wallpaper.zip" -o "$tmp" 2>/dev/null || \
        wget -q "$BASE_URL/wallpaper.zip" -O "$tmp" 2>/dev/null
    unzip -q -o -j "$tmp" -d "$WALL_DIR" 2>/dev/null
    rm -f "$tmp"
    [ -f "$WALL_DIR/dark.png" ]  && mv "$WALL_DIR/dark.png"  "$WALL_DIR/fluxlinux-dark.png"
    [ -f "$WALL_DIR/light.png" ] && mv "$WALL_DIR/light.png" "$WALL_DIR/fluxlinux-light.png"
    $OWNER_CMD "$WALL_DIR" 2>/dev/null
    echo -e "  ${LIME}✓${NC} Wallpaper instalado"
}

# — Instalar fuente JetBrains Mono Nerd —
theme_install_font() {
    echo ""
    echo -e "${MINT}═══ Fuente JetBrains Mono Nerd ═══${NC}"

    if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd"; then
        echo -e "  ${GRAY}○ Fuente ya instalada${NC}"
        return 0
    fi

    mkdir -p "$FONT_DIR"
    local tmp="/tmp/forge-font-$$"
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

    echo -e "  ${YELLOW}↓${NC} Descargando fuente..."
    curl -fL "$font_url" -o "$tmp" 2>/dev/null || \
        wget -q "$font_url" -o "$tmp" 2>/dev/null

    if [ ! -f "$tmp" ] || [ ! -s "$tmp" ]; then
        echo -e "  ${RED}✗ Falló la descarga de la fuente${NC}"
        rm -f "$tmp"
        return 1
    fi

    unzip -q -o -j "$tmp" "*.ttf" -d "$FONT_DIR" 2>/dev/null
    rm -f "$tmp"
    find "$FONT_DIR" -type f ! -name "*.ttf" ! -name "*.otf" -delete 2>/dev/null
    chmod 644 "$FONT_DIR"/*.ttf 2>/dev/null

    echo -e "  ${YELLOW}↓${NC} Reconstruyendo caché de fuentes..."
    $FONT_CMD >/dev/null 2>&1
    $OWNER_CMD "$FONT_DIR" 2>/dev/null

    if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd"; then
        echo -e "  ${LIME}✓${NC} Fuente instalada correctamente"
    else
        echo -e "  ${YELLOW}⚠ La fuente se extrajo pero puede no registrarse hasta reiniciar${NC}"
    fi
}

# — Escribir xsettings.xml —
theme_write_xsettings() {
    mkdir -p "$CONF_DIR" "$GTK_DIR" "$GTK4_DIR"
    cat > "$CONF_DIR/xsettings.xml" << XSEOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="$SEL_THEME"/>
    <property name="IconThemeName" type="string" value="$SEL_ICON"/>
    <property name="EnableEventSounds" type="bool" value="false"/>
    <property name="EnableInputFeedbackSounds" type="bool" value="false"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="CursorThemeName" type="string" value="$SEL_CURSOR"/>
    <property name="CursorThemeSize" type="int" value="52"/>
    <property name="FontName" type="string" value="JetBrainsMono Nerd Font 10"/>
    <property name="MonospaceFontName" type="string" value="JetBrainsMono Nerd Font Mono 10"/>
    <property name="DecorationLayout" type="string" value="menu:minimize,maximize,close"/>
  </property>
  <property name="Gdk" type="empty">
    <property name="WindowScalingFactor" type="int" value="2"/>
  </property>
  <property name="Xft" type="empty">
    <property name="Antialias" type="int" value="1"/>
    <property name="HintStyle" type="string" value="hintslight"/>
    <property name="RGBA" type="string" value="rgb"/>
  </property>
</channel>
XSEOF

    # GTK 3 y 4
    cat > "$GTK_DIR/settings.ini" << GTKEOF
[Settings]
gtk-theme-name=$SEL_THEME
gtk-icon-theme-name=$SEL_ICON
gtk-font-name=JetBrainsMono Nerd Font 10
gtk-cursor-theme-name=$SEL_CURSOR
gtk-cursor-theme-size=52
gtk-application-prefer-dark-theme=1
GTKEOF
    cp "$GTK_DIR/settings.ini" "$GTK4_DIR/settings.ini" 2>/dev/null
    $OWNER_CMD "$CONF_DIR" "$GTK_DIR" "$GTK4_DIR" 2>/dev/null
}

# — Escribir xfwm4.xml (compositor OFF) —
theme_write_xfwm4() {
    mkdir -p "$CONF_DIR"
    cat > "$CONF_DIR/xfwm4.xml" << XFWEOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="$SEL_THEME"/>
    <property name="title_font" type="string" value="JetBrainsMono Nerd Font Bold 10"/>
    <property name="button_layout" type="string" value="O|HMC"/>
    <property name="placement_ratio" type="int" value="20"/>
    <property name="scroll_workspaces" type="bool" value="false"/>
    <property name="show_dock_shadow" type="bool" value="true"/>
    <property name="show_frame_shadow" type="bool" value="true"/>
    <property name="snap_to_border" type="bool" value="true"/>
    <property name="snap_to_windows" type="bool" value="true"/>
    <property name="use_compositing" type="bool" value="false"/>
    <property name="tile_on_move" type="bool" value="true"/>
    <property name="wrap_windows" type="bool" value="true"/>
  </property>
</channel>
XFWEOF
    $OWNER_CMD "$CONF_DIR" 2>/dev/null
}

# — Escribir xfce4-desktop.xml (wallpaper multi-monitor) —
theme_write_desktop() {
    mkdir -p "$CONF_DIR"
    local wp_path="$WALL_DIR/$SEL_WALL"
    local monitors="monitor0 monitor1 monitorVNC-0 monitorbuiltin builtin monitorHDMI-A-0 monitorVirtual-0 monitorVirtual1"
    local mon_props=""

    for m in $monitors; do
        mon_props="$mon_props
    <property name=\"$m\" type=\"empty\">
      <property name=\"workspace0\" type=\"empty\">
        <property name=\"last-image\" type=\"string\" value=\"$wp_path\"/>
        <property name=\"image-style\" type=\"int\" value=\"5\"/>
        <property name=\"color-style\" type=\"int\" value=\"0\"/>
      </property>
    </property>"
    done

    cat > "$CONF_DIR/xfce4-desktop.xml" << DSKEOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">$mon_props
    </property>
  </property>
  <property name="desktop-icons" type="empty">
    <property name="style" type="int" value="2"/>
    <property name="file-icons" type="empty">
      <property name="show-home" type="bool" value="true"/>
      <property name="show-filesystem" type="bool" value="false"/>
      <property name="show-trash" type="bool" value="true"/>
      <property name="show-removable" type="bool" value="true"/>
    </property>
  </property>
</channel>
DSKEOF
    $OWNER_CMD "$CONF_DIR" 2>/dev/null
}

# — Escribir xfce4-panel.xml —
theme_write_panel() {
    mkdir -p "$CONF_DIR"
    cat > "$CONF_DIR/xfce4-panel.xml" << PANELEOF
<?xml version="1.1" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="dark-mode" type="bool" value="true"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=6;x=0;y=0"/>
      <property name="length" type="double" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="icon-size" type="uint" value="16"/>
      <property name="size" type="uint" value="25"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
        <value type="int" value="6"/>
        <value type="int" value="7"/>
        <value type="int" value="8"/>
        <value type="int" value="9"/>
        <value type="int" value="10"/>
        <value type="int" value="11"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="applicationsmenu">
      <property name="button-title" type="string" value="Menu"/>
      <property name="button-icon" type="string" value="open-menu"/>
      <property name="small" type="bool" value="true"/>
      <property name="show-tooltips" type="bool" value="false"/>
      <property name="show-generic-names" type="bool" value="false"/>
      <property name="show-menu-icons" type="bool" value="true"/>
      <property name="show-button-title" type="bool" value="false"/>
    </property>
    <property name="plugin-2" type="string" value="tasklist">
      <property name="grouping" type="uint" value="1"/>
      <property name="flat-buttons" type="bool" value="false"/>
      <property name="show-only-minimized" type="bool" value="false"/>
      <property name="include-all-workspaces" type="bool" value="false"/>
      <property name="show-wireframes" type="bool" value="false"/>
      <property name="show-labels" type="bool" value="false"/>
    </property>
    <property name="plugin-3" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-4" type="string" value="systray"/>
    <property name="plugin-5" type="string" value="separator">
      <property name="style" type="uint" value="2"/>
    </property>
    <property name="plugin-6" type="string" value="clock">
      <property name="digital-layout" type="uint" value="1"/>
      <property name="mode" type="uint" value="4"/>
      <property name="show-seconds" type="bool" value="true"/>
      <property name="show-inactive" type="bool" value="false"/>
    </property>
    <property name="plugin-7" type="string" value="separator">
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-8" type="string" value="actions">
      <property name="items" type="array">
        <value type="string" value="+lock-screen"/>
        <value type="string" value="+logout"/>
        <value type="string" value="+separator"/>
        <value type="string" value="+shutdown"/>
      </property>
    </property>
    <property name="plugin-9" type="string" value="separator">
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-10" type="string" value="pager">
      <property name="rows" type="uint" value="1"/>
    </property>
    <property name="plugin-11" type="string" value="windowmenu"/>
  </property>
</channel>
PANELEOF
    $OWNER_CMD "$CONF_DIR" 2>/dev/null
}

# — Configurar terminal XFCE4 —
theme_write_terminal() {
    mkdir -p "$TERM_DIR"
    cat > "$TERM_DIR/terminalrc" << TERMEOF
[Configuration]
FontUseSystem=FALSE
FontName=JetBrainsMono Nerd Font 12
MiscAlwaysShowTabs=FALSE
MiscBell=FALSE
MiscBordersDefault=TRUE
MiscCursorBlinks=FALSE
MiscCursorShape=TERMINAL_CURSOR_SHAPE_IBEAM
MiscDefaultGeometry=80x24
MiscInheritGeometry=FALSE
MiscMenubarDefault=FALSE
MiscMouseAutohide=FALSE
MiscToolbarDefault=FALSE
MiscConfirmClose=TRUE
MiscCycleTabs=TRUE
MiscTabCloseButtons=TRUE
MiscTabCloseMiddleClick=TRUE
MiscTabPosition=TERMINAL_TAB_POSITION_TOP
MiscHighlightUrls=TRUE
MiscScrollAlternateScreen=TRUE
ScrollingLines=1000
BackgroundMode=TERMINAL_BACKGROUND_TRANSPARENT
BackgroundDarkness=0.7
TERMEOF
    $OWNER_CMD "$TERM_DIR" 2>/dev/null
}

# — Escribir todo de golpe —
theme_apply_all() {
    theme_write_xsettings
    theme_write_xfwm4
    theme_write_desktop
    theme_write_panel
    theme_write_terminal
}