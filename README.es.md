# CLI Data Parser & Filter

Un proyecto práctico que demuestra el filtrado y procesamiento de datos de bajo nivel mediante el uso de herramientas CLI nativas de Unix/Linux (awk, grep, cut) para replicar las operaciones de un motor de bases de datos relacionales.

## 🚀 Overview

Antes de sumergirse en los motores de bases de datos estructuradas (SQL), este proyecto explora cómo un analizador de shell lee, filtra y proyecta datos de archivos planos (formato CSV), demostrando el orden de ejecución lógica de una consulta de base de datos (FROM -> WHERE -> SELECT).

## 🛠️ Tech Stack

* **OS:** Fedora Linux / Arch Linux / Windows (PowerShell)
* **Shell Utilities:** GNU Awk, Grep, Cut, Bash

## 📈 Key Achievements
* Manejo de la arquitectura básica de archivos y redirección usando echo >>.
* Implementación de la conversión de tipos de datos numéricos en awk mediante evaluación aritmética (0+$3 > 20).
* Creación de tuberías con múltiples comandos CLI usando el pipe de Unix (|) para simular consultas estructurales.
