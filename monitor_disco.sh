#!/bin/bash
# =============================================================================
# monitor_disco.sh - Monitor de uso de disco para Debian 13 (Trixie)
#
# Uso:      ./monitor_disco.sh [UMBRAL]
# Ejemplo:  ./monitor_disco.sh 80
#
# - UMBRAL: porcentaje de uso (1-100) a partir del cual se genera una ALERTA.
#           Si no se indica, se usa 80 por defecto.
# - Registra cada resultado en ~/monitor_disco.log (OK o ALERTA).
# - Si el comando "mail" está instalado y se define DESTINATARIO, envía un
#   correo cuando hay una ALERTA.
#
# Automatización con cron (cada 10 minutos):
#   */10 * * * * /home/diegol/scripts/monitor_disco.sh 80
# =============================================================================

# Umbral por defecto: 80 si no se recibe ningún argumento
UMBRAL="${1:-80}"

# Archivo de bitácora y destinatario opcional de correo
LOG="$HOME/monitor_disco.log"
DESTINATARIO="${DESTINATARIO:-}"

# Guarda un mensaje en el log con fecha y hora
registrar() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG"
}

# Validación de la entrada con expresión regular: solo números enteros
if ! [[ "$UMBRAL" =~ ^[0-9]+$ ]]; then
    echo "Error: el umbral debe ser un número entero (recibido: '$UMBRAL')." >&2
    echo "Uso: $0 [UMBRAL]" >&2
    exit 1
fi

# Validación del rango permitido
if (( UMBRAL < 1 || UMBRAL > 100 )); then
    echo "Error: el umbral debe estar entre 1 y 100 (recibido: $UMBRAL)." >&2
    exit 1
fi

# Obtiene porcentaje y punto de montaje de cada sistema de archivos real
# (se omiten los sistemas temporales y virtuales) y recorre cada línea.
df --output=pcent,target -x tmpfs -x devtmpfs -x squashfs -x overlay \
    | tail -n +2 \
    | while read -r USO PUNTO; do

        # Quita el símbolo % para poder comparar números
        USO="${USO%\%}"

        if (( USO >= UMBRAL )); then
            MENSAJE="ALERTA: $PUNTO al ${USO}% (umbral ${UMBRAL}%)"
            registrar "$MENSAJE"
            echo "$MENSAJE"

            # Envío opcional de correo si existe "mail" y hay destinatario
            if [[ -n "$DESTINATARIO" ]] && command -v mail >/dev/null 2>&1; then
                echo "$MENSAJE" | mail -s "Alerta de disco en $(hostname)" "$DESTINATARIO"
            fi
        else
            MENSAJE="OK: $PUNTO al ${USO}%"
            registrar "$MENSAJE"
            echo "$MENSAJE"
        fi
    done

exit 0
