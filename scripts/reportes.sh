#!/bin/bash

# Definicion de una variable con la fecha actual (Formato: Año-Mes-Día)
FECHA=$(date +%Y-%m-%d)

# Deficion del nombre del archivo de salida usando la variable
ARCHIVO_SALIDA="/home/martin/Practicas/datos/reporte_edades_$FECHA.txt"

#  Mensajes para el usuario (estos salen por la terminal, NO van al archivo)
echo "Iniciando conexión con la base de datos..."
echo "Generando reporte para la fecha: $FECHA"

# Ejecución de la consulta. La redirección (>)
sqlite3 -column -header /home/martin/Practicas/DB/escuela.db "SELECT * FROM students ORDER BY age DESC"; > reporte_edades.txt


# Confirmación final
echo "¡Éxito! El reporte limpio se ha guardado en: $ARCHIVO_SALIDA"
