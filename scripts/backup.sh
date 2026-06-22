#!/bin/bash

# Configuración de rutas absolutas
DB_PATH="/home/martin/Practicas/scripts/escuela.db"
BACKUP_PATH="/home/martin/Practicas/Backups/escula_backup.bak"

# Crear directorio de backups si no existe
mkdir -p "$(dirname "$BACKUP_PATH")"

# Función para realizar el backup
realizar_backup() {
    echo "⚙️ Iniciando respaldo de la base de datos..."
    if [ ! -f "$DB_PATH" ]; then
        echo "❌ Error: El archivo de base de datos $DB_PATH no existe."
        exit 1
    fi
    
    # Ejecutar el comando .backup de SQLite
    sqlite3 "$DB_PATH" ".backup '$BACKUP_PATH'"
    
    if [ $? -eq 0 ]; then
        echo "💾 ¡Respaldo completado con éxito!"
        echo "📍 Guardado en: $BACKUP_PATH"
        ls -la "$BACKUP_PATH"
    else
        echo "❌ Error al realizar el respaldo."
        exit 1
    fi
}

# Función para realizar la restauración
realizar_restauracion() {
    echo "⚙️ Iniciando restauración de la base de datos..."
    if [ ! -f "$BACKUP_PATH" ]; then
        echo "❌ Error: No existe ningún archivo de respaldo en $BACKUP_PATH para restaurar."
        exit 1
    fi
    
    # Confirmación de seguridad
    if [ "$1" != "--force" ]; then
        read -p "⚠️ Esto sobrescribirá la base de datos actual en $DB_PATH. ¿Continuar? (s/n): " confirmacion
        if [[ ! "$confirmacion" =~ ^[sS]$ ]]; then
            echo "🚫 Operación cancelada por el usuario."
            exit 0
        fi
    fi
    
    # Ejecutar el comando .restore de SQLite
    sqlite3 "$DB_PATH" ".restore '$BACKUP_PATH'"
    
    if [ $? -eq 0 ]; then
        echo "✅ ¡Base de datos restaurada con éxito desde $BACKUP_PATH!"
        ls -la "$DB_PATH"
    else
        echo "❌ Error al restaurar la base de datos."
        exit 1
    fi
}

# Mostrar uso si se solicita ayuda
mostrar_ayuda() {
    echo "Uso: $0 [backup | restore | --help]"
    echo "  backup    : Realiza un respaldo de la base de datos activa."
    echo "  restore   : Restaura la base de datos desde el último respaldo."
    echo "  --force   : Ejecuta la restauración sin pedir confirmación (ej: ./backup.sh restore --force)."
}

# Lógica de argumentos
case "$1" in
    backup)
        realizar_backup
        ;;
    restore)
        if [ "$2" == "--force" ]; then
            realizar_restauracion "--force"
        else
            realizar_restauracion
        fi
        ;;
    -h|--help)
        mostrar_ayuda
        ;;
    *)
        # Modo interactivo si no se especifican argumentos
        echo "========================================="
        echo "🤖 Gestor de Backup & Restore - Escuela DB"
        echo "========================================="
        echo "1) Realizar un respaldo (Backup)"
        echo "2) Restaurar base de datos (Restore)"
        echo "3) Salir"
        read -p "Seleccione una opción [1-3]: " opcion
        case "$opcion" in
            1) realizar_backup ;;
            2) realizar_restauracion ;;
            3) echo "👋 ¡Hasta luego!"; exit 0 ;;
            *) echo "❌ Opción no válida."; exit 1 ;;
        esac
        ;;
esac
