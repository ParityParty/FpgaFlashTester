import os
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# --- Protocol Bytes ---
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

PAGES_IN_BLOCK = 128
BYTES_IN_PAGE = 8640

TOTAL_BLOCKS = 512
TOTAL_PAGES = TOTAL_BLOCKS * PAGES_IN_BLOCK
TOTAL_BYTES = TOTAL_PAGES * BYTES_IN_PAGE
TOTAL_BITS = TOTAL_BYTES * 8

DOSES_IN_WATER = [0, 111.5,178.3,261.8,378.7,646.0]
DOSES_ADJUSTED = list(map(lambda x: x*0.898, DOSES_IN_WATER))
STATE_0 = [[], [], [[414, 1, 36, 0x51, 1]], [[113, 1, 4273, 0x51, 1]], [], []]


def count_bad_bits(expected, actual):
    bad_bits = 0
    for i in range(0,8):
        if (actual >> i) & 1 != (expected >> i) & 1:
            bad_bits += 1
    return bad_bits


# --- State Management (Simplified for Read-Only) ---
class UartState:
    """A class to hold and manage the state of the UART monitor."""
    def __init__(self):
        self.current_block = 0
        self.capture_mode = False
        self.bad_bytes_in_block = 0
        self.capture_buffer = []
        self.done_counter = 0

        self.is_testing_block = False
        self.block_test_stats = {'read': 0}
        self.current_test_byte_key = "55" # Byte expected during read phase

    def reset_for_next_block(self):
        """Resets the testing stats for the next block."""
        self.is_testing_block = False
        self.bad_bytes_in_block = 0
        self.block_test_stats = {'read': 0}
        # self.block_start_time = 0 # Removed time measuring
        self.current_test_byte_key = "55"
        self.current_block += 1


