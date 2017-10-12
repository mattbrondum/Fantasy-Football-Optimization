import pandas as pd
def addActualpts(week):
	actual_fps=df.read_csv('../ActualW%d.csv' %week)
	actual_fps['ProperName']=actual_fps['Name'].str.replace(r'(.+),\s+(.+)', r'\2 \1')
	salary=df.read_csv('../Input/DKSalaries_W%d.csv'%d)
addActualpts(3)