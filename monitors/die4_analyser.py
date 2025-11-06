import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec # Import GridSpec
from read_analyser import TOTAL_BITS
from read_analyser import DOSES_ADJUSTED as DOSES_READ
from read_analyser import DieStats as ReadDieStats
from program_analyser import DieStats as ProgDieStats
from program_analyser import DOSES_ADJUSTED as DOSES_PROG

read_stats = ReadDieStats(4, 3, 9)
read_stats.get_die_data()

prog_stats = ProgDieStats(4, 0, 9)
prog_stats.get_die_data()

data = list(map(lambda x: x.bad_bits,read_stats.check_stats))
read_values = list(map(lambda x: x/TOTAL_BITS*100,data))

data = list(map(lambda x: x.bad_bits,prog_stats.check_stats))
prog_values = list(map(lambda x: x/TOTAL_BITS*100,data))

annealing_measurements = [24, 98]

# --- Create the Plot ---

# Create a figure with 1 row and 2 columns of subplots.
# sharey=True is the key parameter: it makes both subplots share the same y-axis.
# Create a figure
fig = plt.figure(figsize=(12, 6))

# Create a GridSpec with 1 row, 2 columns, and specified width ratios
# The first plot (ax1) will be 4 times as wide as the second (ax2).
gs = GridSpec(1, 2, width_ratios=[4, 1])
ax1 = fig.add_subplot(gs[0, 0])
ax2 = fig.add_subplot(gs[0, 1], sharey=ax1) # sharey=ax1 links the y-axis

# --- Plot 1 (Left) ---
ax1.plot(DOSES_READ, read_values[:-2], '-', marker='o', label="Sector A")
ax1.plot(DOSES_PROG, prog_values[:-2], '-', marker='o', label="Sector B")
ax1.set_title('Irradiation')
ax1.set_xlabel('Dose [Gy]')
ax1.set_ylabel('Error rate [%]') # Y-label only needs to be set on the first plot
ax1.set_yscale('log')
ax1.legend(loc='upper left')
ax1.grid(True)

# Remove the box (spines)
for i, spine in enumerate(ax1.spines.values()):
    if i in (0, 2): continue
    spine.set_visible(False)

# --- Plot 2 (Right) ---
ax2.plot(annealing_measurements, read_values[-2:], '-', marker='o')
ax2.plot(annealing_measurements, prog_values[-2:], '-', marker='o')
ax2.set_title('Baking')
ax2.set_xlabel('Time after irradiation [h]')
ax2.set_yscale('log')
ax2.grid(True)
ax2.tick_params(axis='y', which='both', length=0, labelleft=False)
ax2.axvline(x=annealing_measurements[0], color='gray', linestyle='--', linewidth=1.5)

# Add the label ("tabel")
ax2.annotate(
    f'Baking start (after {annealing_measurements[0]}h)', # The text to display
    xy=(annealing_measurements[0], read_values[6]),             # The point to annotate
    xytext=(annealing_measurements[0], read_values[6] - 0.00647), # Where to place the text
    # arrowprops=dict(facecolor='black', shrink=0.05, width=1, headwidth=6), # Arrow properties
    bbox=dict(boxstyle="round,pad=0.3", fc='white', lw=1, alpha=0.9) # Box properties
)

# Remove the box (spines)
for i, spine in enumerate(ax2.spines.values()):
    if i == 2: continue
    spine.set_visible(False)

# --- Final Touches ---
fig.suptitle('Error rates at given doses and effects of baking (die 4)', fontsize=16)
plt.tight_layout() # Adjusts plot parameters for a good fit
plt.savefig('plots/die4_error_v_dose.png', bbox_inches='tight', pad_inches=0.1)
plt.close()