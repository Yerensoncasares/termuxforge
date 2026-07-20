#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════
#  TermuxForge — IA Local dentro de Arch
#  Ollama desde AUR
# ═══════════════════════════════════════════════

source "$HOME/scripts/lib/colors.sh"
source "$HOME/scripts/lib/detect.sh"
source "$HOME/scripts/container/proot_helper.sh"

header "IA Local — Ollama en Arch"

arch_check || exit 1

RAM_GB=$(config_get RAM_GB)

echo -e "  ${WHITE}Ollama en Arch se instala desde AUR (necesita paru/yay).${NC}"
echo -e "  ${WHITE}Alternativa: Se puede usar Ollama de Termux nativo.${NC}"
echo ""

echo -e "${MINT}═══ Método de instalación ═══${NC}"
echo -e "  ${LIME}1)${NC} Ollama en Termux nativo (más simple, recomendado)"
echo -e "  ${LIME}2)${NC} Ollama en Arch via AUR (más completo)"

choice=$(ask_number "Elige método" 1 2)

if [ "$choice" = "1" ]; then
    echo ""
    echo -e "  ${MINT}Usando Ollama de Termux nativo...${NC}"
    bash "$HOME/scripts/native/setup_ai.sh"
    exit $?
fi

# — Ollama en Arch via AUR —
echo ""
echo -e "${MINT}Instalando helper de AUR (paru)...${NC}"
arch_root "
    pacman -S --noconfirm base-devel git
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd / && rm -rf /tmp/paru
" 2>&1 | tail -5

echo ""
echo -e "${MINT}Instalando Ollama via AUR...${NC}"
arch_root "su - forge -c 'paru -S --noconfirm ollama'" 2>&1 | tail -5

# — Seleccionar modelo —
echo ""
echo -e "${MINT}═══ Modelo de IA ═══${NC}"
echo -e "  ${GRAY}RAM: ${RAM_GB}GB${NC}"
echo ""

if [ "$RAM_GB" -le 4 ]; then
    echo -e "  ${LIME}1)${NC} qwen2.5-coder:0.5b  ${GRAY}(~400MB)${NC}"
    echo -e "  ${LIME}2)${NC} qwen2.5-coder:1.5b  ${GRAY}(~1GB)${NC}"
    MODELS=("qwen2.5-coder:0.5b" "qwen2.5-coder:1.5b")
elif [ "$RAM_GB" -le 8 ]; then
    echo -e "  ${LIME}1)${NC} qwen2.5-coder:1.5b  ${GRAY}(~1GB)${NC}"
    echo -e "  ${LIME}2)${NC} qwen2.5-coder:3b    ${GRAY}(~2GB)${NC}"
    echo -e "  ${LIME}3)${NC} qwen2.5-coder:7b    ${GRAY}(~4.5GB)${NC}"
    MODELS=("qwen2.5-coder:1.5b" "qwen2.5-coder:3b" "qwen2.5-coder:7b")
else
    echo -e "  ${LIME}1)${NC} qwen2.5-coder:3b    ${GRAY}(~2GB)${NC}"
    echo -e "  ${LIME}2)${NC} qwen2.5-coder:7b    ${GRAY}(~4.5GB)${NC}"
    MODELS=("qwen2.5-coder:3b" "qwen2.5-coder:7b")
fi

mchoice=$(ask_number "Elige modelo" 1 "${#MODELS[@]}")
mchoice=$((mchoice - 1))
SELECTED="${MODELS[$mchoice]}"

echo ""
if ! ask "¿Descargar ${SELECTED}? Puede tardar minutos." y; then exit 0; fi

echo ""
echo -e "${MINT}Descargando modelo...${NC}"
arch_root "ollama serve > /dev/null 2>&1 &"
sleep 3
arch_root "ollama pull ${SELECTED}" 2>&1
arch_root "pkill -f ollama"

echo ""
echo -e "  ${LIME}✓ IA local configurada en Arch.${NC}"
echo -e "  ${GRAY}Usa: ollama run ${SELECTED}${NC}"