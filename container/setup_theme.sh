#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — Temas dentro de Arch
#  Descarga en Termux, copia a Arch, escribe XMLs
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"
source "$HOME/scripts/lib/theming.sh"
source "$HOME/scripts/container/proot_helper.sh"

header "Temas, Iconos, Fuentes — Dentro de Arch"

arch_check || exit 1

echo -e "  ${GRAY}Se descargarán ~150MB de assets.${NC}"
if ! ask "¿Continuar?" y; then exit 0; fi

# — Rutas de Arch —
theme_set_paths "container"

# — Preguntar dark/light —
theme_ask_mode

# — Descargar a /tmp de Termux —
echo ""
echo -e "${MINT}Descargando assets...${NC}"
DL_DIR="/tmp/forge-theme-assets-$$"
mkdir -p "$DL_DIR"/{themes,icons,fonts,wallpapers}

# Descargar y extraer en tmp
curl -fL "$BASE_URL/theme.zip" -o "$DL_DIR/theme.zip" 2>/dev/null && \
    unzip -q -o "$DL_DIR/theme.zip" -d "$DL_DIR/themes" 2>/dev/null

curl -fL "$BASE_URL/icons.zip" -o "$DL_DIR/icons.zip" 2>/dev/null && \
    unzip -q -o "$DL_DIR/icons.zip" -d "$DL_DIR/icons" 2>/dev/null

curl -fL "$BASE_URL/cursor.zip" -o "$DL_DIR/cursor.zip" 2>/dev/null && \
    unzip -q -o "$DL_DIR/cursor.zip" -d "$DL_DIR/icons" 2>/dev/null

curl -fL "$BASE_URL/wallpaper.zip" -o "$DL_DIR/wallpaper.zip" 2>/dev/null && \
    unzip -q -o -j "$DL_DIR/wallpaper.zip" -d "$DL_DIR/wallpapers" 2>/dev/null

[ -f "$DL_DIR/wallpapers/dark.png" ]  && mv "$DL_DIR/wallpapers/dark.png"  "$DL_DIR/wallpapers/fluxlinux-dark.png"
[ -f "$DL_DIR/wallpapers/light.png" ] && mv "$DL_DIR/wallpapers/light.png" "$DL_DIR/wallpapers/fluxlinux-light.png"

# Fuente
curl -fL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
    -o "$DL_DIR/font.zip" 2>/dev/null && \
    mkdir -p "$DL_DIR/fonts" && \
    unzip -q -o -j "$DL_DIR/font.zip" "*.ttf" -d "$DL_DIR/fonts" 2>/dev/null

# — Copiar a Arch —
echo ""
echo -e "${MINT}Copiando assets a Arch...${NC}"

arch_root "mkdir -p $THEME_DIR $ICON_DIR $FONT_DIR $WALL_DIR"

