#!/bin/bash
# ==============================================================================
# Script: grabar_practica.sh
# Descripción: Registra comandos de base de datos y sus salidas en un archivo log.
# Creado por: Nexus (IA de Martin)
# ==============================================================================

# Habilitar el historial en scripts no interactivos para poder usar las flechas arriba/abajo
set -o history

# Definir archivos y directorios
LOG_DIR="/home/martin/Practicas"
LOG_FILE="$LOG_DIR/logs"
HIST_FILE="/home/martin/.db_practice_history"

# Asegurar que el directorio existe
mkdir -p "$LOG_DIR"

# Cargar el historial previo si existe
if [ -f "$HIST_FILE" ]; then
    history -r "$HIST_FILE"
fi

# Colores para la interfaz en la terminal (delimitados para evitar fallos de readline en 'read')
COLOR_TITLE=$'\x01\e[1;36m\x02'   # Cian brillante
COLOR_PROMPT=$'\x01\e[1;33m\x02'  # Amarillo brillante
COLOR_SYSTEM=$'\x01\e[1;35m\x02'  # Púrpura/Magenta
COLOR_SUCCESS=$'\x01\e[1;32m\x02' # Verde
COLOR_ERROR=$'\x01\e[1;31m\x02'   # Rojo
COLOR_RESET=$'\x01\e[0m\x02'      # Restablecer colores

# Imprimir encabezado de inicio
clear
echo -e "${COLOR_TITLE}=========================================================${COLOR_RESET}"
echo -e "${COLOR_TITLE}   🤖 CONSOLA DE REGISTRO DE PRÁCTICAS - NEXUS v1.1 🤖   ${COLOR_RESET}"
echo -e "${COLOR_TITLE}=========================================================${COLOR_RESET}"
echo -e "  - Escribe ${COLOR_PROMPT}grabar${COLOR_RESET} para iniciar el registro de comandos."
echo -e "  - Escribe ${COLOR_ERROR}fin${COLOR_RESET} para detener/pausar la grabación."
echo -e "  - Escribe ${COLOR_ERROR}salir${COLOR_RESET} para cerrar el script."
echo -e "  - Todos tus comandos registrados se guardarán en:"
echo -e "    ${COLOR_SYSTEM}$LOG_FILE${COLOR_RESET}"
echo -e "  - Usa las flechas ${COLOR_PROMPT}↑ / ↓${COLOR_RESET} para navegar por tu historial."
echo -e "${COLOR_TITLE}=========================================================${COLOR_RESET}\n"

