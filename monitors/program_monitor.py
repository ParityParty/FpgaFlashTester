import serial
import time
import sys

# --- Configuration ---
# Baud Rate: 2 * 115200 = 230400
BAUD_RATE = 115200 
# Target byte to count (0xA5 in hexadecimal)
TARGET_BYTE = 0xA5
# Serial port name (Change this to your actual port)
# On Windows, it might be 'COM3', 'COM4', etc.
# On Linux/macOS, it might be '/dev/ttyUSB0', '/dev/ttyACM0', etc.
SERIAL_PORT = '/dev/ttyUSB0' 
# How often to check for new data and print the status (in seconds)
READ_TIMEOUT = 0.1 
# --- End Configuration ---

def run_serial_counter():
    """
    Initializes the serial port, reads incoming data, and counts 
    occurrences of the TARGET_BYTE (0xA5), printing the count in real-time.
    """
    
    total_a5_count = 0
    target_hex = f"0x{TARGET_BYTE:02X}"
    print(f"Attempting to open port: {SERIAL_PORT} at {BAUD_RATE} baud...")

    try:
        # Open the serial connection
        ser = serial.Serial(
            port=SERIAL_PORT,
            baudrate=BAUD_RATE,
            timeout=READ_TIMEOUT # Timeout for read operations
        )
        print("Serial port opened successfully. Press Ctrl+C to stop.")
        
        while True:
            # Check for incoming data
            if ser.in_waiting > 0:
                # Read all available bytes
                data = ser.read(ser.in_waiting) 
                
                # Count the target byte in the received chunk
                # Using the built-in count method for efficiency
                chunk_a5_count = data.count(TARGET_BYTE.to_bytes(1, byteorder='big'))

                total_a5_count += chunk_a5_count
            
            # --- Real-Time Output Update ---
            # Use '\r' (carriage return) to move the cursor to the start of the line, 
            # effectively overwriting the previous output.
            # 'end=""' prevents a newline, and 'flush=True' ensures immediate update.
            bar_length = 100
            progress = int(bar_length * total_a5_count / 4096)
            sys.stdout.write(f"\rCurrent 0x{TARGET_BYTE:02X} count: {total_a5_count:>4} | [{'█' * progress}{' ' * (bar_length - progress)}] ")
            sys.stdout.flush()

            # Pause briefly to prevent excessive CPU usage
            time.sleep(0.01)

    except serial.SerialException as e:
        # Clear the line before printing the error
        sys.stdout.write('\r' + ' ' * 80 + '\r')
        sys.stdout.flush()
        print(f"\n[ERROR] Could not open or read from serial port {SERIAL_PORT}.")
        print(f"[ERROR] Details: {e}")
        print("Please check the port name, connection, and permissions.")
        sys.exit(1)
    except KeyboardInterrupt:
        # Clear the line before printing the final summary
        sys.stdout.write('\r' + ' ' * 80 + '\r')
        sys.stdout.flush()
        print("\nProgram interrupted by user (Ctrl+C).")
    finally:
        # Ensure the port is closed if it was opened
        if 'ser' in locals() and ser.is_open:
            ser.close()
            print("Serial port closed.")
        
        print(f"Final Total {target_hex} Count: {total_a5_count}")

if __name__ == "__main__":
    run_serial_counter()