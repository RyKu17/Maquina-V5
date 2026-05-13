#!/bin/bash
# 02-tailscale.sh - Instala y configura Tailscale VPN
set -e

log() { echo "[02-tailscale] $*"; }
error() { echo "[02-tailscale] ERROR: $*" >&2; exit 1; }

TAILSCALE_AUTHKEY="${TAILSCALE_AUTHKEY:-}"

log "Verificando si Tailscale ya esta instalado..."
if command -v tailscale &>/dev/null; then
    log "Tailscale ya esta instalado"
    tailscale status --json 2>/dev/null | jq -r '.Self.DNSName // "desconocido"' 2>/dev/null
    exit 0
fi

log "Instalando Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh || error "Fallo al instalar Tailscale"

log "Iniciando Tailscale..."
if [ -n "$TAILSCALE_AUTHKEY" ]; then
    tailscale up --auth-key="$TAILSCALE_AUTHKEY" --accept-dns=false || error "Fallo al autenticar Tailscale"
    log "Autenticacion automatica completada"
else
    log "Iniciando Tailscale en modo interactivo..."
    tailscale up --accept-dns=false || true
fi

# Esperar a que Tailscale este conectado
for i in $(seq 1 10); do
    TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || true)
    if [ -n "$TAILSCALE_IP" ] && [ "$TAILSCALE_IP" != "0.0.0.0" ]; then
        log "Tailscale conectado! IP: $TAILSCALE_IP"
        break
    fi
    sleep 2
done

log "Tailscale listo"
exit 0
