import serial
import os
import sys
from datetime import datetime
import time

# --- Configuration ---
SERIAL_PORT = '/dev/ttyUSB0'
BAUD_RATE = 460800 / 4
LOG_DIR = './logs'
READ_TIMEOUT = 1  # seconds

# --- Protocol Bytes (for clarity) ---
INIT_COMPLETE = 0x53
DIE_RESET_SUCCESS = 0xA0
READ_PHASE_START = 0xA6
READ_PHASE_END = 0xA7
BLOCK_ERASE_FAIL = 0xE0
BLOCK_ERASE_FAIL_MOVE_ON = 0xE1
BLOCK_ERASE_OK = 0xA1
PROG_INCREMENT = 0xA2
READ_INCREMENT = 0xA3
TEST_BYTE_CHANGED_NOTIFICATION = 0xA4
BLOCK_TEST_COMPLETE = 0xA5
BAD_BYTE = 0xE4
FINISHED = 0xDD

# --- State Management (Simplified for Read-Only) ---
class UartState:
    """A class to hold and manage the state of the UART monitor."""
    def __init__(self):
        self.current_block = 0
        self.last_byte_val = None
        self.is_line_busy = False # True if the last print was overwritable
        self.capture_mode = False
        self.bad_bytes_in_block = 0
        self.capture_buffer = []
        self.done_counter = 0
        self.test_time = 0

        # State for the block testing sequence (A6 to A5)
        self.is_testing_block = False
        self.block_test_stats = {'read': 0}
        self.block_start_time = 0
        self.current_test_byte_key = "55" # Byte expected during read phase

    def reset_for_next_block(self):
        """Resets the testing stats for the next block."""
        self.is_testing_block = False
        self.bad_bytes_in_block = 0
        self.block_test_stats = {'read': 0}
        self.block_start_time = 0
        self.current_test_byte_key = "55"
        self.current_block += 1

    def handle_new_byte(self, byte_val):
        """Checks the last byte to reset counters or clear the line."""
        # Simplified list of overwritable commands
        if self.last_byte_val not in [READ_PHASE_START, READ_INCREMENT, BLOCK_TEST_COMPLETE, FINISHED] and self.is_line_busy:
            # If the last command was overwritable, print a newline to preserve
            # the status message before the next timestamped line begins.
            log_terminal()
            self.is_line_busy = False
            
        self.last_byte_val = byte_val

# --- Timestamp and Logging Helpers ---

def get_timestamp():
    """Returns the current time formatted as HH:MM:SS.mili"""
    now = datetime.now()
    # Format: HH:MM:SS.mili
    return now.strftime("%H:%M:%S") + f".{now.microsecond // 1000:03d}"

def log_terminal(message="\n", file=sys.stdout, omit_timestamp=False, runtime=0):
    """
    Prints a message to the terminal, prepending a timestamp.
    Handles messages starting with '\r' specially for overwritable status lines.
    """
    runtime_str = f"{int(runtime / 60)}:{(runtime % 60):>05.2f}"
    timestamp = f"[{get_timestamp()}]   {runtime_str:>8}   " if message != "\n" and not omit_timestamp else ""

    if message.startswith('\r'):
        # Overwritable line: Insert timestamp after '\r'
        output = f"\r{timestamp}{message[1:]}"
    else:
        # Standard line: Prepend timestamp
        output = f"{timestamp}{message}"

    file.write(output)
    file.flush()

# --- Main Functions ---

def setup_logging():
    """Creates the log directory and a unique log file for the current run."""
    try:
        if not os.path.exists(LOG_DIR):
            os.makedirs(LOG_DIR)
        
        timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        log_filename = os.path.join(LOG_DIR, f"uart_log_{timestamp}.bin")
        
        # Open in binary append mode
        log_file = open(log_filename, 'ab')
        log_terminal(f"Logging raw bytes to {log_filename}\n")
        return log_file
    except OSError as e:
        log_terminal(f"Error: Could not create log file/directory: {e}\n", file=sys.stderr)
        return None

