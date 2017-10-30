import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
f = 'C:\Users\Vicky\Desktop\Draft Kings\Github_DFS_Scripts\DFS_Scripts\Input\LineupCO\Week1_LU.csv'
print(f)
df = pd.read_csv(f)
df = df[df['Actual'] > 2]
df = df[df['AvgPointsPerGame'] > 2]

n = np.poly1d(np.polyfit(df['Actual'],df['AvgPointsPerGame'],1))
plt.plot(df['Actual'],n(df['Actual']))
plt.scatter(df['AvgPointsPerGame'], df['Actual'],alpha = .85)
plt.ylabel('Actual Fantasy Points')
plt.xlabel('Projected Fantasy Points')
plt.axis([0,50,0,50])
plt.text(50,0, 'Source: www.linestarapp.com, Weeks 1-6, 2017',
        verticalalignment='bottom', horizontalalignment='right',
        color='black', fontsize=7)
plt.text(45, 18, 'R-sq: .13',
        verticalalignment='bottom', horizontalalignment='right',
        color='black', fontsize=10)
plt.show()