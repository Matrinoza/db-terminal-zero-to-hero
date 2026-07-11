#!/usr/bin/env python3
import sqlite3
import json

# 1. CONEXIÓN: Apuntamos a la base de datos (ajusta la ruta si es distinta)
# Como ejecutaremos esto desde la raíz ~/Practicas, la base está ahí mismo.
ruta_db = 'escuela.db'
ruta_json = 'datos/reporte_edades.json'

try:
    print(f"Conectando a {ruta_db}...")
    conexion = sqlite3.connect(ruta_db)
    
    # El cursor es nuestro "dedo" que apunta y ejecuta cosas dentro de la BD
    cursor = conexion.cursor()

    # 2. CONSULTA: Escribimos el string de SQL
    query = "SELECT edad, COUNT(*) FROM alumnos GROUP BY edad;"
    cursor.execute(query)
    
    # .fetchall() trae todos los resultados y los guarda en una lista de tuplas
    resultados = cursor.fetchall()
    print(f"Datos extraídos correctamente. Procesando {len(resultados)} grupos de edades...")

    # 3. TRANSFORMACIÓN: Convertimos las tuplas de SQL a un formato diccionario (compatible con JSON)
    datos_estructurados = []
    for fila in resultados:
        edad_alumno = fila[0]
        cantidad = fila[1]
        
        datos_estructurados.append({
            "edad": edad_alumno,
            "total_alumnos": cantidad
        })

    # 4. EXPORTACIÓN: Guardamos la lista estructurada en un archivo .json
    with open(ruta_json, 'w') as archivo_json:
        # indent=4 lo formatea bonito para que sea legible por humanos
        json.dump(datos_estructurados, archivo_json, indent=4)
        
    print(f"¡Éxito! El reporte se generó en {ruta_json}")

except sqlite3.Error as error:
    print(f"Error fatal de SQLite: {error}")

finally:
    # 5. LIMPIEZA: Siempre hay que cerrar la conexión para no bloquear la base de datos
    if conexion:
        conexion.close()
        print("Conexión cerrada.")
