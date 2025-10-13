import serial
from serial.serialutil import SerialException
import time
import sys

# --- Configuration ---
PORT = '/dev/ttyUSB0'
BAUD_RATE = 115200

# The target bytes we are looking for (0xA1 starts a block, 0xA4 ends it. 0xA2 and 0xA3 are counted within)
BYTE_A1 = 0xA1  # 161 in decimal (Block START Marker / Block Erase Success)
BYTE_A4 = 0xA4  # 164 in decimal (Block END Marker)
BYTE_A2 = 0xA2  # 162 in decimal (Page Program Success Count)
BYTE_A3 = 0xA3  # 163 in decimal (Page Read Success Count)
BYTE_E6 = 0xE6  # 230 in decimal (Address/Data Follow-up Error)
BYTE_A0 = 0xA0  # 160 in decimal (Die Reset Success) # Defining A0 for clarity

LOG_FILE = 'serial_log.bin' # File where all raw incoming bytes will be logged
# ---------------------

# Mapping for status and error codes provided by the user
STATUS_CODES = {
    0xA0: "die reset successful",
    0xA1: "block erase successful", # Also used as the Block START marker
    0xA2: "page program success",   # Also used as the Page Write counter
    0xA3: "page read success",      # Also used as the Page Read counter
    0xE1: "erase command not received",
    0xE2: "erase failed (bad block)",
    0xE3: "program command not received",
    0xE4: "program failed",
    0xE5: "read command not received",
    0xE6: "error: address/data expected",
}


