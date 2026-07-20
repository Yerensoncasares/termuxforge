<div align="center">

```
 ██████╗ ██████╗  █████╗ ███╗   ██╗██╗  ██╗███████╗
██╔════╝ ██╔══██╗██╔══██╗████╗  ██║██║ ██╔╝██╔════╝
██║  ███╗██████╔╝███████║██╔██╗ ██║█████╔╝ █████╗  
██║   ██║██╔══██╗██╔══██║██║╚██╗██║██╔═██╗ ██╔══╝  
╚██████╔╝██║  ██║██║  ██║██║ ╚████║██║  ██╗███████╗
 ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝
```

**Instalador modular de entorno Linux para Termux**

[![Architecture](https://img.shields.io/badge/arch-ARM64-green)]()
[![Termux](https://img.shields.io/badge/platform-Termux-blue)]()

</div>

---

## ¿Qué es TermuxForge?

TermuxForge transforma tu teléfono Android en un entorno de desarrollo Linux completo. No es una app, no requiere root, no flashlea nada. Es un script que instala y configura todo paso a paso, dejándote elegir exactamente qué necesitas.

## ¿Qué NO es?

- **No es una distribución Linux.** No reemplaza Android.
- **No requiere root.** Funciona en cualquier Android 7+ con Termux.
- **No instala nada sin preguntar.** Cada herramienta requiere confirmación.
- **No es un script monolítico.** Cada módulo es independiente.

---

## Dos caminos, tú eliges

### Camino 1: Termux Nativo

Todo corre directamente en Termux. Sin contenedores, sin capas extra, máximo rendimiento.

```
Termux → XFCE4 → Firefox → VS Code → Godot → GIMP
```

| Herramienta | Fuente | Notas |
|---|---|---|
| XFCE4 | repos oficiales Termux | Escritorio completo |
| Firefox | tur-repo | Navegador completo |
| VS Code (code-oss) | tur-repo | Editor con extensiones |
| Godot Engine | tur-repo | Compilado nativo para Termux |
| GIMP | tur-repo | Editor de imágenes |
| LibreSprite | tur-repo | Editor de pixel art |
| Audacity | tur-repo | Editor de audio |
| ImageMagick | repos oficiales | Manipulación de imágenes CLI |
| Node.js | repos oficiales | Runtime JavaScript |
| Python | repos oficiales | Runtime Python |
| Ollama | tur-repo | IA local (modelos qwen2.5-coder) |

### Camino 2: Termux + Arch Linux

Termux como anfitrión ligero + Arch Linux en contenedor proot. Más paquetes disponibles. VS Code y Godot corren en Termux nativo pero se acceden desde dentro de Arch para mejor integración.

```
Termux (host) → proot → Arch Linux → XFCE4 → Firefox → ...
                              ↑
                   VS Code + Godot (binarios de Termux)
```

| Herramienta | Notas |
|---|---|
| Firefox (repo Mozilla) | Siempre actualizado, con fix para proot |
| Geany | Editor ligero (~30MB RAM) |
| Node.js + Python | Dentro de Arch (independientes de Termux) |
| Ren'Py | Motor de visual novels |
| LÖVE (Love2D) | Motor de juegos 2D |
| Pygame | Desarrollo de juegos en Python |
| Raylib | Desarrollo de juegos en C/C++ |
| Panda3D | Motor 3D en Python |
| LibreOffice | Suite ofimática |
| Thunderbird | Cliente de correo |
| Nmap, Wireshark, Aircrack-ng | Ciberseguridad |
| John, Hydra, SQLMap, Hashcat | Pentesting |
| MPV, FFmpeg | Multimedia |

---

## Display: X11, VNC o Ambos

| Modo | Dónde se ve | Latencia | Requisito |
|---|---|---|---|
| **X11 Local** | Pantalla del teléfono | Cero | App Termux:X11 (F-Droid) |
| **VNC Remoto** | TV, PC, tablet por WiFi | Baja | Cualquier VNC Viewer |
| **Ambos** | Eliges al arrancar | — | Ambos anteriores |

Puedes cambiar de modo en cualquier momento sin reinstalar nada.

---

## Detección de hardware

Al ejecutar por primera vez, TermuxForge detecta:

- **RAM física** → Clasifica tu dispositivo en tiers (low/mid/high/ultra)
- **CPU núcleos** → Informa al usuario
- **Almacenamiento libre** → Verifica que haya al menos 2GB
- **Conexión a internet** — Requerida para descargar paquetes

Según tu RAM, el menú marca cada módulo:

```
RAM ≤ 3GB:  XFCE4 → ⚠️ Pesado | VS Code → ⚠️ Pesado | LibreOffice → ❌ No recomendado
RAM 4-6GB:  XFCE4 → ✅ | VS Code → ✅ | GIMP → ⚠️ Pesado | LibreOffice → ❌
RAM 8+ GB:  Todo → ✅
```

Los marcadores **no impiden** instalar nada. Solo son advertencias. Tú decides.

---

## Cada herramienta pregunta individualmente

No existe "instalar módulo = instalar todo". Ejemplo del módulo de juegos:

```
═══ Desarrollo de Juegos ═══

  ○ Ren'Py (Visual Novels)
  [?] ¿Instalar Ren'Py? [s/N]: n

  ○ LÖVE (Love2D)
  [?] ¿Instalar LÖVE? [s/N]: s

  ○ Pygame (Python)
  [?] ¿Instalar Pygame? [s/N]: s

  ○ Raylib (C/C++)
  [?] ¿Instalar Raylib? [s/N]: n

═══ Resumen ═══
  Instalar: LÖVE, Pygame
  Omitir: Ren'Py, Raylib
  ¿Correcto? [s/N]: s
```

---

## IA Local (Opcional)

Ollama ejecuta modelos de lenguaje directamente en tu dispositivo. Sin internet después de descargar. Se usa desde una terminal en XFCE4:

```bash
ollama run qwen2.5-coder:1.5b
```

El modelo se elige según tu RAM:

| RAM | Modelo recomendado | Tamaño |
|---|---|---|
| ≤ 2GB | qwen2.5-coder:0.5b | ~400MB |
| 3-4GB | qwen2.5-coder:1.5b | ~1GB |
| 5-8GB | qwen2.5-coder:3b | ~2GB |
| 9+ GB | qwen2.5-coder:7b | ~4.5GB |

---

## Requisitos

- Android 7.0 o superior
- [Termux](https://f-droid.org/packages/com.termux/) desde F-Droid (NO de Play Store)
- Conexión a internet para la instalación
- Mínimo 2GB de almacenamiento libre
- Mínimo 3GB de RAM para experiencia usable

**Opcional:**

- [Termux:X11](https://f-droid.org/packages/com.termux.x11/) (para modo X11 local)
- Un VNC Viewer cualquiera (para modo VNC remoto)

---

## Instalación

```bash
# 1. Clona el repositorio
git clone https://github.com/Yerensoncasares/termuxforge.git
cd termuxforge

# 2. Ejecuta el instalador
bash setup.sh

# 3. Sigue el menú interactivo
#    - Elige camino (Nativo o Arch)
#    - Elige display (X11, VNC, Ambos)
#    - Instala los módulos que quieras
#    - Cada herramienta pregunta individualmente

# 4. Inicia el entorno
bash scripts/start-forge.sh
```

---

## Estructura del proyecto

```
termuxforge/
├── setup.sh                    ← Punto de entrada (menú interactivo)
├── start-forge.sh              ← Iniciar entorno
├── stop-forge.sh               ← Detener entorno
├── switch-display.sh           ← Cambiar X11 ↔ VNC
├── README.md
│
├── scripts/
│   ├── lib/
│   │   ├── colors.sh           ← Colores, spinners, helpers de UI
│   │   ├── detect.sh           ← Detección de hardware y RAM
│   │   └── theming.sh          ← Lógica compartida de temas (dark/light)
│   │
│   ├── native/                  ← Camino 1: Todo en Termux
│   │   ├── install_base.sh     ← pkg update, repos, estructura
│   │   ├── setup_xfce.sh       ← XFCE4 nativo
│   │   ├── setup_vnc.sh        ← TigerVNC nativo
│   │   ├── setup_x11.sh        ← Termux:X11 nativo
│   │   ├── setup_nodepy.sh     ← Node.js + Python
│   │   ├── setup_dev.sh        ← VS Code + Godot (tur-repo)
│   │   ├── setup_art.sh        ← GIMP + Audacity + LibreSprite
│   │   ├── setup_theme.sh      ← Temas, iconos, fuentes, panel
│   │   ├── setup_ai.sh         ← Ollama + modelo de IA
│   │   └── termux_tweaks.sh    ← Zsh, OhMyZsh, fuente, colores
│   │
│   ├── container/               ← Camino 2: Termux + Arch
│   │   ├── proot_helper.sh     ← Funciones para operar dentro de Arch
│   │   ├── install_base.sh     ← Termux como host ligero
│   │   ├── install_proot.sh    ← Instalar Arch Linux (proot-distro)
│   │   ├── optimize_pacman.sh  ← Test de velocidad de mirrors
│   │   ├── setup_user.sh       ← Crear usuario "forge" en Arch
│   │   ├── setup_xfce.sh       ← XFCE4 dentro de Arch
│   │   ├── setup_vnc.sh        ← TigerVNC dentro de Arch
│   │   ├── setup_nodepy.sh     ← Node.js + Python en Termux
│   │   ├── setup_dev.sh        ← .desktop que apuntan a binarios de Termux
│   │   ├── setup_webdev.sh     ← Firefox, Node, Python, Geany en Arch
│   │   ├── setup_gamedev.sh    ← Ren'Py, LÖVE, Pygame, Raylib
│   │   ├── setup_art.sh        ← GIMP, Audacity en Arch
│   │   ├── setup_media.sh      ← MPV, FFmpeg en Arch
│   │   ├── setup_office.sh     ← LibreOffice, Thunderbird en Arch
│   │   ├── setup_cybersec.sh   ← Nmap, Wireshark, Metasploit en Arch
│   │   ├── setup_theme.sh      ← Temas completos en Arch
│   │   ├── setup_ai.sh         ← Ollama en Arch (AUR o Termux)
│   │   └── termux_tweaks.sh    ← Reutiliza tweaks del lado nativo
│   │
│   └── utils/
│       └── setup_controls.sh   ← Genera start/stop/switch + .desktop
```

---

## Tematización (Opcional)

Si eliges personalizar, se instala:

- **Tema:** Space (dark o light) desde [FluxLinux assets](https://github.com/abhay-byte/fluxlinux/releases)
- **Iconos:** Papirus (dark o light)
- **Cursor:** Vimix
- **Fuente:** JetBrains Mono Nerd Font
- **Panel:** XFCE4 personalizado con reloj, lanzador, systray
- **Terminal:** Fondo transparente, cursor IBEAM, fuente Nerd
- **Atajos de teclado:** Ctrl+T (terminal), Ctrl+E (archivos), Ctrl+B (navegador)

---

## Control del entorno

```bash
scripts/start-forge.sh      # Iniciar (pregunta modo si es "Ambos")
scripts/stop-forge.sh       # Detener todo (graceful: TERM → KILL)
scripts/switch-display.sh   # Cambiar X11/VNC sin reiniciar
```

---

## Seguridad y transparencia

- El script **no envía datos** a ningún servidor. Todo se descarga de repositorios oficiales (Termux, Arch Linux, Mozilla, GitHub releases).
- Cada comando de instalación es visible en la terminal.
- Puedes leer cualquier script antes de ejecutarlo.
- No se modifican archivos del sistema Android.
- Todo se instala dentro del sandbox de Termux (`/data/data/com.termux/`).

---

## Problemas conocidos

| Problema | Solución |
|---|---|
| Firefox se cierra al abrir en Arch | Ya incluye fix (`MOZ_DISABLE_*_SANDBOX`). Si persiste, usa Firefox de Termux nativo. |
| VS Code no carga extensiones | Ya configurado `extensions.verifySignature: false`. |
| VNC muestra pantalla negra | LLVMpipe está configurado por defecto. Si instalaste aceleración GPU, puede haber conflicto. |
| Ollama no responde | Asegúrate de que `ollama serve` esté corriendo. Usa `scripts/start-forge.sh`. |
| Arch se siente lento | proot tiene overhead inherente. En dispositivos con 3GB RAM o menos, el camino Nativo es mejor. |
| PulseAudio no funciona | Ejecuta `pulseaudio --start --exit-idle-time=-1` manualmente. |
| `.gitkeep` aparece en el repo | Es un archivo vacío necesario para que Git rastree carpetas vacías. No afecta la ejecución. |

---

## Licencia

MIT — Usa, modifica, distribuye. Atribución apreciada pero no requerida.

---

## Créditos

- Temas, iconos y cursores: [FluxLinux](https://github.com/abhay-byte/fluxlinux) por Abhay Byte
- Fuente: [JetBrains Mono Nerd Font](https://github.com/ryanoasis/nerd-fonts) por Ryan L McIntosh
- Conceptos de aceleración GPU: [termux-desktop](https://github.com/termux/termux-desktop) y [lfdevs/mesa-for-android-container](https://github.com/lfdevs/mesa-for-android-container)
- Conceptos de empaquetado ARM64: [FluxLinux AppDev scripts](https://github.com/abhay-byte/fluxlinux)

---
