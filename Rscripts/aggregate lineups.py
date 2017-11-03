
import pandas as pd
import os
import csv
from numpy import savetxt

dfs = []
indir = 'C:/Users/Vicky/Desktop/Draft Kings/Github_DFS_Scripts/Fantasy-Football-Optimization/Lineup Generations/'

for root, dirs, filenames in os.walk(indir):
    for f in filenames:
        if f[-4:] == '.csv':
            print(f)
            x = indir + f
            new = pd.read_csv(x)
            new['week'] = f[-5]
            dfs.append(new)

df = pd.concat(dfs)
#print(list(df))

df.to_csv('aggregated_lineups.csv')













