class CheckStats:
    def __init__(self):
        self.errors = {}
        self.bad_byte_types = {}
        self.pages_with_errors = {}  # key - number of errors, value - number of pages with this number of errors
        self.bad_blocks = 0
        self.bad_pages = 0
        self.bad_bytes = 0
        self.bad_bits = 0

    def add_error(self, block, page, address, value, number):
        if block not in self.errors:
            self.errors[block] = {}
            self.bad_blocks += 1

        if page not in self.errors[block]:
            self.errors[block][page] = {}
            self.bad_pages += 1
        
        self.errors[block][page][address] = {'value':value, 'number': number}
        self.bad_bytes += number

        if value not in self.bad_byte_types:
            self.bad_byte_types[value] = 0
        self.bad_byte_types[value] += number
        self.bad_bits += count_bad_bits(0x55, value) * number
    

    def plot_scatter(self, plot_filename):
        blocks = []
        pages = []
        bytes_addr = []

        # Iterate through the nested dictionary to get the x, y, z coordinates
        for block_num, pages_data in self.errors.items():
            for page_num, bytes_data in pages_data.items():
                for byte_num, info in bytes_data.items():
                    # Each key (block_num, page_num, byte_num) is a coordinate
                    blocks.append(block_num)
                    pages.append(page_num)
                    for i in range(0,info['number']):
                        bytes_addr.append(byte_num + i)

        # Check if we actually extracted any data points
        plot_3d_filename = f'{plot_filename}_3d.png'
        plot_xy_filename = f'{plot_filename}_xy.png'
        plot_xz_filename = f'{plot_filename}_xz.png'
        plot_yz_filename = f'{plot_filename}_yz.png'

        min_block, max_block = 0, TOTAL_BLOCKS - 1
        min_page, max_page = 0, PAGES_IN_BLOCK - 1
        min_byte, max_byte = 0, BYTES_IN_PAGE - 1

        # --- 1. Generate the Main 3D Plot (without projections) ---
        if blocks:
            fig = plt.figure(figsize=(10, 8))
            ax = fig.add_subplot(111, projection='3d')

            # The main 3D scatter plot
            ax.scatter(blocks, pages, bytes_addr, c='blue', marker='.', alpha=0.4, s=10, label='Data Points')

            # Set axis labels and limits
            ax.set_xlabel('block_num')
            ax.set_ylabel('page_num')
            ax.set_zlabel('byte_num')
            
            ax.set_xlim([min_block, max_block + 1])
            ax.set_ylim([min_page, max_page + 1])
            ax.set_zlim([min_byte, max_byte + 1])

            ax.set_title('3D Dot Plot of Data Addresses')
            ax.legend()
            plt.tight_layout()
            plt.savefig(plot_3d_filename)
            plt.close(fig)
            print(f"Main 3D plot saved to {plot_3d_filename}")

        # --- 2. Generate XY Projection (block_num vs page_num) ---
        if blocks:
            fig = plt.figure(figsize=(8, 6))
            plt.scatter(blocks, pages, c='blue', alpha=0.4, marker='.', s=10)
            
            plt.title('XY Projection (block_num vs page_num)')
            plt.xlabel('block_num')
            plt.ylabel('page_num')
            
            plt.xlim([min_block, max_block + 1])
            plt.ylim([min_page, max_page + 1])
            
            plt.grid(True, linestyle='--', alpha=0.6)
            plt.tight_layout()
            plt.savefig(plot_xy_filename)
            plt.close(fig)
            print(f"XY projection plot saved to {plot_xy_filename}")

        # --- 3. Generate XZ Projection (block_num vs byte_num) ---
        if blocks:
            fig = plt.figure(figsize=(8, 6))
            plt.scatter(blocks, bytes_addr, c='blue', alpha=0.4, marker='.', s=10)
            
            plt.title('XZ Projection (block_num vs byte_num)')
            plt.xlabel('block_num')
            plt.ylabel('byte_num')
            
            plt.xlim([min_block, max_block + 1])
            plt.ylim([min_byte, max_byte + 1])
            
            plt.grid(True, linestyle='--', alpha=0.6)
            plt.tight_layout()
            plt.savefig(plot_xz_filename)
            plt.close(fig)
            print(f"XZ projection plot saved to {plot_xz_filename}")

        # --- 4. Generate YZ Projection (page_num vs byte_num) ---
        if blocks:
            fig = plt.figure(figsize=(8, 6))
            plt.scatter(pages, bytes_addr, c='blue', alpha=0.4, marker='.', s=10)
            
            plt.title('YZ Projection (page_num vs byte_num)')
            plt.xlabel('page_num')
            plt.ylabel('byte_num')
            
            plt.xlim([min_page, max_page + 1])
            plt.ylim([min_byte, max_byte + 1])
            
            plt.grid(True, linestyle='--', alpha=0.6)
            plt.tight_layout()
            plt.savefig(plot_yz_filename)
            plt.close(fig)
            print(f"YZ projection plot saved to {plot_yz_filename}")


    def get_page_num_v_faults(self):
        data = [0] * 128
        for block in self.errors:
            for page in self.errors[block]:
                for address in self.errors[block][page]:
                    error = self.errors[block][page][address]
                    data[page] += error['number'] * count_bad_bits(0x55, error['value'])

        return data


    def get_pages_with_errors(self):
        for block in self.errors:
            for page in self.errors[block]:
                number_of_errors_in_page = 0
                for byte in self.errors[block][page]:
                    number_of_errors_in_page += self.errors[block][page][byte]['number']

                if number_of_errors_in_page not in self.pages_with_errors:
                    self.pages_with_errors[number_of_errors_in_page] = 0
                self.pages_with_errors[number_of_errors_in_page] += 1
        return self.pages_with_errors
    
    def __str__(self):
        """Returns a user-friendly, pretty-printed string representation of the stats."""
        output_lines = []
        
        if not self.errors:
            output_lines.append("  <No errors reported>")
            return "\n".join(output_lines)
        
        output_lines.append(f"Total bad blocks: {len(self.errors)} ({len(self.errors)/TOTAL_BLOCKS*100} %)")
        output_lines.append('')
        output_lines.append(f"Total bad pages: {self.bad_pages} ({self.bad_pages/TOTAL_PAGES*100} %)")
        output_lines.append("Errors per page:")
        self.get_pages_with_errors()
        for err in sorted(self.pages_with_errors):
            output_lines.append(f"    {err}: {self.pages_with_errors[err]}")
        output_lines.append('')
        output_lines.append(f"Total bad bytes: {self.bad_bytes} ({self.bad_bytes/TOTAL_BYTES*100} %)")
        for err in self.bad_byte_types:
            output_lines.append(f"    0x{err:X}: {self.bad_byte_types[err]}")
        
        return "\n".join(output_lines)


