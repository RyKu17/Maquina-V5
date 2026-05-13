<div align="center">

# ☁️ Maquina-V5: Cloud Gaming Transparente
### ⭐ ¡Si te fue útil, no olvides dejar una estrella!

### 🎮 Ejecuta Steam y juega en la nube con Google Colab

![Portada](assets/1.png)

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/RyKu17/Maquina-V5/blob/main/colab/maquina-v5.ipynb)
[![GitHub Stars](https://img.shields.io/github/stars/RyKu17/Maquina-V5?style=social)](https://github.com/RyKu17/Maquina-V5/stargazers)
[![GitHub License](https://img.shields.io/github/license/RyKu17/Maquina-V5)](https://github.com/RyKu17/Maquina-V5/blob/main/LICENSE)

---

> ✅ **100% TRANSPARENTE** — Todos los scripts son bash legibles, sin binarios opacos.
>
> Basado en el proyecto original de [kmille36/Colab-Cloud-Gaming](https://github.com/kmille36/Colab-Cloud-Gaming)

[📺 Ver Demostración en YouTube](https://youtu.be/zkxQ1IQ--7M?si=avkAjTEgBRfEpBRc)

</div>

---

## 🚀 Inicio Rápido (Colab)

1. Abre el notebook en Colab:
   [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/RyKu17/Maquina-V5/blob/main/colab/maquina-v5.ipynb)

2. Ejecuta las celdas en orden:
   - **Celda 1:** Montar Google Drive (opcional, para backups)
   - **Celda 2:** Verificar región
   - **Celda 3:** Instalación automática (descarga los scripts y ejecuta todo)
   - **Celda 4:** Mantener sesión activa (opcional)

3. Conecta **Moonlight** a la IP de Tailscale que aparece al final

### 🚀 Inicio Rápido (VPS)

```bash
# 1. Clona el repo
git clone https://github.com/RyKu17/Maquina-V5.git
cd Maquina-V5

# 2. Configura (opcional)
cp config.env .env
# edita .env con tus preferencias

# 3. Ejecuta
sudo bash scripts/install.sh
```

---

## 📋 Requisitos

| Software | Descripción |
|----------|-------------|
| 🔗 **Tailscale** | Conexión segura de red (se instala automáticamente) |
| 🌙 **Moonlight** | Cliente de streaming en tu PC/Tablet/Phone |
| ☁️ **Google Colab** | GPU Tesla T4 gratuita (~4h por sesión) |

---

## 🧩 Estructura del Proyecto

```
Maquina-V5/
├── scripts/
│   ├── install.sh          # Orquestador principal
│   ├── 01-system.sh        # Dependencias del sistema
│   ├── 02-tailscale.sh     # Tailscale VPN
│   ├── 03-sunshine.sh      # Sunshine (servidor streaming)
│   ├── 04-steam.sh         # Steam + Wine/Proton
│   ├── 05-display.sh       # Display virtual X11
│   └── 06-backup.sh        # Backup Google Drive
├── colab/
│   └── maquina-v5.ipynb    # Notebook para Google Colab
├── config.env              # Template de configuración
├── docs/
│   └── pipeline.md         # Documentación del pipeline
└── assets/                 # Imágenes y capturas
```

---

## ⚙️ Configuración Personalizable

| Variable | Default | Descripción |
|----------|---------|-------------|
| `SUNSHINE_USER` | `admin` | Usuario web Sunshine |
| `SUNSHINE_PASS` | `admin` | Contraseña Sunshine |
| `TAILSCALE_AUTHKEY` | — | Auth key automática (opcional) |
| `DISPLAY_RES` | `1920x1080` | Resolución del display virtual |
| `BACKUP_ENABLED` | `false` | Activar backups a Google Drive |

---

## 🔄 Diferencia con el Original

| Aspecto | Original (kmille36) | Esta versión |
|---------|-------------------|--------------|
| Instalador | Binario ELF compilado (15KB, ilegible) | Scripts bash (100% legibles) |
| Personalización | Hardcodeado en el binario | Variables de entorno |
| Notebook | Apunta al binario original | Apunta a scripts transparentes |
| VPS | Solo Colab | Colab + VPS Ubuntu |
| Código | No modificable | Totalmente modificable |

---

## 📺 TUTORIAL

[![Tutorial en YouTube](https://img.youtube.com/vi/zkxQ1IQ--7M/maxresdefault.jpg)](https://youtu.be/zkxQ1IQ--7M?si=avkAjTEgBRfEpBRc)

**[▶️ Ver Tutorial Completo en YouTube](https://youtu.be/zkxQ1IQ--7M?si=avkAjTEgBRfEpBRc)**

---

## 💻 Especificaciones de la Máquina Virtual

| 🎮 **GPU** | ⚡ **CPU** | 💾 **RAM** | 🖥️ **Sistema Operativo** |
|:----------:|:----------:|:----------:|:------------------------:|
| **NVIDIA Tesla T4** | **Intel Xeon**<br>2 Cores @ 2.0GHz | **12.67 GB** | **Ubuntu 22.04 LTS** |

---

## 🎮 Juegos Compatibles

- Doom Eternal
- Metal Gear Solid V: The Phantom Pain
- Titanfall 2
- Wolfenstein II: The New Colossus
- Sniper Elite 4
- Mad Max
- Batman: Arkham Knight
- Rise of the Tomb Raider
- Grand Theft Auto V
- Alien: Isolation
- Resident Evil 2 (Remake)
- Devil May Cry 5
- BioShock Infinite
- Hades
- Forza Horizon 4

---

## ⚙️ Configuración de Streaming

| Función | Estado |
|---------|--------|
| Soporte de control en Moonlight | ✅ Funcional |
| Gamepad virtual | ❌ No disponible |
| Gamepad físico | ❌ No disponible |

🌐 **Interfaz web de Sunshine:** `https://[tu-ip-tailscale]:47990`

---

## 💾 Sistema de Respaldos

> Ahorra entre **50% y 75%** del tiempo de espera en tu próxima sesión.

1. **Descarga e instala** tu juego de Steam/Epic
2. **Compila los shaders** en el primer inicio
3. **Ejecuta el backup:** `bash scripts/06-backup.sh backup`
4. **¡Listo!** La próxima vez restaura con: `bash scripts/06-backup.sh restore`

---

## ⚠️ Recomendaciones

- ⏰ Sesión de ~4 horas (se reinicia cada 24h)
- 👀 No ocultes la pestaña de Colab para evitar desconexiones
- 💿 El montaje de Drive es opcional
- 🔐 Cambia la contraseña de Sunshine por seguridad

---

## 🐛 Solución de Problemas

> Si encuentras algún error, revisa los logs:
> ```bash
> tail -f /tmp/sunshine.log  # Logs de Sunshine
> journalctl -u tailscale    # Logs de Tailscale
> ```

---

<div align="center">

### ⭐ ¡Si te fue útil, no olvides dejar una estrella!

Hecho con ❤️ para la comunidad gamer

</div>
