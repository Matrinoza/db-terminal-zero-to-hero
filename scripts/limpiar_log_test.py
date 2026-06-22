import re
import sys

def clean_terminal_output(raw_bytes):
    # 1. Decodificar UTF-8 correctamente (arregla caracteres rotos como Ã³ -> ó)
    text = raw_bytes.decode('utf-8', errors='replace')

    # 2. Eliminar secuencias ANSI y OSC (colores, bracketed paste, etc.)
    ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
    osc_escape = re.compile(r'\x1B\].*?(?:\x07|\x1B\\)')

    text = ansi_escape.sub('', text)
    text = osc_escape.sub('', text)

    # 3. Interpretar movimientos de cursor (\r y \b) para simular la escritura
    lines = []
    current_line = []
    cursor = 0

    for char in text:
        if char == '\n':
            lines.append("".join(current_line))
            current_line = []
            cursor = 0
        elif char == '\r':
            cursor = 0
        elif char == '\b' or char == '\x7f':  # Backspace o Delete
            cursor = max(0, cursor - 1)
        else:
            if cursor < len(current_line):
                current_line[cursor] = char
            else:
                # Rellenar con espacios si el cursor saltó
                current_line.extend([' '] * (cursor - len(current_line)))
                current_line.append(char)
            cursor += 1

    if current_line:
        lines.append("".join(current_line))

    # 4. Limpiar espacios finales para que quede prolijo
    return '\n'.join(line.rstrip() for line in lines)

def main():
    if len(sys.argv) < 3:
        print("Uso: python3 limpiar_log.py <input_file> <output_file>")
        sys.exit(1)

    with open(sys.argv[1], 'rb') as f:
        raw_data = f.read()

    cleaned_text = clean_terminal_output(raw_data)

    with open(sys.argv[2], 'w', encoding='utf-8') as f:
        f.write(cleaned_text)

if __name__ == '__main__':
    main()