def read_file(file) -> CheckStats:
    state = UartState()
    errors = CheckStats()
    with open(file, 'rb') as f:
        while True:
            byte = f.read(1)

            if not byte:
                break

            byte_val = int.from_bytes(byte, 'big')
            

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
                    # message = (
                    #     f"Block {state.current_block:<5} BAD BYTE in page {state.block_test_stats['read']} at 0x{address:04X} ({address:>4}) "
                    #     f"expected 0x{state.current_test_byte_key} was 0x{data:02X} (x{number})\n"
                    # )
                    # log_terminal(message, runtime=time.monotonic() - state.test_time) # Removed printout
                    state.bad_bytes_in_block += number
                    errors.add_error(state.current_block, state.block_test_stats['read'], address, data, number)
                    
                    # Reset capture state
                    state.capture_mode = False
                    state.capture_buffer = []

                continue # Skip normal interpretation if currently capturing data

            if byte_val == INIT_COMPLETE:
                state = UartState()
                errors = CheckStats()
                # state.test_time = time.monotonic() # Removed time measuring
            
            elif byte_val == DIE_RESET_SUCCESS:
                pass
                # log_terminal("\rInit complete, reseting... Done\n", runtime=time.monotonic() - state.test_time) # Removed printout

            elif byte_val == BAD_BYTE:
                # Expects 5 bytes: [Addr_L, Addr_H, Data, Num_L, Num_H]
                state.capture_mode = True
                state.bytes_to_capture = 5

            elif byte_val == READ_PHASE_START:
                state.is_testing_block = True
                state.current_test_byte_key = "55" # This phase reads 0x55
                # state.block_start_time = time.monotonic() # Removed time measuring
                # update_block_test_display(state) # Removed printout
        
            # --- Removed READ_PHASE_END (A7) ---
            
            # --- Removed ERASE/PROG bytes (E0, E1, A1, A2, A4) ---

            elif byte_val == READ_INCREMENT and state.is_testing_block:
                state.block_test_stats['read'] += 1
            
            elif byte_val == BLOCK_TEST_COMPLETE:
                stats = state.block_test_stats

                if (state.bad_bytes_in_block == 0
                    and stats['read'] == 128):
                    # Use '\r' to overwrite the status line, clear it, and '\n' to finalize.
                    # msg = f"\rBlock {state.current_block:<5} {'OK':<13}{total_time:.3f}s" + " " * 140 + "\n"
                    # log_terminal(msg, runtime=time.monotonic() - state.test_time) # Removed printout
                    state.is_line_busy = True # To prevent timestamp on next line
                else:
                    # msg = f"\rBlock {state.current_block:<5} {'FAIL':<13}{total_time:.3f}s   Bad bytes: {state.bad_bytes_in_block}   READ: {stats['read']}{' '* 70}\n"
                    # log_terminal(msg, runtime=time.monotonic() - state.test_time) # Removed printout
                    pass
                
                state.reset_for_next_block()

            elif byte_val == FINISHED:
                break
            
            else:
                print(f"Unknown byte: 0x{byte_val:02X}")

    return errors


class DieStats:
    def __init__(self, die_num, check_min = 3, check_max = 6):
        self.check_min = check_min
        self.check_max = check_max
        self.die_num = die_num
        self.check_stats = []
    
    def get_die_data(self):
        state_0_stats = CheckStats()
        for err in STATE_0[self.die_num-1]:
            state_0_stats.add_error(err[0],err[1],err[2],err[3],err[4])
        self.check_stats.append(state_0_stats)
        for check in range(self.check_min,self.check_max+1):
            stats = read_file(f'results/check{check}/read/die{self.die_num}.bin')
            self.check_stats.append(stats)
        self.print_data()
    
    def print_data(self):
        for i, check in enumerate(self.check_stats):
            if i == 0:
                print(f"--------------------\n\nDie {self.die_num}, check 0\n")
            else:
                print(f"--------------------\n\nDie {self.die_num}, check {i+self.check_min-1}\n")
            print(check)
    
    def gen_scatter_plots(self):
        os.makedirs(f"plots/sector_A/die{self.die_num}/scatter", exist_ok=True)
        for i, check in enumerate(self.check_stats):
            if self.die_num == 4 and i == 4: continue
            check.plot_scatter(f"plots/sector_A/die{self.die_num}/scatter/check{i+self.check_min}")

    def gen_page_num_v_errors_plot(self):
        os.makedirs(f"plots/sector_A/die{self.die_num}", exist_ok=True)
        data = self.check_stats[-1].get_page_num_v_faults()

        for i in range(0,128):
            data[i] = data[i] / TOTAL_BITS * 100

        plt.figure(figsize=(10, 6))
        plt.bar(range(0,128), data)
        plt.xlabel('Page number')
        plt.ylabel('Average error rate [%]')
        plt.title(f'Average error rate per page over all blocks (die {self.die_num}, check {self.check_max})')
        plt.savefig(f"plots/sector_A/die{self.die_num}/page_num_v_errors.png")
        plt.close()

        # for i, check in enumerate(self.check_stats):
        #     check.plot_page_num_v_faults(f"plots/sector_A/die{self.die_num}/p_num_v_faults/check{i+self.check_min}")


