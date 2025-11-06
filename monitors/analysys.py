import os
import matplotlib.pyplot as plt

from program_analyser import GlobalStats as ProgStats
from read_analyser import GlobalStats as ReadStats
from read_analyser import DOSES_ADJUSTED, TOTAL_BITS

prog_stats = ProgStats()
prog_stats.load_dice()

read_stats = ReadStats()
read_stats.load_dice()

prog_avg = [0] * 5
for die in prog_stats.die_stats[:-1]:
    data = list(map(lambda x: x.bad_bits,die.check_stats))
    values = list(map(lambda x: x/TOTAL_BITS*100,data))
    del values[1:3]
    for i, value in enumerate(values):
        prog_avg[i] += value / 5

read_avg = [0] * 5
for die in read_stats.die_stats[:-1]:
    data = list(map(lambda x: x.bad_bits,die.check_stats))
    values = list(map(lambda x: x/TOTAL_BITS*100,data))
    for i, value in enumerate(values):
        read_avg[i] += value / 5

plt.figure(figsize=(10, 6))
plt.plot(DOSES_ADJUSTED[:-1],read_avg,marker='o',label=f"Sector A")
plt.plot(DOSES_ADJUSTED[:-1],prog_avg,marker='o',label=f"Sector B")
plt.legend()
plt.xlabel('Dose [Gy]')
plt.yscale('log')
plt.ylabel('Error rate [%]')
plt.title('Average error rates at given doses')
plt.savefig(f'plots/errors_v_dose.png')
plt.close()
