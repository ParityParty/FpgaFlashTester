import os
import sys
from datetime import datetime
import time

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

# --- State Management ---
class UartState:
    """A class to hold and manage the state of the log file parser."""
    def __init__(self):
        self.current_block = 0
        self.e0_counter = 0
        self.last_byte_val = None
        self.is_line_busy = False # True if the last print was overwritable
        self.erase_failed = False
        self.capture_mode = False
        self.bad_bytes_in_block = 0
        self.capture_buffer = []
        self.done_counter = 0
        self.test_time = 0

        # State for the block testing sequence (0xA1 to 0xA5)
        self.is_testing_block = False
        self.current_test_byte_key = "AA"  # 'AA' or '55'
        self.block_test_stats = {
            'AA': {'prog': 0, 'read': 0, 'time': 0},
            '55': {'prog': 0, 'read': 0, 'time': 0}
        }
        self.test_phase = 0
        self.read_phase_time = 0

        # --- New variables for summary ---
        self.successful_blocks = 0
        self.failed_blocks = 0
        self.failed_block_list = []


    def reset_for_next_block(self):
        """Resets the testing stats for the next block."""
        self.is_testing_block = False
        self.erase_failed = False
        self.current_test_byte_key = "AA"
        self.bad_bytes_in_block = 0
        self.block_test_stats = {
            'AA': {'prog': 0, 'read': 0, 'time': 0},
            '55': {'prog': 0, 'read': 0, 'time': 0}
        }
        self.current_block += 1

    def handle_new_byte(self, byte_val):
        """Checks the last byte to reset counters or clear the line."""
        if self.last_byte_val not in [READ_PHASE_START, READ_PHASE_END, BLOCK_ERASE_FAIL, BLOCK_ERASE_OK, PROG_INCREMENT, READ_INCREMENT, BLOCK_TEST_COMPLETE, TEST_BYTE_CHANGED_NOTIFICATION] and self.is_line_busy:
            # If the last command was overwritable, print a newline to preserve
            # the status message before the next timestamped line begins.
            log_terminal()
            self.is_line_busy = False

        if byte_val != BLOCK_ERASE_FAIL:
            self.e0_counter = 0

        self.last_byte_val = byte_val

# --- Timestamp and Logging Helpers ---

def get_timestamp():
    """Returns the current time formatted as HH:MM:SS.mili"""
    now = datetime.now()
    return now.strftime("%H:%M:%S") + f".{now.microsecond // 1000:03d}"

def log_terminal(message="\n", omit_timestamp=False, runtime=0):
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

    sys.stdout.write(output)
    sys.stdout.flush()

# --- Main Functions ---

