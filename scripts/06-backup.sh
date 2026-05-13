#!/bin/bash
# 06-backup.sh - Backup/Restore de la sesion a Google Drive
set -e

log() { echo "[06-backup] $*"; }
error() { echo "[06-backup] ERROR: $*" >&2; exit 1; }

BACKUP_FILE="/content/drive/MyDrive/backup.tar.gz"
MOUNT_POINT="/content/drive"

backup() {
    log "Iniciando backup a Google Drive..."
    
    if [ ! -d "$MOUNT_POINT" ]; then
        log "Google Drive no montado. Intentando montar..."
        if command -v google-drive-ocamlfuse &>/dev/null; then
            mkdir -p "$MOUNT_POINT"
            google-drive-ocamlfuse "$MOUNT_POINT" 2>/dev/null || {
                log "No se pudo montar Google Drive. Usando /tmp/backup..."
                BACKUP_FILE="/tmp/backup.tar.gz"
            }
        else
            BACKUP_FILE="/tmp/backup.tar.gz"
        fi
    fi
    
    log "Creando archivo de backup en: $BACKUP_FILE"
    tar -czf "$BACKUP_FILE" \
        --exclude="/proc" \
        --exclude="/sys" \
        --exclude="/dev" \
        --exclude="/tmp" \
        "$HOME/.steam" \
        "$HOME/.local/share/Steam" \
        "$HOME/.wine64" \
        "$HOME/.config/sunshine" \
        2>/dev/null || log "Backup creado con algunas omisiones"
    
    log "Backup completado: $(du -sh "$BACKUP_FILE" 2>/dev/null | cut -f1)"
}

restore() {
    log "Restaurando backup desde Google Drive..."
    
    if [ -f "$BACKUP_FILE" ]; then
        log "Restaurando desde: $BACKUP_FILE"
        tar -xzf "$BACKUP_FILE" -C / 2>/dev/null || log "Error al restaurar algunos archivos"
        log "Restauracion completada"
    else
        log "No se encontro archivo de backup en: $BACKUP_FILE"
        return 1
    fi
}

case "${1:-}" in
    backup)  backup  ;;
    restore) restore ;;
    *)
        log "Uso: $0 {backup|restore}"
        log "Ejemplo: $0 backup   # Crea backup"
        log "Ejemplo: $0 restore  # Restaura backup"
        exit 1
        ;;
esac

exit 0