class GlobalStats:
    def __init__(self):
        self.die_stats = []

    def load_dice(self):
        for i in range(1,7):
            die = DieStats(i)
            die.get_die_data()
            self.die_stats.append(die)
    
    def gen_scatter_plots(self):
        for die in self.die_stats:
            die.gen_scatter_plots()
    
    def gen_page_num_v_errors_plots(self):
        for die in self.die_stats:
            die.gen_page_num_v_errors_plot()
    
    def gen_avg_page_num_v_errors(self):
        data = [0] * 128
        for die in self.die_stats[:-1]:
            for i, page_faults in enumerate(die.check_stats[4].get_page_num_v_faults()):
                data[i] += page_faults
            
        for i in range(0,128):
            data[i] = data[i] / TOTAL_BITS * 100
            data[i] /= 5
        
        plt.figure(figsize=(10, 6))
        plt.bar(range(0,128), data)
        plt.xlabel('Page number')
        plt.ylabel('Average error rate [%]')
        plt.title(f'Average error rate per page over all blocks and dice (dose {(DOSES_ADJUSTED[4]):.2f} Gy)')
        plt.savefig(f"plots/sector_A/avg_page_num_v_errors.png")
        plt.close()
    
    def gen_dose_v_errors(self):
        plt.figure(figsize=(10, 6))
        for i, die in enumerate(self.die_stats):
            data = list(map(lambda x: x.bad_bits,die.check_stats))
            values = list(map(lambda x: x/TOTAL_BITS*100,data))
            plt.plot(DOSES_ADJUSTED[:-1], values, marker='o', label=f"Die {i+1}")
        plt.legend()
        plt.xlabel('Dose [Gy]')
        plt.yscale('symlog', linthresh=9e-8)
        plt.ylabel('Error rate [%]')
        plt.title('Error rates at given doses')
        plt.savefig(f'plots/sector_A/errors_v_dose.png')
        plt.close()
    
    def gen_bias_dose_v_errors(self):
        biased = [0] * 5
        unbiased = [0] * 5 
        for i, die in enumerate(self.die_stats):
            data = list(map(lambda x: x.bad_bits,die.check_stats))
            if i == 3:
                data = data[:-1]
            values = list(map(lambda x: x/TOTAL_BITS*100,data))

            for j, element in enumerate(values):
                if i in (0,1,3):
                    biased[j] += element
                elif i in (2,4):
                    unbiased[j] += element
                
        for i in range(0,4):
            biased[i] /= 3
            unbiased[i] /= 2
        
        print(biased)
        print(unbiased)
        
        for i, elem in enumerate(biased):
            print((elem-unbiased[i])/unbiased[i])
        
        plt.figure(figsize=(10, 6))
        plt.plot(DOSES_ADJUSTED[:-1],biased,marker='o',label=f"Biased dice")
        plt.plot(DOSES_ADJUSTED[:-1],unbiased,marker='o',label=f"Unbiased dice")
        plt.legend()
        plt.xlabel('Dose [Gy]')
        plt.yscale('log')
        plt.ylabel('Error rate [%]')
        plt.title('Error rates at given doses')
        plt.savefig(f'plots/sector_A/bias_errors_v_dose.png')
        plt.close()



def main():
    stats = GlobalStats()
    stats.load_dice()
    # stats.gen_scatter_plots()
    # stats.gen_page_num_v_errors_plots()
    os.makedirs(f"plots/sector_A", exist_ok=True)
    stats.gen_avg_page_num_v_errors()
    stats.gen_dose_v_errors()
    stats.gen_bias_dose_v_errors()


if __name__ == "__main__":
    main()
