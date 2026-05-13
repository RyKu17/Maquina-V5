#!/bin/bash
# 03-sunshine.sh - Instala y configura Sunshine (servidor de streaming)
set -e

log() { echo "[03-sunshine] $*"; }
error() { echo "[03-sunshine] ERROR: $*" >&2; exit 1; }

SUNSHINE_USER="${SUNSHINE_USER:-admin}"
SUNSHINE_PASS="${SUNSHINE_PASS:-admin}"

SUNSHINE_VERSION="0.23.1"
ARCH="$(uname -m)"
case "$ARCH" in
    x86_64)  PKG_ARCH="amd64" ;;
    aarch64) PKG_ARCH="arm64"  ;;
    *)       error "Arquitectura no soportada: $ARCH" ;;
esac

install_from_github() {
    local url="https://github.com/LizardByte/Sunshine/releases/download/v${SUNSHINE_VERSION}/sunshine-ubuntu-22.04-${PKG_ARCH}.deb"
    local deb_file="/tmp/sunshine.deb"

    log "Descargando Sunshine v${SUNSHINE_VERSION}..."
    curl -fsSL "$url" -o "$deb_file" || error "Fallo al descargar Sunshine"
    
    log "Instalando Sunshine..."
    dpkg -i "$deb_file" 2>/dev/null || true
    apt-get install -f -y -qq || error "Fallo al instalar dependencias de Sunshine"
    rm -f "$deb_file"
}

install_from_apt() {
    log "Instalando Sunshine via apt..."
    add-apt-repository ppa:superm1/ffmpeg5 -y -n 2>/dev/null || true
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq sunshine 2>/dev/null || return 1
    return 0
}

log "Verificando si Sunshine ya esta instalado..."
if command -v sunshine &>/dev/null; then
    log "Sunshine ya esta instalado"
else
    log "Instalando Sunshine..."
    install_from_apt || install_from_github || error "No se pudo instalar Sunshine"
    log "Sunshine instalado correctamente"
fi

log "Configurando Sunshine..."
SUNSHINE_CONFIG_DIR="/home/$SUDO_USER/.config/sunshine"
if [ -z "$SUDO_USER" ]; then
    SUNSHINE_CONFIG_DIR="$HOME/.config/sunshine"
fi

mkdir -p "$SUNSHINE_CONFIG_DIR"

cat > "$SUNSHINE_CONFIG_DIR/sunshine.conf" << EOF
port = 47990
pkey = /home/sunshine/.config/sunshine/sunshine.key
cert = /home/sunshine/.config/sunshine/sunshine.cert
file_state = /home/sunshine/.config/sunshine/state.json
credentials_file = /home/sunshine/.config/sunshine/credentials.json
min_log_level = 2
EOF

log "Estableciendo credenciales de Sunshine..."
cat > "$SUNSHINE_CONFIG_DIR/credentials.json" << EOF
{
    "username": "${SUNSHINE_USER}",
    "password": "${SUNSHINE_PASS}"
}
EOF

chmod 600 "$SUNSHINE_CONFIG_DIR/credentials.json"

log "Sunshine configurado - Usuario: $SUNSHINE_USER"
exit 0
