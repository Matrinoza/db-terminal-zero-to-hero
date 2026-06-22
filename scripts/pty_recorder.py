import os
import sys
import pty

def main():
    if len(sys.argv) < 3:
        print("Usage: pty_recorder.py <log_file> <command...>")
        sys.exit(1)
        
    log_file_path = sys.argv[1]
    cmd_args = sys.argv[2:]
    
    # Open log file in append binary mode
    with open(log_file_path, 'ab') as log_f:
        def read_callback(fd):
            data = os.read(fd, 1024)
            if data:
                # Write to log file
                log_f.write(data)
                log_f.flush()
            return data
            
        try:
            # pty.spawn handles forwarding stdin and restoring terminal state
            pty.spawn(cmd_args, read_callback)
        except Exception as e:
            sys.stderr.write(f"PTY Spawn Error: {e}\n")
            sys.exit(1)

if __name__ == '__main__':
    main()
