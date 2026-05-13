#!/bin/bash
# 04-steam.sh - Instala Steam + Proton + configura Wine
set -e

log() { echo "[04-steam] $*"; }
error() { echo "[04-steam] ERROR: $*" >&2; exit 1; }

install_steam_from_repo() {
    log "Instalando Steam desde repositorio..."
    # Agregar arquitectura i386 si no existe
    dpkg --add-architecture i386 2>/dev/null || true
    apt-get update -qq

    # Instalar steam
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq steam-installer steam-devices 2>/dev/null || return 1
    
    # Configurar Steam para modo headless
    mkdir -p "$HOME/.steam"
    cat > "$HOME/.steam/steam_dev.cfg" << 'EOF'
@nClientDownloadEnabled 1
@fDownloadRateLimit 0
@fDownloadMinSpeed 0
@fDownloadThrottleKbps 0
EOF
    
    return 0
}

install_steam_from_flatpak() {
    log "Instalando Steam via Flatpak..."
    apt-get install -y -qq flatpak 2>/dev/null || true
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
    flatpak install -y flathub com.valvesoftware.Steam 2>/dev/null || return 1
    return 0
}

setup_wine_proton() {
    log "Configurando Wine/Proton..."
    
    # Configurar Wine en 64 bits
    export WINEARCH=win64
    export WINEPREFIX="$HOME/.wine64"
    
    if [ ! -d "$WINEPREFIX" ]; then
        log "Inicializando Wine prefix (64 bits)..."
        wineboot -u 2>/dev/null || true
    fi

    # Instalar componentes esenciales via winetricks
    log "Instalando componentes de Wine (directx, vcrun)..."
    winetricks -q corefonts vcrun2019 dxvk 2>/dev/null || log "Algunos componentes de Wine no se instalaron (no critico)"
    
    # Descargar Proton GE si estamos en entorno desktop
    log "Descargando Proton GE..."
    PROTON_URL=$(curl -fsSL https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest 2>/dev/null | grep "browser_download_url.*tar.gz" | cut -d'"' -f4 | head -1)
    
    if [ -n "$PROTON_URL" ]; then
        mkdir -p "$HOME/.steam/root/compatibilitytools.d"
        curl -fsSL "$PROTON_URL" -o /tmp/proton-ge.tar.gz
        tar -xzf /tmp/proton-ge.tar.gz -C "$HOME/.steam/root/compatibilitytools.d/" 2>/dev/null || log "No se pudo extraer Proton GE"
        rm -f /tmp/proton-ge.tar.gz
        log "Proton GE instalado"
    else
        log "No se pudo descargar Proton GE (continuando sin el)"
    fi
}

log "Verificando si Steam ya esta instalado..."
if command -v steam &>/dev/null || [ -f "$HOME/.steam/steam.sh" ]; then
    log "Steam ya esta instalado"
else
    log "Instalando Steam..."
    install_steam_from_repo || install_steam_from_flatpak || log "Steam no se pudo instalar (se puede instalar manualmente)"
fi

setup_wine_proton

log "Steam/Wine listo"
exit 0
