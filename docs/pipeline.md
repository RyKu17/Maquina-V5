# Pipeline de Maquina-V5

## Arquitectura

```
Google Colab (GPU Tesla T4)
├── Ubuntu 22.04 LTS
├── NVIDIA Tesla T4 (16GB VRAM)
├── 12.67 GB RAM
├── 2 Cores Intel Xeon @ 2.0GHz
│
├── Componentes:
│   ├── Tailscale    → VPN mesh (conexion segura)
│   ├── Sunshine     → Servidor de streaming (alternativa a GeForce Experience)
│   ├── Steam        → Plataforma de juegos (via Wine/Proton)
│   ├── Wine/Proton  → Capa de compatibilidad Windows → Linux
│   └── X11 Dummy    → Display virtual headless
│
└── Cliente:
    └── Moonlight    → Cliente de streaming en PC/Tablet/Phone
```

## Flujo de Instalacion

### Fase 1: Sistema Base (`01-system.sh`)
```
1. apt-get update
2. Instalar: xorg, mesa-utils, libgl, pulseaudio
3. Agregar arquitectura i386
4. Instalar: wine64, wine32, winetricks
```

### Fase 2: Display Virtual (`05-display.sh`)
```
1. Detectar GPU (NVIDIA Tesla T4 / AMD / Dummy)
2. Configurar Xorg con display virtual
3. Iniciar Xorg en :0
4. Configurar resolucion con xrandr
```

### Fase 3: Tailscale (`02-tailscale.sh`)
```
1. Descargar e instalar Tailscale
2. Autenticar (auto con auth key o manual)
3. Obtener IP de Tailscale
```

### Fase 4: Sunshine (`03-sunshine.sh`)
```
1. Instalar Sunshine (apt o GitHub Releases)
2. Configurar credenciales (user/pass)
3. Generar certificados SSL
4. Iniciar servicio en puerto 47990
```

### Fase 5: Steam + Wine (`04-steam.sh`)
```
1. Agregar arquitectura i386
2. Instalar Steam (apt o flatpak)
3. Inicializar Wine prefix (64 bits)
4. Instalar: corefonts, vcrun2019, dxvk
5. Descargar Proton GE
```

## Puertos

| Puerto | Protocolo | Servicio     |
|--------|-----------|--------------|
| 47990  | TCP       | Sunshine Web |
| 47984  | TCP       | Sunshine Ctrl|
| 47989  | TCP       | Sunshine Ctrl|
| 47998  | UDP       | Video        |
| 47999  | UDP       | Video        |
| 48000  | UDP       | Streaming    |
| 48002  | UDP       | Streaming    |
| 48010  | UDP       | Streaming    |
| 41641  | UDP       | Tailscale    |

## Variables de Entorno

| Variable         | Default    | Descripcion                  |
|------------------|------------|------------------------------|
| SUNSHINE_USER    | admin      | Usuario web Sunshine         |
| SUNSHINE_PASS    | admin      | Contraseña Sunshine          |
| TAILSCALE_AUTHKEY| (vacio)    | Auth key para Tailscale      |
| DISPLAY_RES      | 1920x1080  | Resolucion display virtual   |
| DISPLAY_REFRESH  | 60         | Frecuencia de refresco       |
| MOUNT_DRIVE      | false      | Montar Google Drive          |
| BACKUP_ENABLED   | false      | Activar backups              |
| REGION_PREF      | auto       | Region preferida Colab       |

## Notas

- Cada sesion de Colab dura ~4 horas continuas
- El tiempo se reinicia cada 24 horas
- Los backups reducen el tiempo de espera 50-75%
- Sunshine usa certificados auto-firmados (aceptar excepcion en el navegador)
