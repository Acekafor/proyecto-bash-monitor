# Monitor de Uso de Disco en Debian 13

Script en **Bash** que supervisa el uso del disco en **Debian 13 (Trixie)** y registra una alerta cuando el porcentaje de ocupación supera un umbral definido. Se automatiza con **cron** para ejecutarse cada 10 minutos sin intervención del usuario.

## Descripción

La saturación del disco puede causar fallos en servicios y problemas de estabilidad del sistema, y las revisiones manuales suelen llegar tarde. Este proyecto automatiza la supervisión del almacenamiento usando únicamente herramientas nativas de Debian, sin dependencias externas.

## Objetivos

**Objetivo general:** desarrollar un script en Bash que supervise el uso del disco y genere alertas cuando se supere un umbral definido.

**Objetivos específicos:**

- Configurar `sudo` y los repositorios de Debian.
- Obtener el porcentaje de ocupación mediante el comando `df`.
- Implementar validaciones con condicionales y bucles `while`.
- Automatizar la ejecución periódica mediante `cron`.
- Registrar los resultados en un archivo de bitácora (log).

## Tecnologías utilizadas

| Herramienta | Uso |
|---|---|
| Debian 13 (Trixie) | Sistema operativo |
| Bash | Desarrollo del script |
| `df` | Consulta del uso de disco |
| `sudo` | Administración segura del sistema |
| APT | Gestión de paquetes |
| `cron` | Automatización de tareas |
| `mail` | Envío opcional de notificaciones |

## Estructura del repositorio

```
.
├── monitor_disco.sh   # Script principal
└── README.md
```

## Preparación del entorno

Entrar como root e instalar `sudo`:

```bash
su -
apt install sudo
```

Agregar el usuario al grupo `sudo` (cambia `diegol` por tu usuario):

```bash
usermod -aG sudo diegol
```

Cierra sesión y vuelve a entrar para que el cambio de grupo se aplique, y verifica los privilegios:

```bash
sudo -l
```

Actualizar el sistema:

```bash
sudo apt update && sudo apt upgrade
```

## Instalación

```bash
mkdir -p ~/scripts
cp monitor_disco.sh ~/scripts/
chmod +x ~/scripts/monitor_disco.sh
```

## Uso

```bash
~/scripts/monitor_disco.sh [UMBRAL]
```

- `UMBRAL`: porcentaje de uso entre 1 y 100. Si no se indica, se usa **80** por defecto.

Ejemplos:

```bash
~/scripts/monitor_disco.sh        # umbral por defecto (80%)
~/scripts/monitor_disco.sh 95     # alerta al llegar a 95%
~/scripts/monitor_disco.sh 1      # prueba: genera alertas en todos los puntos
```

### Notificaciones por correo (opcional)

Si `mail` está instalado, define el destinatario con la variable `DESTINATARIO`:

```bash
DESTINATARIO=correo@ejemplo.com ~/scripts/monitor_disco.sh 80
```

## Cómo funciona

1. Recibe un umbral de uso (por defecto 80%).
2. Valida con expresiones regulares que sea un número entero entre 1 y 100.
3. Consulta los sistemas de archivos con `df --output=pcent,target`.
4. Recorre cada resultado con un bucle `while read`.
5. Compara el porcentaje de uso con el umbral.
6. Registra `OK` o `ALERTA` en el log mediante la función `registrar()`.
7. Envía un correo si hay una alerta y se configuró el destinatario.

### Componentes principales

- `${1:-80}`: define el umbral por defecto.
- `registrar()`: guarda los eventos en el archivo de log con fecha y hora.
- Expresiones regulares: validan la entrada del usuario.
- `df --output=pcent,target`: obtiene el porcentaje y el punto de montaje.
- `while read`: procesa cada línea de la salida.
- `mail`: envía las notificaciones de alerta.

## Automatización con cron

Instalar y verificar el servicio:

```bash
sudo apt install cron
systemctl status cron
```

Editar la tabla de tareas con `crontab -e` y agregar:

```cron
*/10 * * * * /home/diegol/scripts/monitor_disco.sh 80
```

Esto ejecuta el monitoreo **cada 10 minutos**. Para ver la tarea programada:

```bash
crontab -l
```

## Registro (log)

Los resultados se guardan en `~/monitor_disco.log`. Para ver las últimas líneas:

```bash
tail -n 10 ~/monitor_disco.log
```

Ejemplo de salida:

```
2026-11-18 22:35:35 OK: / al 20%
2026-11-18 22:35:38 ALERTA: / al 20% (umbral 1%)
2026-11-19 00:20:02 OK: / al 21%
```

## Pruebas realizadas

| Prueba | Resultado |
|---|---|
| Umbral 95% | Registros OK |
| Umbral 1% | Alertas en todos los puntos |
| Valor inválido | Error y salida controlada |
| Lectura del log | Visualización de registros |
| Cron activo | Ejecución automática verificada |

## Mejoras futuras

- Integrar webhooks para notificaciones.
- Usar archivos de configuración.
- Reemplazar cron por temporizadores de `systemd`.

## Autores

- David Martínez Zambrano
- Nicolás Romero Beltrán
- Diego Alejandro López Arrieta
