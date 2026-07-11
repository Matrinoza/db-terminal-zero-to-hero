import os
import sys
import pty
import tempfile

class TerminalCleaner:
    def __init__(self):
        self.lines = []
        self.current_line = []
        self.x = 0
        self.in_escape = False
        self.escape_buffer = []

    def process_text(self, text):
        i = 0
        n = len(text)
        while i < n:
            char = text[i]
            
            if self.in_escape:
                self.escape_buffer.append(char)
                if len(self.escape_buffer) > 1:
                    if self.escape_buffer[1] != '[':
                        # 2-character escape sequence (like Esc > or Esc = or Esc O)
                        self.in_escape = False
                        self.process_escape_sequence()
                    elif len(self.escape_buffer) > 2 and ord(char) >= 0x40 and ord(char) <= 0x7E:
                        # CSI sequence ends with a character in the range @ to ~
                        self.in_escape = False
                        self.process_escape_sequence()
                    elif len(self.escape_buffer) > 100:
                        self.in_escape = False
                i += 1
                continue

            if char == '\x1b':  # ESC
                self.in_escape = True
                self.escape_buffer = [char]
            elif char == '\n':  # LF
                self.fill_line_to_cursor()
                self.lines.append("".join(self.current_line))
                self.current_line = []
                self.x = 0
            elif char == '\r':  # CR
                self.x = 0
            elif char == '\x08':  # BS (Backspace)
                self.x = max(0, self.x - 1)
            elif char == '\t':  # TAB
                spaces = 8 - (self.x % 8)
                self.write_chars(' ' * spaces)
            elif ord(char) >= 32 or char == '\x07':  # Printable characters or Bell (ignore bell)
                if char != '\x07':
                    self.write_chars(char)
            i += 1

    def write_chars(self, s):
        for char in s:
            self.fill_line_to_cursor()
            if self.x < len(self.current_line):
                self.current_line[self.x] = char
            else:
                self.current_line.append(char)
            self.x += 1

    def fill_line_to_cursor(self):
        if self.x > len(self.current_line):
            self.current_line.extend([' '] * (self.x - len(self.current_line)))

    def process_escape_sequence(self):
        seq = "".join(self.escape_buffer)
        if not seq.startswith('\x1b['):
            return

        cmd = seq[-1]
        params_str = seq[2:-1]
        
        # Parse params
        params = []
        if params_str:
            if params_str.startswith('?'):
                params_str = params_str[1:]
            try:
                params = [int(p) for p in params_str.split(';') if p.isdigit()]
            except ValueError:
                pass

        n = params[0] if params else 1

        if cmd == 'C':  # Cursor Forward
            self.x += n
        elif cmd == 'D':  # Cursor Backward
            self.x = max(0, self.x - n)
        elif cmd == 'K':  # Erase in Line
            mode = params[0] if params else 0
            self.fill_line_to_cursor()
            if mode == 0:    # Clear from cursor to end of line
                self.current_line = self.current_line[:self.x]
            elif mode == 1:  # Clear from beginning of line to cursor
                self.current_line = [' '] * self.x + self.current_line[self.x:]
            elif mode == 2:  # Clear entire line
                self.current_line = []
        elif cmd == 'P':  # Delete Characters
            self.fill_line_to_cursor()
            if self.x < len(self.current_line):
                del self.current_line[self.x : self.x + n]
        elif cmd == '@':  # Insert Characters
            self.fill_line_to_cursor()
            self.current_line[self.x:self.x] = [' '] * n

    def get_clean_text(self):
        if self.current_line:
            self.fill_line_to_cursor()
            self.lines.append("".join(self.current_line))
            self.current_line = []
        return "\n".join(self.lines)

def main():
    if len(sys.argv) < 3:
        print("Usage: pty_recorder.py <log_file> <command...>")
        sys.exit(1)
        
    log_file_path = sys.argv[1]
    cmd_args = sys.argv[2:]
    
    # We will write to a temporary file first
    temp_fd, temp_path = tempfile.mkstemp()
    
    try:
        with os.fdopen(temp_fd, 'wb') as temp_f:
            def read_callback(fd):
                data = os.read(fd, 1024)
                if data:
                    temp_f.write(data)
                    temp_f.flush()
                return data
                
            try:
                # pty.spawn handles forwarding stdin and restoring terminal state
                pty.spawn(cmd_args, read_callback)
            except Exception as e:
                sys.stderr.write(f"PTY Spawn Error: {e}\n")
    finally:
        # Post-process the recorded data and write clean version to main log
        try:
            if os.path.exists(temp_path):
                with open(temp_path, 'rb') as temp_f:
                    raw_data = temp_f.read()
                
                # Clean up temp file
                os.remove(temp_path)
                
                if raw_data:
                    cleaner = TerminalCleaner()
                    decoded_text = raw_data.decode('utf-8', errors='replace')
                    cleaner.process_text(decoded_text)
                    clean_content = cleaner.get_clean_text()
                    
                    # Append clean output to the main log file
                    with open(log_file_path, 'a', encoding='utf-8') as log_f:
                        log_f.write(clean_content)
        except Exception as e:
            sys.stderr.write(f"Post-processing Error: {e}\n")

if __name__ == '__main__':
    main()
