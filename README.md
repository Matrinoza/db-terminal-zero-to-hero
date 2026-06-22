# CLI Data Parser & Filter

A hands-on project demonstrating low-level data filtering and processing using native Unix/Linux CLI tools (`awk`, `grep`, `cut`) to replicate relational database engine operations.

## 🚀 Overview
Before diving into structured database engines (SQL), this project explores how a shell parser reads, filters, and projects data from flat files (CSV format), demonstrating the logical execution order of a database query (`FROM` -> `WHERE` -> `SELECT`).

## 🛠️ Tech Stack
* **OS:** Fedora Linux / Arch Linux / Windows (PowerShell)
* **Shell Utilities:** GNU Awk, Grep, Cut, Bash

## 📈 Key Achievements
* Handled basic file architecture and redirection using `echo >>`.
* Implemented numerical data-type casting in `awk` using arithmetic evaluation (`0+$3 > 20`).
* Pipelined multiple CLI commands using the Unix pipe (`|`) to simulate structural queries.

## 🛠️ Custom Tools: NEXUS Logger
To streamline the learning process and maintain a forensic record of all database interactions, this repository includes a custom Bash wrapper:
* **`grabar_practica.sh` (NEXUS):** An advanced logging script that captures all executed commands, standard output (stdout), standard error (stderr), and exit codes. It intelligently detects and bypasses interactive TUI commands (like `vim` or the `sqlite3` interactive prompt) to prevent logging corruption, saving all sessions dynamically in a timestamped log file.

## 📂 Repository Structure
```text
db-terminal-zero-to-hero/
├── .gitignore          # Excludes local databases, data dumps, and logs
├── README.md           # English documentation (Main)
├── README.es.md        # Spanish documentation (Mirror)
├── consultas.txt       # Initial practice notes
├── datos/              # Data playground directory
│   └── public/
│       └── logs/
│           └── servidor_v1.log
└── scripts/            # Automation scripts directory
    └── backup.sh