cp -r "$DL_DIR/themes/"* "$DL_DIR/themes/." 2>/dev/null
arch_copy "$DL_DIR/themes" "$THEME_DIR"
# Si la copia de directorio no funciona bien, copiar contenido
for d in "$DL_DIR/themes"/*/; do
    dirname=$(basename "$d")
    arch_root "mkdir -p '$THEME_DIR/$dirname'"
    cp -r "$d"* "$DL_DIR/$dirname/" 2>/dev/null
    arch_copy "$DL_DIR/$dirname" "$THEME_DIR/$dirname"
done

for d in "$DL_DIR/icons/"*; do
    if [ -d "$d" ]; then
        dirname=$(basename "$d")
        arch_root "mkdir -p '$ICON_DIR/$dirname'"
        arch_copy "$d" "$ICON_DIR/$dirname"
    fi
done

arch_copy "$DL_DIR/fonts" "$FONT_DIR"
arch_copy "$DL_DIR/wallpapers" "$WALL_DIR"
arch_root "chown -R forge:users $THEME_DIR $ICON_DIR $FONT_DIR $WALL_DIR"

# Font cache
arch_root "fc-cache -fv $FONT_DIR >/dev/null 2>&1"

# Limpiar tmp
rm -rf "$DL_DIR"

# — Escribir XMLs dentro de Arch —
echo ""
echo -e "${MINT}Escribiendo configuración XFCE4...${NC}"

# Exportar variables de tema para el heredoc
export SEL_THEME SEL_ICON SEL_CURSOR SEL_WALL
export THEME_DIR ICON_DIR FONT_DIR WALL_DIR CONF_DIR GTK_DIR GTK4_DIR TERM_DIR

arch_root "mkdir -p $CONF_DIR $GTK_DIR $GTK4_DIR $TERM_DIR"

# xsettings.xml
arch_write "$CONF_DIR/xsettings.xml" << XSEOF
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
</channel>
XSEOF

# GTK
arch_write "$GTK_DIR/settings.ini" << GTKEOF
[Settings]
gtk-theme-name=$SEL_THEME
gtk-icon-theme-name=$SEL_ICON
gtk-font-name=JetBrainsMono Nerd Font 10
gtk-cursor-theme-name=$SEL_CURSOR
gtk-cursor-theme-size=52
gtk-application-prefer-dark-theme=1
GTKEOF
arch_root "cp $GTK_DIR/settings.ini $GTK4_DIR/settings.ini 2>/dev/null"

# xfwm4.xml
arch_write "$CONF_DIR/xfwm4.xml" << XFWEOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="$SEL_THEME"/>
    <property name="title_font" type="string" value="JetBrainsMono Nerd Font Bold 10"/>
    <property name="button_layout" type="string" value="O|HMC"/>
    <property name="use_compositing" type="bool" value="false"/>
    <property name="tile_on_move" type="bool" value="true"/>
    <property name="wrap_windows" type="bool" value="true"/>
    <property name="snap_to_border" type="bool" value="true"/>
    <property name="snap_to_windows" type="bool" value="true"/>
  </property>
</channel>
XFWEOF

# xfce4-desktop.xml (wallpaper)
WP_PATH="$WALL_DIR/$SEL_WALL"
MONS="monitor0 monitor1 monitorVNC-0 monitorbuiltin builtin monitorHDMI-A-0 monitorVirtual-0 monitorVirtual1"
MON_PROPS=""
for m in $MONS; do
    MON_PROPS="$MON_PROPS
    <property name=\"$m\" type=\"empty\">
      <property name=\"workspace0\" type=\"empty\">
        <property name=\"last-image\" type=\"string\" value=\"$WP_PATH\"/>
        <property name=\"image-style\" type=\"int\" value=\"5\"/>
      </property>
    </property>"
done

arch_write "$CONF_DIR/xfce4-desktop.xml" << DSKEOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">$MON_PROPS
    </property>
  </property>
  <property name="desktop-icons" type="empty">
    <property name="style" type="int" value="2"/>
    <property name="file-icons" type="empty">
      <property name="show-home" type="bool" value="true"/>
      <property name="show-trash" type="bool" value="true"/>
    </property>
  </property>
</channel>
DSKEOF

# Terminal config
arch_write "$TERM_DIR/terminalrc" << TERMEOF
[Configuration]
FontUseSystem=FALSE
FontName=JetBrainsMono Nerd Font 12
MiscCursorShape=TERMINAL_CURSOR_SHAPE_IBEAM
MiscMenubarDefault=FALSE
MiscToolbarDefault=FALSE
BackgroundMode=TERMINAL_BACKGROUND_TRANSPARENT
BackgroundDarkness=0.7
ScrollingLines=1000
TERMEOF

# Permisos
arch_root "chown -R forge:users /home/forge/.config"

echo ""
echo -e "  ${LIME}✓ Tematización completada en Arch.${NC}"
echo -e "  ${GRAY}Tema: ${SEL_THEME} | Iconos: ${SEL_ICON}${NC}"