# Función para verificar si un comando es interactivo
is_interactive_command() {
    local cmd="$1"
    local lower_cmd
    lower_cmd=$(echo "$cmd" | tr '[:upper:]' '[:lower:]')
    
    # Comandos netamente interactivos / TUIs
    if [[ "$lower_cmd" =~ ^(vim|nano|emacs|less|more|top|htop|btop|glances|tmux|ssh|mosh|nmtui|harlequin|hql)$ ]]; then
        return 0
    fi
    
    # Clientes de bases de datos ejecutados de forma interactiva (sin el query inline)
    if [[ "$lower_cmd" == "sqlite3"* ]] && [[ ! "$lower_cmd" =~ (\'|\"|\-cmd) ]]; then
        return 0
    fi
    if [[ "$lower_cmd" == "pgcli"* ]] && [[ ! "$lower_cmd" =~ (\'|\"|\-c\ ) ]]; then
        return 0
    fi
    if [[ "$lower_cmd" == "mycli"* ]] && [[ ! "$lower_cmd" =~ (\'|\"|\-e\ ) ]]; then
        return 0
    fi
    if [[ "$lower_cmd" == "usql"* ]] && [[ ! "$lower_cmd" =~ (\'|\"|\-c\ |\-f\ ) ]]; then
        return 0
    fi
    if [[ "$lower_cmd" == "mysql"* ]] && [[ ! "$lower_cmd" =~ (\'|\"|\-e\ ) ]]; then
        return 0
    fi
    if [[ "$lower_cmd" == "psql"* ]] && [[ ! "$lower_cmd" =~ (\'|\"|\-c\ ) ]]; then
        return 0
    fi
    
    return 1
}

# Estado inicial de la grabación
RECORDING=false

# Loop principal
while true; do
    # Definir el prompt en base al estado
    if [ "$RECORDING" = "true" ]; then
        PROMPT_TEXT="${COLOR_PROMPT}Nexus-DB> ${COLOR_RESET}"
    else
        PROMPT_TEXT="${COLOR_TITLE}Nexus> ${COLOR_RESET}"
    fi

    # Leer el comando del usuario usando read con soporte readline (-e)
    read -e -p "$PROMPT_TEXT" CMD
    
    # Eliminar espacios extras al inicio y al final
    CMD=$(echo "$CMD" | xargs)
    
    # Si no se ingresó nada, continuar
    if [[ -z "$CMD" ]]; then
        continue
    fi
    
    # Procesar comandos según el estado
    if is_interactive_command "$CMD"; then
            echo -e "${COLOR_SYSTEM}[Nexus: Comando interactivo detectado. Grabando sesión y salida...]${COLOR_RESET}"

            # Registrar sólo el inicio del comando interactivo en el log
            echo "[$CURRENT_TIME] Comando Interactivo: $CMD" >> "$LOG_FILE"
            echo "----------------------------------------" >> "$LOG_FILE"

            # ---> NUEVO FLUJO DE GRABACIÓN Y LIMPIEZA <---
            RAW_TMP=$(mktemp)
            CLEAN_TMP=$(mktemp)

            # 1. Ejecutar a través del grabador PTY y guardar en un temporal
            python3 /home/martin/Practicas/scripts/pty_recorder.py "$RAW_TMP" bash -c "$CMD"

            # 2. Limpiar el archivo temporal usando el script de Python
            python3 /home/martin/Practicas/scripts/limpiar_log.py "$RAW_TMP" "$CLEAN_TMP"

            # 3. Volcar el texto limpio al log definitivo
            cat "$CLEAN_TMP" >> "$LOG_FILE"

            # 4. Limpiar archivos temporales de Arch Linux
            rm -f "$RAW_TMP" "$CLEAN_TMP"
            # ---------------------------------------------

            # Registrar fin de la sesión interactiva
            echo -e "\n----------------------------------------\n" >> "$LOG_FILE"
        else
            echo -e "${COLOR_ERROR}⚠️ Comando no reconocido en modo espera.${COLOR_RESET} Escribe ${COLOR_PROMPT}grabar${COLOR_RESET} para iniciar o ${COLOR_PROMPT}salir${COLOR_RESET} para finalizar."
            continue
        fi
    else
        # Modo Grabación Activo
        if [[ "$CMD" == "fin" ]]; then
            echo -e "\n${COLOR_SUCCESS}🛑 Grabación detenida. ¡Sesión guardada en el archivo logs!${COLOR_RESET}"
            # Guardar historial persistente
            history -w "$HIST_FILE"
            RECORDING=false
            echo -e "Volviendo al menú de control. Escribe ${COLOR_PROMPT}grabar${COLOR_RESET} para iniciar otra sesión o ${COLOR_PROMPT}salir${COLOR_RESET} para salir.\n"
            continue
        fi
        
        if [[ "$CMD" == "salir" ]]; then
            echo -e "\n${COLOR_SUCCESS}🛑 Grabación detenida. ¡Sesión guardada en el archivo logs!${COLOR_RESET}"
            echo -e "${COLOR_SUCCESS}👋 Saliendo de la consola Nexus. ¡Adiós!${COLOR_RESET}"
            # Guardar historial persistente
            history -w "$HIST_FILE"
            break
        fi
        
        # Agregar comando al historial del script
        history -s "$CMD"
        history -w "$HIST_FILE"
        
        # Obtener fechas y horas
        CURRENT_DATE=$(date +"%Y-%m-%d")
        CURRENT_TIME=$(date +"%H:%M:%S")
        
        # Escribir el encabezado del día si cambió o si el archivo no existe o no tiene la fecha actual
        DATE_HEADER="📅 FECHA: $CURRENT_DATE"
        if [ ! -f "$LOG_FILE" ] || ! grep -q "^$DATE_HEADER$" "$LOG_FILE"; then
            echo -e "\n=========================================" >> "$LOG_FILE"
            echo "$DATE_HEADER" >> "$LOG_FILE"
            echo -e "=========================================\n" >> "$LOG_FILE"
        fi
        
        # Evaluar si el comando es interactivo
        if is_interactive_command "$CMD"; then
            echo -e "${COLOR_SYSTEM}[Nexus: Comando interactivo detectado. Grabando sesión y salida...]${COLOR_RESET}"
            
            # Registrar sólo el inicio del comando interactivo en el log
            echo "[$CURRENT_TIME] Comando Interactivo: $CMD" >> "$LOG_FILE"
            echo "----------------------------------------" >> "$LOG_FILE"
            
            # Ejecutar a través del grabador PTY para registrar entrada y salida interactiva
            python3 /home/martin/Practicas/scripts/pty_recorder.py "$LOG_FILE" bash -c "$CMD"
            
            # Registrar fin de la sesión interactiva
            echo -e "\n----------------------------------------\n" >> "$LOG_FILE"
        else
            # Es un comando de ejecución directa (por ejemplo, consultas SQLite, scripts, etc.)
            # Registrar el comando en el log
            echo "[$CURRENT_TIME] Comando: $CMD" >> "$LOG_FILE"
            echo "----------------------------------------" >> "$LOG_FILE"
            
            # Crear un archivo temporal para capturar salida y error de forma conjunta
            TMP_OUT=$(mktemp)
            
            # Ejecutar el comando, capturando stdout y stderr en el archivo temporal
            eval "$CMD" > "$TMP_OUT" 2>&1
            EXIT_CODE=$?
            
            # Mostrar el resultado en pantalla para el usuario
            cat "$TMP_OUT"
            
            # Copiar el resultado al archivo de logs
            cat "$TMP_OUT" >> "$LOG_FILE"
            
            # Registrar el código de salida y dar respuesta visual en terminal
            if [ $EXIT_CODE -eq 0 ]; then
                STATUS_MSG="[ESTADO: OK (Código de salida: 0)]"
                echo -e "${COLOR_SUCCESS}✓ OK${COLOR_RESET}"
            else
                STATUS_MSG="[ESTADO: ERROR (Código de salida: $EXIT_CODE)]"
                echo -e "${COLOR_ERROR}✗ ERROR (Código: $EXIT_CODE)${COLOR_RESET}"
            fi
            
            # Escribir el estado en el log
            echo -e "\n$STATUS_MSG\n----------------------------------------\n" >> "$LOG_FILE"
            
            # Limpiar archivo temporal
            rm -f "$TMP_OUT"
        fi
    fi
done
