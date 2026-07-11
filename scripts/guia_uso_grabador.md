# 🤖 Guía de Uso: Consola de Registro de Prácticas de Nexus

Esta guía detalla el funcionamiento de la herramienta optimizada para grabar tus prácticas de bases de datos y administración en Fedora 44, garantizando logs limpios de caracteres basura e ideales para copiar y pegar.

---

## 🚀 1. Cómo Iniciar la Consola

El sistema está totalmente integrado en tu entorno Fish. Para iniciar la consola:

1. Abre tu terminal de Fedora (Konsole, COSMIC Terminal, etc.).
2. Escribe el comando directo:
   ```bash
   grabar
   ```
   *(Este comando es un alias global que ejecuta el script [grabar_practica.sh](file:///home/martin/Practicas/scripts/grabar_practica.sh))*.

Verás el siguiente menú interactivo en tu pantalla:

```text
=========================================================
   🤖 CONSOLA DE REGISTRO DE PRÁCTICAS - NEXUS v1.1 🤖   
=========================================================
  - Escribe grabar para iniciar el registro de comandos.
  - Escribe fin para detener/pausar la grabación.
  - Escribe salir para cerrar el script.
  - Todos tus comandos registrados se guardarán en:
    /home/martin/Practicas/logs
  - Usa las flechas ↑ / ↓ para navegar por tu historial.
=========================================================

Nexus> 
```

---

## 🛠️ 2. Flujo de Trabajo y Comandos de Control

La consola tiene dos estados definidos por el prompt en tu terminal:

### A. Modo Control (`Nexus> `)
Es el estado de espera. Lo que escribas aquí no se grabará en el log.
* **`grabar`**: Inicia la sesión de grabación. El prompt cambiará a `Nexus-DB>`.
* **`salir`**: Cierra la consola y regresa a tu terminal Fish habitual.

### B. Modo Grabación Activo (`Nexus-DB> `)
Todo lo que escribas a partir de este punto y sus salidas se registrará en el archivo de log.
* **`fin`**: Pausa/Detiene la grabación actual y te devuelve al modo control (`Nexus> `).
* **`salir`**: Detiene la grabación y cierra la consola inmediatamente.

---

## 💻 3. Cómo Grabar Comandos y Consultas SQL

Una vez iniciado el modo grabación (`Nexus-DB>`), puedes correr dos tipos de comandos:

### Tipo 1: Comandos Directos
Comandos rápidos que devuelven salida inmediata y finalizan (ej: `ls`, `python3 reporte.py`).
* **Ejemplo:**
  ```text
  Nexus-DB> sqlite3 escuela.db "SELECT * FROM alumnos LIMIT 2;"
  ```
* **Comportamiento:** Se ejecuta, muestra el resultado en tu pantalla, escribe la salida en el log e imprime un estado visual: `✓ OK` o `✗ ERROR`.

### Tipo 2: Comandos Interactivos (Bases de Datos)
Clientes interactivos donde navegas y ejecutas consultas en tiempo real dentro de una interfaz de consola (ej: `sqlite3 escuela.db`, `pgcli`, `mycli`, `usql`).
* **Ejemplo:**
  ```text
  Nexus-DB> sqlite3 escuela.db
  ```
* **Comportamiento:** La consola detecta que el comando requiere una terminal interactiva (PTY). Abrirá el motor SQL transparente para ti.
* **Dentro del motor:** Trabaja normalmente. Puedes usar colores, autocompletado, cometer errores y corregirlos con *Backspace* o moverte con las flechas de dirección.
* **Al finalizar:** Escribe `.exit` (en sqlite), `exit` o `quit` para cerrar el motor interactivo de base de datos.
* **Procesamiento de Nexus:** Al salir, el grabador limpia de manera automática e invisible todos los caracteres de control ANSI y redibujos de readline en tu sesión, guardando en [logs](file:///home/martin/Practicas/logs) un histórico de texto plano limpio.

---

## 💾 4. Dónde Consultar y Copiar las Salidas

Todas las sesiones grabadas se concatenan ordenadamente por fecha y hora en el archivo plano:

📌 **Ruta del Log:** [logs](file:///home/martin/Practicas/logs)

> [!TIP]
> Puedes abrir este archivo con cualquier editor (VS Code, Zen Browser, o nano) o ver las últimas líneas directamente desde tu terminal usando:
> ```bash
> tail -n 50 /home/martin/Practicas/logs
> ```

### Ejemplo de cómo queda registrado en el archivo de logs:
```text
=========================================
📅 FECHA: 2026-07-11
=========================================

[10:12:15] Comando Interactivo: sqlite3 escuela.db
----------------------------------------
SQLite version 3.51.2 2026-01-09 17:27:48
Enter ".help" for usage hints.
sqlite> .header on
sqlite> .mode column
sqlite> SELECT * FROM alumnos WHERE nombre LIKE 'L%'
   ...> ;
id  nombre          edad
--  --------------  ----
5   Lucas Martínez  13  
12  Lucía Álvarez   16  
sqlite> .exit

----------------------------------------
```

---

## 💡 Consejos de Uso y Buenas Prácticas

> [!NOTE]
> **Historial del Consola:** La consola interactiva conserva tu historial entre sesiones. Puedes presionar las flechas **`↑` / `↓`** dentro de `Nexus-DB>` para volver a ejecutar comandos previos rápidamente.

> [!IMPORTANT]
> **Logs Inteligentes sin Basura:** Si durante tu sesión interactiva cometes un error de escritura (ej. escribes `.colum on` en vez de `.mode column`) y usas retroceso (*backspace*) para corregirlo, el motor de Nexus guardará la versión final corregida en el archivo de logs, manteniendo la limpieza y la legibilidad.

> [!WARNING]
> **Cierre Seguro:** Evita cerrar la terminal abruptamente usando la `X` de la ventana mientras estés en modo grabación interactiva. Siempre sal del cliente SQL con `.exit`/`exit` y luego usa el comando `salir` o `fin` en el prompt de Nexus. Esto garantiza que el buffer temporal se procese y se escriba correctamente en el log físico.
