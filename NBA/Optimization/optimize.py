from pulp import *
import numpy as np
import pandas as pd
import re 
import csv
import random
from player import *

def optimize(date):
	iterations=50
	print date
	data=pd.read_csv(date)
	prob = pulp.LpProblem('NBA', pulp.LpMaximize)
	players={}
	total_budget=50000
	pgs=sgs=sfs=pfs=cs=''
	objective_function=''
	total_cost=''
	decision_variables=[]
	num_players=''
	for rownum, row in data.iterrows():
		variable = str('x' + str(rownum))
		variable = pulp.LpVariable(str(variable), lowBound = 0, upBound = 1, cat= 'Integer')
		player=Player(row, str(variable))
		players[str(variable)]=player
		decision_variables.append(variable)
		num_players += variable

		player_points = row["Projected"]*variable
		objective_function += player_points

		player_cost = row['Salary']*variable
		total_cost+= player_cost

		#Categorize players by position groups
		pgs += player.position['PG']*variable
		sgs += player.position['SG']*variable
		sfs += player.position['SF']*variable
		pfs += player.position['PF']*variable
		cs += player.position['C']*variable
	#Set  the objective function
	prob +=  lpSum(objective_function)


	#Mininum constraints for an eligible lineup
	prob += (total_cost <= total_budget)
	prob += (num_players ==8)

	prob += (pgs <=3)
	prob += (pgs >=1)

	prob += (sgs <=3)
	prob += (sgs >=1)

	prob += (sfs <=3)
	prob += (sfs >=1)

	prob += (pfs <=3)
	prob += (pfs >=1)

	prob += (cs <=2)
	prob += (cs >=1)

	#additional Constraint
	diversity_constraint=''
	div_limit=3  
	lineups=[]
	iterations=50
	for i in range(1,iterations+1):

		print 'Iteration %d'% i
		#fileLP="NBA_X%d.lp"%i
		#prob.writeLP(fileLP)


		optimization_result = prob.solve()
		if optimization_result != pulp.LpStatusOptimal:
			print "finished abrupty"
			break
		lineup=[]
		selected_vars=[]
		diversity_constraint=''
		freq_limit=5
		div_limit=3
		lineup_values=[]
		for var in prob.variables():
			if 'x' not in str(var):
				continue
			if var.varValue:
				
				selected_vars.append(var)
				player=players[str(var)]
				lineup.append(player)
				#print player.name, player.scored, player.projected
				player.count+=1
				frequency_constraint=''
				frequency_constraint+=player.count*var+var
				prob+=(frequency_constraint<=freq_limit)
				#Resets the value to be 'fresh' for next optimization
				var.varValue=0
			#Force diversity s.t no than two lineups can share more than 3 players
		diversity_constraint=sum([var for var in selected_vars])				
		prob+=(diversity_constraint<=div_limit)

		lineups.append(lineup)
	filename=date.split("/")[-1].replace("Projection", 'Prediction')
	write_output(filename,lineups,prob)

def write_output(filename, lineups, prob):
	#Writes lineups to csv
	player_list=[]
	team_list=[]
	pos_list=[]
	salary_list=[]
	for i in xrange(8):
		player_list.append('Player%s' %str(i+1))
		team_list.append('Team%s' %str(i+1))
		pos_list.append('Pos%s' %str(i+1))
		salary_list.append('Salary%s' %(str(i+1)))
	print filename
	target=open(filename, 'w')
	headers=player_list+team_list+pos_list+salary_list+['Projected Value', 'Actual Scored', 'Iteration', 'date'] 
	target=open(filename, 'w')
	csvwriter=csv.writer(target)
	csvwriter.writerow(headers)
	for iteration, lineup in enumerate(lineups):
		names=[]
		teams=[]
		scored=[]
		salaries=[]
		projected=[]
		positions=[]
		for player in lineup:
			names.append(player.name)
			teams.append(player.team)
			scored.append(player.scored)
			projected.append(player.projected)
			positions.append(player.pos)
			salaries.append(player.salary)
		counter=collections.Counter(teams)

		final_output=names+teams+positions+salaries+[round(sum(projected),2), round(sum(scored),2), iteration+1]
		csvwriter.writerow(final_output)
	target.close()

	df=pd.read_csv(filename)
	print filename
	df.to_csv('../Predictions/%s'% filename, index=False)

#dates=os.listdir('../Projections/past')[1:]
file="../Input/Projections/Projection_10172017.csv"
optimize(file)