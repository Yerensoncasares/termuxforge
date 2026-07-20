#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — IA Local (Ollama + modelo)
#  Corre en terminal dentro de XFCE4
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"

header "IA Local — Ollama"

RAM_GB=$(config_get RAM_GB)

# — Explicación —
echo -e "  ${WHITE}Ollama corre modelos de IA directamente en tu dispositivo.${NC}"
echo -e "  ${WHITE}No necesita internet después de descargar el modelo.${NC}"
echo -e "  ${WHITE}Se usa desde una terminal en XFCE4 con: ollama run <modelo>${NC}"
echo ""

# — Seleccionar modelo según RAM —
echo -e "${MINT}═══ Modelo de IA ═══${NC}"
echo -e "  ${GRAY}Modelos disponibles según tu RAM (${RAM_GB}GB):${NC}"
echo ""

if [ "$RAM_GB" -le 2 ]; then
    echo -e "  ${LIME}1)${NC} qwen2.5-coder:0.5b  ${GRAY}(~400 MB) — Muy básico${NC}"
    echo -e "  ${RED}2)${NC} Modelos mayores     ${GRAY}(no recomendados con tu RAM)${NC}"
    MODEL_OPTIONS=("qwen2.5-coder:0.5b")
    MODEL_SIZES=("400")
elif [ "$RAM_GB" -le 4 ]; then
    echo -e "  ${LIME}1)${NC} qwen2.5-coder:0.5b  ${GRAY}(~400 MB) — Rápido, básico${NC}"
    echo -e "  ${LIME}2)${NC} qwen2.5-coder:1.5b  ${GRAY}(~1 GB) — Recomendado${NC}"
    echo -e "  ${YELLOW}3)${NC} qwen2.5-coder:3b    ${GRAY}(~2 GB) — Más capaz, lento${NC}"
    MODEL_OPTIONS=("qwen2.5-coder:0.5b" "qwen2.5-coder:1.5b" "qwen2.5-coder:3b")
    MODEL_SIZES=("400" "1000" "2000")
elif [ "$RAM_GB" -le 8 ]; then
    echo -e "  ${LIME}1)${NC} qwen2.5-coder:1.5b  ${GRAY}(~1 GB) — Rápido${NC}"
    echo -e "  ${LIME}2)${NC} qwen2.5-coder:3b    ${GRAY}(~2 GB) — Recomendado${NC}"
    echo -e "  ${LIME}3)${NC} qwen2.5-coder:7b    ${GRAY}(~4.5 GB) — Más capaz${NC}"
    MODEL_OPTIONS=("qwen2.5-coder:1.5b" "qwen2.5-coder:3b" "qwen2.5-coder:7b")
    MODEL_SIZES=("1000" "2000" "4500")
else
    echo -e "  ${LIME}1)${NC} qwen2.5-coder:3b    ${GRAY}(~2 GB)${NC}"
    echo -e "  ${LIME}2)${NC} qwen2.5-coder:7b    ${GRAY}(~4.5 GB) — Recomendado${NC}"
    echo -e "  ${LIME}3)${NC} qwen2.5-coder:14b   ${GRAY}(~9 GB) — Máximo disponible${NC}"
    MODEL_OPTIONS=("qwen2.5-coder:3b" "qwen2.5-coder:7b" "qwen2.5-coder:14b")
    MODEL_SIZES=("2000" "4500" "9000")
fi

echo ""
mchoice=$(ask_number "Elige modelo" 1 "${#MODEL_OPTIONS[@]}")
mchoice=$((mchoice - 1))
SELECTED_MODEL="${MODEL_OPTIONS[$mchoice]}"
SELECTED_SIZE="${MODEL_SIZES[$mchoice]}MB"

echo ""
echo -e "  ${MINT}Modelo seleccionado: ${WHITE}${SELECTED_MODEL}${NC}"
echo -e "  ${MINT}Tamaño estimado:    ${WHITE}~${SELECTED_SIZE}${NC}"
echo ""

if [ "$RAM_GB" -le 3 ] && [ "$mchoice" -ge 1 ]; then
    ram_warning "${SELECTED_MODEL}" "${SELECTED_SIZE}" "$RAM_GB"
    if ! ask "¿Continuar de todos modos?" n; then
        echo -e "  ${GRAY}Cancelado.${NC}"
        exit 0
    fi
fi

if ! ask "¿Instalar Ollama + descargar ${SELECTED_MODEL}?" y; then
    echo -e "  ${GRAY}Cancelado.${NC}"
    exit 0
fi

# — Instalar Ollama —
echo ""
if command -v ollama >/dev/null 2>&1; then
    echo -e "  ${GRAY}○ Ollama ya instalado${NC}"
else
    install_pkg "ollama" "Ollama"
fi

# — Descargar modelo —
echo ""
echo -e "${MINT}Descargando modelo ${SELECTED_MODEL}...${NC}"
echo -e "  ${YELLOW}Esto puede tardar varios minutos según tu conexión.${NC}"
echo ""

# Arrancar servidor en background
pkill -f "ollama serve" 2>/dev/null
sleep 1
ollama serve > /dev/null 2>&1 &
SERVER_PID=$!
sleep 3

# Descargar modelo
if ollama pull "$SELECTED_MODEL" 2>&1; then
    echo ""
    echo -e "  ${LIME}✓${NC} Modelo descargado correctamente"
else
    echo ""
    echo -e "  ${RED}✗ Falló la descarga del modelo${NC}"
    kill "$SERVER_PID" 2>/dev/null
    exit 1
fi

# Detener servidor (se reiniciará al usar start-forge.sh)
kill "$SERVER_PID" 2>/dev/null
pkill -f "ollama" 2>/dev/null

echo ""
echo -e "  ${LIME}✓ IA Local configurada.${NC}"
echo -e "  ${GRAY}Para usarla, abre una terminal en XFCE4 y ejecuta:${NC}"
echo -e "  ${WHITE}  ollama run ${SELECTED_MODEL}${NC}"
echo -e "  ${GRAY}Ollama se iniciará automáticamente con el entorno.${NC}"