def update_block_test_display(state):
    """Displays the current block test status in an overwritable line."""
    prog_count = state.block_test_stats[state.current_test_byte_key]['prog']
    read_count = state.block_test_stats[state.current_test_byte_key]['read']

    if state.test_phase == 0:
        total_time = time.monotonic() - state.read_phase_time
    else:
        if state.current_test_byte_key == "AA":
            total_time = time.monotonic() - state.block_test_stats["AA"]["time"]
        else:
            total_time = time.monotonic() - state.block_test_stats["55"]["time"] + state.block_test_stats["AA"]["time"]
        total_time += state.read_phase_time

    if state.test_phase == 0:
        read_msg = f"Read cycle... {read_count:<5}"
        prog_msg = ""
    else:
        read_msg = "Read cycle... OK   "
        prog_msg = f"Program-read cycle... BYTE 0x{state.current_test_byte_key} | PROG: {prog_count:>3} | READ: {read_count:>3}   "

    total_steps = 128 + 256 * 2
    if state.test_phase == 0:
        current_steps = read_count
    else:
        s = state.block_test_stats
        current_steps = s["AA"]["read"] + s["AA"]["prog"] + 128
        if state.current_test_byte_key == "55":
            current_steps += s["55"]["read"] + s["55"]["prog"]

    progress_percent = min(100, max(0, (current_steps / total_steps) * 100))
    bar_length = 50
    filled_length = int(bar_length * progress_percent // 100)
    bar = '█' * filled_length + '-' * (bar_length - filled_length)

    message = f"\rBlock {state.current_block:<5} Testing...   {total_time:.3f}s   {read_msg}{prog_msg}"
    message = f"{message:<120}[{bar}] "

    log_terminal(message, runtime=time.monotonic() - state.test_time)
    state.is_line_busy = True

def print_summary(state):
    """Prints a final summary of the test results."""
    log_terminal("\n\n--- Test Summary ---\n", omit_timestamp=True)
    total_tested = state.successful_blocks + state.failed_blocks

    if total_tested == 0:
        log_terminal("No complete block tests were found in the log.\n", omit_timestamp=True)
        return

    run_time_str = f"{int(state.test_time / 60)} min {(state.test_time % 60):.2f} s"
    log_terminal(f"Total Test Time: {run_time_str}\n", omit_timestamp=True)
    log_terminal(f"Blocks Tested:   {total_tested}\n", omit_timestamp=True)
    log_terminal(f"Successful:      {state.successful_blocks}\n", omit_timestamp=True)
    log_terminal(f"Failed:          {state.failed_blocks}\n", omit_timestamp=True)

    if state.failed_blocks > 0:
        log_terminal("\nFailed Block Numbers:\n", omit_timestamp=True)
        # Group failed blocks into neat lines
        sorted_failures = sorted(state.failed_block_list)
        line = ""
        for block_num in sorted_failures:
            if len(line) + len(str(block_num)) > 70:
                log_terminal(f"  {line}\n", omit_timestamp=True)
                line = ""
            line += f"{block_num}, "
        if line:
            log_terminal(f"  {line.rstrip(', ')}\n", omit_timestamp=True)

def main():
    """Main function to parse the UART log file."""
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <log_file.bin>")
        sys.exit(1)

    input_filename = sys.argv[1]
    state = UartState()

    try:
        log_terminal(f"Attempting to open and read log file: {input_filename}\n")
        with open(input_filename, 'rb') as f:
            while True:
                byte = f.read(1)
                if not byte:
                    # End of file has been reached
                    break

                byte_val = int.from_bytes(byte, 'big')

                state.handle_new_byte(byte_val)

                if state.capture_mode:
                    state.capture_buffer.append(byte_val)
                    state.bytes_to_capture -= 1

                    if state.bytes_to_capture == 0:
                        # Full sequence received: [Addr_L, Addr_H, Data]
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
                            f"Block {state.current_block:<5} BAD BYTE in page {state.block_test_stats[state.current_test_byte_key]['read']} at 0x{address:04X} ({address:>4}) "
                            f"expected 0x{state.current_test_byte_key} was 0x{data:02X} (x{number})\n"
                        )
                        log_terminal(message, runtime=time.monotonic() - state.test_time)
                        state.bad_bytes_in_block += number
                        
                        # Reset capture state
                        state.capture_mode = False
                        state.capture_buffer = []

                    continue

                if byte_val == INIT_COMPLETE:
                    log_terminal()
                    log_terminal("Init complete, reseting...")
                    state = UartState()
                    state.test_time = time.monotonic()

                elif byte_val == DIE_RESET_SUCCESS:
                    log_terminal("\rInit complete, reseting... Done\n", runtime=time.monotonic() - state.test_time)

                elif byte_val == BAD_BYTE:
                    state.capture_mode = True
                    state.bytes_to_capture = 5

                elif byte_val == READ_PHASE_START:
                    state.is_testing_block = True
                    state.test_phase = 0
                    state.current_test_byte_key = "55"
                    state.read_phase_time = time.monotonic()

                elif byte_val == READ_PHASE_END:
                    state.test_phase = 1
                    state.current_test_byte_key = "AA"
                    state.read_phase_time = time.monotonic() - state.read_phase_time

                elif byte_val == BLOCK_ERASE_FAIL:
                    state.e0_counter += 1
                    msg = f"\rBlock {state.current_block:<5} 0x{state.current_test_byte_key} ERASE FAIL (x{state.e0_counter})"
                    log_terminal(msg, runtime=time.monotonic() - state.test_time)
                    state.is_line_busy = True

                elif byte_val == BLOCK_ERASE_FAIL_MOVE_ON:
                    if state.current_test_byte_key == '55':
                        state.erase_failed = True

                elif byte_val == BLOCK_ERASE_OK:
                    state.block_test_stats[state.current_test_byte_key] = {'prog': 0, 'read': 0, 'time': time.monotonic()}
                    update_block_test_display(state)

                elif byte_val == PROG_INCREMENT and state.is_testing_block:
                    state.block_test_stats[state.current_test_byte_key]['prog'] += 1
                    update_block_test_display(state)

                elif byte_val == READ_INCREMENT and state.is_testing_block:
                    state.block_test_stats[state.current_test_byte_key]['read'] += 1
                    update_block_test_display(state)

                elif byte_val == TEST_BYTE_CHANGED_NOTIFICATION:
                    timestamp = time.monotonic()
                    state.block_test_stats['AA']['time'] = timestamp - state.block_test_stats['AA']['time']
                    state.block_test_stats['55']['time'] = timestamp
                    state.current_test_byte_key = '55'

                elif byte_val == BLOCK_TEST_COMPLETE:
                    is_success = False
                    if not state.erase_failed:
                        timestamp = time.monotonic()
                        stats = state.block_test_stats
                        time_AA = stats['AA']['time']
                        time_55 = timestamp - stats['55']['time'] if stats['55']['time'] != 0 else 0

                        is_full_run = (stats['AA']['prog'] == 128 and stats['AA']['read'] == 128 and
                                       stats['55']['prog'] == 128 and stats['55']['read'] == 128)
                        
                        if state.bad_bytes_in_block == 0 and is_full_run:
                            is_success = True
                            state.successful_blocks += 1
                            msg = f"\rBlock {state.current_block:<5} {'OK':<13}{(time_AA + time_55 + state.read_phase_time):.3f}s   RD {state.read_phase_time:.3f}s   0xAA {time_AA:.3f}s   0x55 {time_55:.3f}s" + " " * 120 + "\n"
                            log_terminal(msg, runtime=time.monotonic() - state.test_time)
                        else:
                            log_terminal(f"\rBlock {state.current_block:<5} {'FAIL':<13}{(time_AA + time_55 + state.read_phase_time):.3f}s   Bad bytes: {state.bad_bytes_in_block}   RD {state.read_phase_time:.3f}s   0xAA {time_AA:.3f}s PROG: {stats['AA']['prog']} READ: {stats['AA']['read']}   0x55 {time_55:.3f}s PROG: {stats['55']['prog']} READ: {stats['55']['read']}{' '* 70}\n", runtime=time.monotonic() - state.test_time)

                    if not is_success:
                         state.failed_blocks += 1
                         state.failed_block_list.append(state.current_block)

                    state.reset_for_next_block()

                elif byte_val == FINISHED:
                    if state.done_counter == 0:
                        state.test_time = time.monotonic() - state.test_time if state.test_time != 0 else 0
                        log_terminal()

                    indicator = "." * ((state.done_counter % 4) + 1)
                    state.done_counter += 1
                    log_terminal(f"\r   {indicator:>4}  Test finished in {int(state.test_time / 60)} min {(state.test_time % 60):.2f} s {indicator:<4}    ", omit_timestamp=True)

                else:
                    log_terminal(f"Received unhandled byte: 0x{byte_val:02X}\n", runtime=time.monotonic() - state.test_time)
                    time.sleep(2)

    except FileNotFoundError:
        print(f"Error: File not found at '{input_filename}'", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        log_terminal("\nOperation cancelled by user.\n")
    finally:
        # The summary is printed here, after the loop finishes or is interrupted.
        print_summary(state)

if __name__ == "__main__":
    main()