def update_block_test_display(state):
    """Displays the current block test status in an overwritable line."""

    read_count = state.block_test_stats['read']
    total_time = 0
    if state.block_start_time > 0:
         total_time = time.monotonic() - state.block_start_time

    read_msg = f"Read cycle... {read_count:<5}"
    
    total_steps = 128 # 128 read increments
    current_steps = read_count

    # Calculate percentage and create bar
    progress_percent = min(100, max(0, (current_steps / total_steps) * 100))
    bar_length = 50 # Length of the progress bar string
    filled_length = int(bar_length * progress_percent // 100)
    bar = '█' * filled_length + '-' * (bar_length - filled_length)

    message = f"\rBlock {state.current_block:<5} Testing...   {total_time:.3f}s   {read_msg}"
    message = f"{message:<120}[{bar}] "

    # Use log_terminal, which handles the '\r' and timestamp insertion
    log_terminal(message, runtime=time.monotonic() - state.test_time)
    state.is_line_busy = True

def main():
    """Main function to run the UART monitor."""
    log_file = setup_logging()
    if not log_file:
        sys.exit(1)

    state = UartState()
    ser = None

    try:
        log_terminal(f"Attempting to open serial port {SERIAL_PORT} at {BAUD_RATE} baud...\n")
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=READ_TIMEOUT)
        log_terminal("Serial port opened successfully. Waiting for data...\n")

        while True:
            byte = ser.read(1)

            # If read timed out, continue waiting
            if not byte:
                continue

            # Log every byte received to file
            log_file.write(byte)
            log_file.flush()

            byte_val = int.from_bytes(byte, 'big')
            
            # --- State Handling ---
            state.handle_new_byte(byte_val)

            if state.capture_mode:
                state.capture_buffer.append(byte_val)
                state.bytes_to_capture -= 1

                if state.bytes_to_capture == 0:
                    # Full sequence received: [Addr_L, Addr_H, Data, Num_L, Num_H]
                    addr_l = state.capture_buffer[0]
                    addr_h = state.capture_buffer[1]
                    data = state.capture_buffer[2]
                    number_l = state.capture_buffer[3]
                    number_h = state.capture_buffer[4]
                    
                    # Address is Little Endian: (Addr_H * 256) + Addr_L
                    address = (addr_h << 8) | addr_l
                    number = (number_h << 8) | number_l
                    
                    # Output message
                    message = (
                        f"Block {state.current_block:<5} BAD BYTE in page {state.block_test_stats['read']} at 0x{address:04X} ({address:>4}) "
                        f"expected 0x{state.current_test_byte_key} was 0x{data:02X} (x{number})\n"
                    )
                    log_terminal(message, runtime=time.monotonic() - state.test_time)
                    state.bad_bytes_in_block += number
                    
                    # Reset capture state
                    state.capture_mode = False
                    state.capture_buffer = []

                continue # Skip normal interpretation if currently capturing data

            # --- Byte Interpretation (Read-Only Phase) ---
            if byte_val == INIT_COMPLETE:
                log_terminal()
                log_terminal("Init complete, reseting...")
                state = UartState()
                state.test_time = time.monotonic()
            
            elif byte_val == DIE_RESET_SUCCESS:
                log_terminal("\rInit complete, reseting... Done\n", runtime=time.monotonic() - state.test_time)

            elif byte_val == BAD_BYTE:
                # Expects 5 bytes: [Addr_L, Addr_H, Data, Num_L, Num_H]
                state.capture_mode = True
                state.bytes_to_capture = 5

            elif byte_val == READ_PHASE_START:
                state.is_testing_block = True
                state.current_test_byte_key = "55" # This phase reads 0x55
                state.block_start_time = time.monotonic()
                update_block_test_display(state)
        
            # --- Removed READ_PHASE_END (A7) ---
            
            # --- Removed ERASE/PROG bytes (E0, E1, A1, A2, A4) ---

            elif byte_val == READ_INCREMENT and state.is_testing_block:
                state.block_test_stats['read'] += 1
                update_block_test_display(state)
            
            elif byte_val == BLOCK_TEST_COMPLETE:
                timestamp = time.monotonic()
                stats = state.block_test_stats
                total_time = 0
                if state.block_start_time > 0:
                    total_time = timestamp - state.block_start_time

                if (state.bad_bytes_in_block == 0
                    and stats['read'] == 128):
                    # Use '\r' to overwrite the status line, clear it, and '\n' to finalize.
                    msg = f"\rBlock {state.current_block:<5} {'OK':<13}{total_time:.3f}s" + " " * 140 + "\n"
                    log_terminal(msg, runtime=time.monotonic() - state.test_time)
                    state.is_line_busy = True # To prevent timestamp on next line
                else:
                    msg = f"\rBlock {state.current_block:<5} {'FAIL':<13}{total_time:.3f}s   Bad bytes: {state.bad_bytes_in_block}   READ: {stats['read']}{' '* 70}\n"
                    log_terminal(msg, runtime=time.monotonic() - state.test_time)
                
                state.reset_for_next_block()

            elif byte_val == FINISHED:
                if state.done_counter == 0:
                    state.test_time = time.monotonic() - state.test_time if state.test_time != 0 else 0
                    # log_terminal() # Newline before finish message

                # Simple spinning indicator
                indicator = "." * (1 + (state.done_counter % 4))
                state.done_counter += 1
                log_terminal(f"\r   {indicator:>4}  Test finished in {int(state.test_time / 60)} min {(state.test_time % 60):.2f} s {indicator:<4}    ", omit_timestamp=True)
                state.is_line_busy = True

            else:
                # Print any other byte that is not part of a special sequence
                log_terminal(f"Received unhandled byte: 0x{byte_val:02X}\n", runtime=time.monotonic() - state.test_time)

    except serial.SerialException as e:
        log_terminal(f"Error: Could not open or read from serial port {SERIAL_PORT}: {e}\n", file=sys.stderr)
    except KeyboardInterrupt:
        log_terminal("\nExiting program.\n")
    finally:
        if state.is_line_busy:
            log_terminal() # Print a final newline
        if ser and ser.is_open:
            ser.close()
            log_terminal("Serial port closed.\n")
        if log_file:
            log_file.close()
            log_terminal("Log file closed.\n")

if __name__ == "__main__":
    main()