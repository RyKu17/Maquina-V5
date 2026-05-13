#!/bin/bash
# ============================================
# Maquina-V5 - Instalador Automatico
# Cloud Gaming con GPU NVIDIA Tesla T4 (Colab)
# ============================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

log() { echo "[install] $*"; }
error() { echo "[install] ERROR: $*" >&2; exit 1; }
warn() { echo "[install] WARN: $*" >&2; }

# Cargar configuracion si existe
CONFIG_FILE="$PROJECT_DIR/config.env"
if [ -f "$CONFIG_FILE" ]; then
    log "Cargando configuracion desde $CONFIG_FILE"
    set -o allexport
    source "$CONFIG_FILE"
    set +o allexport
fi

# Verificar que somos root en Colab
if [ "$(id -u)" -ne 0 ]; then
    warn "No se esta ejecutando como root. Algunas funciones pueden fallar."
fi

# Detectar entorno
is_colab() {
    [ -d /content ] && return 0
    return 1
}

print_banner() {
    echo ""
    echo "  ╔══════════════════════════════════════════╗"
    echo "  ║        MAQUINA-V5  CLOUD GAMING          ║"
    echo "  ║  Steam + Sunshine + Tailscale + GPU T4   ║"
    echo "  ╚══════════════════════════════════════════╝"
    echo ""
}

print_summary() {
    local tailscale_ip="${1:-desconocida}"
    echo ""
    echo "  ══════════════════════════════════════════"
    echo "  ✅ INSTALACION COMPLETADA"
    echo "  ══════════════════════════════════════════"
    echo ""
    echo "  🌐 Tailscale IP: $tailscale_ip"
    echo "  🖥️  Sunshine WebUI: https://${tailscale_ip}:47990"
    echo "  🔑 Sunshine User: ${SUNSHINE_USER:-admin}"
    echo "  🔑 Sunshine Pass: ${SUNSHINE_PASS:-admin}"
    echo ""
    echo "  📱 Conecta Moonlight a: $tailscale_ip"
    echo ""
    echo "  ══════════════════════════════════════════"
    echo ""
}

# ============================================
print_banner
START_TIME=$(date +%s)

# ============================================
# FASE 1: Sistema base
# ============================================
log "FASE 1/5 - Instalando dependencias del sistema..."
bash "$SCRIPT_DIR/01-system.sh" || error "Fallo en 01-system.sh"
log "Sistema base listo"

# ============================================
# FASE 2: Pantalla virtual
# ============================================
log "FASE 2/5 - Configurando display virtual..."
bash "$SCRIPT_DIR/05-display.sh" || warn "Display virtual puede requerir ajustes"
log "Display virtual listo"

# ============================================
# FASE 3: Tailscale
# ============================================
log "FASE 3/5 - Instalando Tailscale..."
bash "$SCRIPT_DIR/02-tailscale.sh" || error "Fallo en 02-tailscale.sh"
TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "pendiente")
log "Tailscale IP: $TAILSCALE_IP"

# ============================================
# FASE 4: Sunshine
# ============================================
log "FASE 4/5 - Instalando Sunshine..."
bash "$SCRIPT_DIR/03-sunshine.sh" || error "Fallo en 03-sunshine.sh"
log "Sunshine listo"

# ============================================
# FASE 5: Steam + Wine
# ============================================
log "FASE 5/5 - Instalando Steam y Wine..."
bash "$SCRIPT_DIR/04-steam.sh" || warn "Steam/Wine pueden requerir configuracion manual"
log "Steam y Wine listos"

# ============================================
# Iniciar servicios
# ============================================
log "Iniciando servicios..."

# Matar instancias previas de Sunshine si las hay
pkill sunshine 2>/dev/null || true
sleep 1

# Iniciar Sunshine en background
nohup sunshine > /tmp/sunshine.log 2>&1 &
SUNSHINE_PID=$!
log "Sunshine iniciado (PID: $SUNSHINE_PID)"

# ============================================
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
log "Instalacion completada en ${DURATION}s"

print_summary "$TAILSCALE_IP"

# ============================================
# Backup opcional
# ============================================
if [ "${BACKUP_ENABLED:-false}" = "true" ] && is_colab; then
    log "Backup habilitado, ejecutando..."
    bash "$SCRIPT_DIR/06-backup.sh" backup || warn "Backup no completado"
fi

log "¡Disfruta tu PC Gamer en la nube!"
exit 0
