#!/bin/bash
# 05-display.sh - Configura display virtual X11 headless para GPU NVIDIA
set -e

log() { echo "[05-display] $*"; }
error() { echo "[05-display] ERROR: $*" >&2; exit 1; }

RESOLUTION="${DISPLAY_RES:-1920x1080}"
REFRESH="${DISPLAY_REFRESH:-60}"

# Parsear resolucion
WIDTH="${RESOLUTION%x*}"
HEIGHT="${RESOLUTION#*x}"

log "Configurando display virtual: ${WIDTH}x${HEIGHT} @ ${REFRESH}Hz"

# Detectar GPU
detect_gpu() {
    if command -v nvidia-smi &>/dev/null; then
        echo "nvidia"
    elif lsmod 2>/dev/null | grep -q "amdgpu"; then
        echo "amd"
    else
        echo "dummy"
    fi
}

GPU_TYPE=$(detect_gpu)
log "GPU detectada: $GPU_TYPE"

case "$GPU_TYPE" in
    nvidia)
        log "Configurando NVIDIA Tesla T4..."
        # Configurar NVIDIA para display virtual
        nvidia-xconfig --allow-empty-initial-configuration --enable-all-gpus \
            --busid "$(nvidia-xconfig --query-gpu-info 2>/dev/null | grep -i "busid" | head -1 | awk '{print $NF}')" \
            --virtual="${WIDTH}x${HEIGHT}" \
            --depth=24 2>/dev/null || true
        
        # Iniciar Xorg virtual
        Xorg :0 -config /etc/X11/xorg.conf 2>/dev/null &
        ;;
    amd)
        log "Configurando GPU AMD..."
        cat > /tmp/xorg-amd.conf << EOF
Section "Device"
    Identifier  "AMD"
    Driver      "amdgpu"
EndSection
Section "Screen"
    Identifier  "Screen0"
    Device      "AMD"
    SubSection  "Display"
        Modes   "${RESOLUTION}"
    EndSubSection
EndSection
EOF
        Xorg :0 -config /tmp/xorg-amd.conf 2>/dev/null &
        ;;
    dummy)
        log "Usando display dummy (sin GPU fisica)..."
        cat > /tmp/xorg-dummy.conf << EOF
Section "Device"
    Identifier  "Dummy"
    Driver      "dummy"
    VideoRam    256000
EndSection
Section "Screen"
    Identifier  "Screen0"
    Device      "Dummy"
    Monitor     "Monitor0"
    SubSection  "Display"
        Modes   "${RESOLUTION}"
        Depth   24
    EndSubSection
EndSection
Section "Monitor"
    Identifier  "Monitor0"
    Modeline    "${RESOLUTION}_${REFRESH}" $(cvt "$WIDTH" "$HEIGHT" "$REFRESH" 2>/dev/null | grep "Modeline" | awk '{for(i=3;i<=NF;i++) printf "%s ", $i}') 
    Option      "PreferredMode" "${RESOLUTION}"
EndSection
EOF
        Xorg :0 -config /tmp/xorg-dummy.conf 2>/dev/null &
        ;;
esac

# Esperar a que Xorg este listo
for i in $(seq 1 15); do
    if xdpyinfo -display :0 &>/dev/null 2>&1; then
        log "Display :0 activo"
        break
    fi
    sleep 1
done

export DISPLAY=:0

# Configurar resolucion con xrandr si esta disponible
if command -v xrandr &>/dev/null; then
    xrandr --display :0 --output HEAD-0 --mode "${WIDTH}x${HEIGHT}" 2>/dev/null || true
    xrandr --display :0 --output DVI-I-1 --mode "${WIDTH}x${HEIGHT}" 2>/dev/null || true
    xrandr --display :0 --output Virtual-1 --mode "${WIDTH}x${HEIGHT}" 2>/dev/null || true
fi

log "Display virtual configurado en :0 (${RESOLUTION})"
exit 0
