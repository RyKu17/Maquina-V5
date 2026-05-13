# Skill: maquina-v5

Cloud Gaming automatizado con GPU Tesla T4 (Google Colab) o VPS Ubuntu.

## Triggers
- "crea el VPS"
- "ejecuta maquina-v5"
- "instala cloud gaming"
- "arma la maquina gamer"

## Flujo

Cuando el usuario ejecute cualquiera de los triggers:

1. **Preguntar modo de despliegue:**
   - `colab` — genera notebook y da instrucciones
   - `vps` — despliegue automatico por SSH

2. **Si es modo VPS, preguntar configuracion:**
   - IP del servidor
   - Puerto SSH (default: 22)
   - Usuario SSH (default: root)
   - Contrasena SSH o clave privada
   - Usuario Sunshine (default: admin)
   - Contrasena Sunshine (default: admin)
   - Resolucion display (default: 1920x1080)
   - Tailscale Auth Key (opcional)
   - Activar backups Google Drive (solo Colab)

3. **Ejecutar:**
   - **Modo Colab:** Abrir enlace a notebook, pegarlo en Colab, ejecutar celdas
   - **Modo VPS:** Conectar SSH → clonar repo → ejecutar `scripts/install.sh` con variables de entorno → devolver resumen

4. **Devolver resumen:**
   - IP Tailscale
   - URL Sunshine WebUI: `https://[IP]:47990`
   - Credenciales Sunshine
   - Instrucciones conectar Moonlight

## Variables Configurables

| Variable | Default | Descripcion |
|---|---|---|
| SUNSHINE_USER | admin | Usuario web Sunshine |
| SUNSHINE_PASS | admin | Contrasena Sunshine |
| TAILSCALE_AUTHKEY | — | Auth key Tailscale (opcional) |
| DISPLAY_RES | 1920x1080 | Resolucion display virtual |
| DISPLAY_REFRESH | 60 | Hz del display |
| MOUNT_DRIVE | false | Montar Google Drive |
| BACKUP_ENABLED | false | Activar backups |

## Estructura del Repo

```
Maquina-V5/
├── scripts/
│   ├── install.sh          # Orquestador
│   ├── 01-system.sh        # Dependencias
│   ├── 02-tailscale.sh     # Tailscale VPN
│   ├── 03-sunshine.sh      # Sunshine server
│   ├── 04-steam.sh         # Steam + Wine/Proton
│   ├── 05-display.sh       # Display virtual
│   └── 06-backup.sh        # Backup Google Drive
├── colab/
│   └── maquina-v5.ipynb    # Notebook Colab
├── config.env              # Template configuracion
└── docs/
    └── pipeline.md         # Documentacion del pipeline
```

## Notas

- Los scripts son 100% transparentes (bash puro, sin binarios compilados)
- Compatible con Ubuntu 22.04/24.04
- La GPU Tesla T4 de Colab da ~800 FPS en juegos ligeros
- Sesion de Colab: ~4h continuas (se reinicia cada 24h)
- Sunshine requiere certificado SSL auto-firmado (aceptar en navegador)
