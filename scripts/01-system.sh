#!/bin/bash
# 01-system.sh - Instala dependencias del sistema
set -e

log() { echo "[01-system] $*"; }
error() { echo "[01-system] ERROR: $*" >&2; exit 1; }

# Detectar si estamos en Colab
is_colab() {
    [ -f /content/ColabSteam ] || [ -d /content ] && grep -q "colab" /etc/hostname 2>/dev/null
    return $?
}

log "Actualizando paquetes del sistema..."
apt-get update -qq || error "No se pudo actualizar apt"

log "Instalando dependencias esenciales..."
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    wget curl gnupg2 software-properties-common \
    xserver-xorg-video-dummy xorg xorg-server \
    mesa-utils libgl1-mesa-dri libgl1-mesa-glx \
    cabextract p7zip unzip zip \
    pulseaudio pavucontrol \
    jq net-tools \
    ca-certificates \
    2>&1 || error "Fallo al instalar dependencias esenciales"

log "Instalando Wine y dependencias de 32 bits..."
dpkg --add-architecture i386
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    wine64 wine32 wine \
    winetricks \
    2>&1 || log "Wine no disponible en repos, se instalara manualmente si es necesario"

log "Sistema base listo"
exit 0
