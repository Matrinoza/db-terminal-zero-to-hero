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