def run_byte_counter():
    """
    Initializes the serial port and continuously reads data.
    It counts occurrences of BYTE_A2 (Page Programs) and BYTE_A3 (Page Reads) between a BYTE_A1 start marker and 
    a BYTE_A4 end marker, reports all status/error bytes, logs all raw bytes to a file, and measures block duration.
    It also handles a special 3-byte capture sequence (2 address, 1 data) upon receiving 0xE6.
    The address is now interpreted using Little Endian byte order.
    """
    print(f"Attempting to connect to {PORT} at {BAUD_RATE} baud...")
    
    try:
        # Open the serial port
        ser = serial.Serial(
            port=PORT,
            baudrate=BAUD_RATE,
            timeout=1,          # Read timeout in seconds
            write_timeout=1     # Write timeout in seconds
        )
        print("Connection successful. Monitoring incoming bytes...")
        print("Press Ctrl+C to stop the script.")

    except SerialException as e:
        print(f"\n--- ERROR: Could not open serial port {PORT} ---")
        print("Please ensure:")
        print("1. The device is connected (e.g., Arduino, UART adapter).")
        print("2. You have the correct permissions (e.g., you might need to run with 'sudo' or be in the 'dialout' group on Linux).")
        print(f"Underlying error: {e}")
        sys.exit(1)

    # State variables for sequence tracking
    segment_active = False # True when 0xA1 has been received and 0xA4 is pending
    a2_program_count = 0   # Counts A2 bytes (Page Program Success) within the active block
    a3_read_count = 0      # Counts A3 bytes (Page Read Success) within the active block
    block_number = 0       # Tracks the number of completed blocks
    block_start_time = None # Time when the current block started (using time.monotonic())
    log_file = None        # Handle for the log file

    # New state variables for E6 capture
    capture_mode = False   # True when 0xE6 has been received and 3 bytes are expected
    capture_buffer = []    # Buffer to hold the 3 bytes (2 address, 1 data)
    BYTES_TO_CAPTURE = 3  # (2 Address bytes + 1 Data byte)
    
    try:
        # Attempt to open the log file for binary appending
        log_file = open(LOG_FILE, 'ab')
        print(f"All incoming bytes will be saved to: {LOG_FILE}")
    except IOError as e:
        print(f"\n--- WARNING: Could not open log file {LOG_FILE} ---")
        print(f"Logging will be disabled. Error: {e}")
        # log_file remains None, so logging calls will be skipped

    try:
        while True:
            # Read one byte from the serial buffer
            byte_read = ser.read(1)

            if byte_read:
                # Write the raw byte to the log file (if successfully opened)
                if log_file:
                    log_file.write(byte_read)
                    
                # byte_read is a bytes object (e.g., b'\xa1'). Get the integer value.
                current_byte_int = byte_read[0]

                # --- HIGH PRIORITY ADDRESS CAPTURE LOGIC (overrides normal processing) ---
                if capture_mode:
                    capture_buffer.append(current_byte_int)
                    
                    # Check if we have collected all 3 bytes (2 Address, 1 Data)
                    if len(capture_buffer) == BYTES_TO_CAPTURE:
                        address_bytes = capture_buffer[0:2] # Take first 2 bytes for address
                        data_byte = capture_buffer[2]       # Take 3rd byte for data
                        
                        # Convert 2 bytes into a single 16-bit address integer (LSB first assumed - Little Endian)
                        # The first byte (index 0) is LSB, the second byte (index 1) is MSB.
                        address = (address_bytes[1] << 8) | address_bytes[0]
                        
                        # Print the address in Hex and Numerical (Little Endian) value
                        print(f"[E6 CAPTURE] Address: 0x{address:04x} (Numerical LE: {address}) (Bytes: 0x{address_bytes[0]:02x} 0x{address_bytes[1]:02x}) | Data: 0x{data_byte:02x}\n")
                        
                        # Reset state and return to normal block counting
                        capture_mode = False
                        capture_buffer = []
                        # Restore continuous update line if block is active
                        if segment_active:
                            print(f"Current Programs: {a2_program_count} | Current Reads: {a3_read_count}\r", end="")
                            
                    # Skip the rest of the loop until capture is complete
                    continue 
                # --- END HIGH PRIORITY ADDRESS CAPTURE LOGIC ---

                # --- Core Counting Logic ---
                if current_byte_int == BYTE_A0:
                    # Handle A0 Reset: Reset all tracking variables
                    print(f"\n[RESET] Received 0x{current_byte_int:02x}: {STATUS_CODES[current_byte_int]}. Resetting all block counters and state.")
                    segment_active = False
                    a2_program_count = 0
                    a3_read_count = 0
                    block_number = 0
                    block_start_time = None  # Reset block duration timer
                    capture_mode = False
                    capture_buffer = []
                    print() # Ensure a newline after the reset message
                
                elif current_byte_int == BYTE_A1:
                    # An A1 marker was received (Block START)
                    
                    if not segment_active:
                        # Start a new block
                        segment_active = True
                        a2_program_count = 0 # Reset counters for the new block
                        a3_read_count = 0
                        block_start_time = time.monotonic() # Start the timer
                        print(f"0x{BYTE_A1:02x} received. Starting count for Page Programs (0x{BYTE_A2:02x}) and Page Reads (0x{BYTE_A3:02x}) until 0x{BYTE_A4:02x}.")
                    else:
                        # A1 received mid-block
                        print(f"\n[INFO] Received 0x{BYTE_A1:02x} mid-block. Ignoring block state change.")
                        # Restart the continuous update line to overwrite the INFO message
                        print(f"Current Programs: {a2_program_count} | Current Reads: {a3_read_count}\r", end="")

                elif current_byte_int == BYTE_A4:
                    # An A4 marker was received (Block END)
                    
                    if segment_active:
                        # Case 1: This is the closing A4 (A1 ... A4 sequence complete)
                        block_number += 1
                        
                        # Calculate duration
                        duration_sec = 0.0
                        if block_start_time is not None:
                            duration_sec = time.monotonic() - block_start_time

                        # Define the validation count
                        VALID_COUNT = 128
                        
                        # Conditional Output Logic
                        if a2_program_count == VALID_COUNT and a3_read_count == VALID_COUNT:
                            # Print simplified "valid" message
                            print(f"\nblock {block_number} valid (Duration: {duration_sec:.4f}s)")
                            print() # Add a final empty line for separation
                        else:
                            # Output the detailed block number and counts using newlines
                            print(f"\n\nBlock {block_number} Closed by 0x{BYTE_A4:02x} (Duration: {duration_sec:.4f}s):")
                            print(f"Block contained:")
                            print(f"  - {a2_program_count} Page Program Success (0x{BYTE_A2:02x})")
                            print(f"  - {a3_read_count} Page Read Success (0x{BYTE_A3:02x})")
                            print() # Add a final empty line for separation
                        
                        # Reset state
                        segment_active = False
                        block_start_time = None 
                    else:
                        # A4 received when block is inactive
                        print(f"\n[INFO] Received 0x{BYTE_A4:02x} while block inactive. Ignoring.")

                elif segment_active:
                    # Byte received while a block is active (A2, A3, E6, or other)

                    if current_byte_int == BYTE_E6:
                        # Initiate address capture mode
                        capture_mode = True
                        capture_buffer = []
                        print(f"\n[STATUS] Received 0x{BYTE_E6:02x}: {STATUS_CODES[BYTE_E6]}. Entering address capture mode.")
                        continue # Skip the rest of the processing and wait for the next byte

                    # Check for A2/A3
                    updated = False
                    if current_byte_int == BYTE_A2:
                        a2_program_count += 1
                        updated = True
                    elif current_byte_int == BYTE_A3:
                        a3_read_count += 1
                        updated = True
                    
                    if updated:
                        # Use \r for a continuous update on the current line
                        print(f"Current Programs: {a2_program_count} | Current Reads: {a3_read_count}\r", end="")
                    else:
                        # Other byte received mid-block: check if it's a defined status code
                        status_message = STATUS_CODES.get(current_byte_int)
                        if status_message:
                            print(f"\n[STATUS] Received 0x{current_byte_int:02x}: {status_message}")
                        else:
                            print(f"\n[INFO] Received unknown byte 0x{current_byte_int:02x} inside active block.")
                        # Restart the continuous update line to overwrite the INFO/STATUS message
                        print(f"Current Programs: {a2_program_count} | Current Reads: {a3_read_count}\r", end="")
                
                else:
                    # Byte received while no block is active (and not A1, A4, or A0)
                    status_message = STATUS_CODES.get(current_byte_int)
                    
                    # We check for A1/A4/A0 here too, just in case, but they are generally handled above
                    if status_message and current_byte_int not in [BYTE_A1, BYTE_A4, BYTE_A0]: 
                        print(f"\n[STATUS] Received 0x{current_byte_int:02x}: {status_message}")
                    else:
                        # Only print INFO for truly unknown bytes outside the main handlers
                        if current_byte_int not in [BYTE_A1, BYTE_A4, BYTE_A0]:
                            print(f"\n[INFO] Received unknown byte 0x{current_byte_int:02x} outside any block.")

    except KeyboardInterrupt:
        print("\n\nScript interrupted by user (Ctrl+C). Closing serial port and log file.")
    
    finally:
        # Clean up and close the serial port
        if 'ser' in locals() and ser.is_open:
            ser.close()
        # Clean up and close the log file
        if log_file:
            log_file.close()
            print(f"Log file {LOG_FILE} closed.")
            
        print("Serial port closed. Exiting.")


if __name__ == "__main__":
    run_byte_counter()
