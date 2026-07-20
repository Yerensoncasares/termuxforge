#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — XFCE4 Nativo (Termux)
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"

header "Escritorio XFCE4 — Termux Nativo"

RAM_GB=$(config_get RAM_GB)

# Advertencia para dispositivos con poca RAM
if [ "$RAM_GB" -le 2 ]; then
    echo -e "  ${RED}⚠ Tu dispositivo tiene ${RAM_GB}GB RAM.${NC}"
    echo -e "  ${RED}  XFCE4 necesita al menos 200-300MB solo para arrancar.${NC}"
    echo -e "  ${RED}  Puede ser inusable. ¿Continuar de todos modos?${NC}"
    if ! ask "" n; then
        echo -e "  ${GRAY}Cancelado.${NC}"
        exit 0
    fi
elif [ "$RAM_GB" -le 3 ]; then
    ram_warning "XFCE4" "300" "$RAM_GB"
    if ! ask "¿Continuar?" n; then
        echo -e "  ${GRAY}Cancelado.${NC}"
        exit 0
    fi
fi

TO_INSTALL=""
TO_SKIP=""

# Lista de paquetes con descripción
XFCE_ITEMS=(
    "xfce4:Escritorio XFCE4"
    "xfce4-terminal:Terminal XFCE4"
    "thunar:Gestor de archivos Thunar"
    "mousepad:Editor de textos Mousepad"
    "ristretto:Visor de imágenes Ristretto"
    "xfce4-taskmanager:Administrador de tareas"
    "tumbler:Miniaturas de Thunar"
)

for item in "${XFCE_ITEMS[@]}"; do
    pkg="${item%%:*}"
    desc="${item##*:}"

    if pkg list-installed 2>/dev/null | grep -q "^$pkg/"; then
        echo -e "  ${GRAY}○ ${desc} ya instalado${NC}"
        TO_INSTALL="${TO_INSTALL}${desc} "
    else
        if ask "¿Instalar ${desc}?" y; then
            TO_INSTALL="${TO_INSTALL}${desc} "
        else
            TO_SKIP="${TO_SKIP}${desc} "
        fi
    fi
    echo ""
done

# — Resumen —
summary "XFCE4" "$TO_INSTALL" "$TO_SKIP"

if [ -z "$TO_INSTALL" ]; then
    echo -e "  ${GRAY}Nada que instalar.${NC}"
    exit 0
fi

if ! ask "¿Proceder?" y; then
    echo -e "  ${GRAY}Cancelado.${NC}"
    exit 0
fi

# — Instalar —
echo ""
ERRORS=0
for item in "${XFCE_ITEMS[@]}"; do
    pkg="${item%%:*}"
    desc="${item##*:}"

    if echo "$TO_INSTALL" | grep -q "$desc"; then
        if ! pkg list-installed 2>/dev/null | grep -q "^$pkg/"; then
            install_pkg "$pkg" "$desc"
            pkg list-installed 2>/dev/null | grep -q "^$pkg/" || ERRORS=$((ERRORS + 1))
        fi
    fi
done

# — Configuración mínima: compositor OFF por defecto —
CONF_DIR="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
mkdir -p "$CONF_DIR"
if [ ! -f "$CONF_DIR/xfwm4.xml" ]; then
    cat > "$CONF_DIR/xfwm4.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="use_compositing" type="bool" value="false"/>
  </property>
</channel>
EOF
fi

# — Verificación —
echo ""
echo -e "${MINT}Verificación:${NC}"
for cmd in xfce4-session xfce4-terminal thunar mousepad; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "  ${LIME}✓${NC} ${cmd}"
    else
        echo -e "  ${RED}✗${NC} ${cmd} faltante"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""
if [ "$ERRORS" -eq 0 ]; then
    echo -e "  ${LIME}✓ XFCE4 instalado correctamente.${NC}"
    echo -e "  ${GRAY}Ahora configura el display (X11 o VNC) para usarlo.${NC}"
    exit 0
else
    echo -e "  ${RED}✗ Algunos componentes fallaron.${NC}"
    exit 1
fi