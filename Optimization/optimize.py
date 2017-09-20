from pulp import *
import pandas as pd
import re , csv
from draftkings import *


import time

def optimize():
	print "Starting optimization model"
	print "----------------------------------"
	print "Reading Data"
	player_data=pd.read_csv("../Input/DKSalaries.csv")
	prob = pulp.LpProblem('NFL', pulp.LpMaximize)
	constraint_details=[]
	players={}
	total_budget=50000
	positions=["QB", "RB", "WR", "TE", "DST"]
	
	salaries={}
	position_constraints={}

	for position in positions:
		salaries[position]=''
		position_constraints[position]=''
	
	 
	num_players=''

 	teams=player_data.teamAbbrev.unique()
	team_constraints={}


 	freq_limit=10
	objective_function=''
	total_cost=''
	l_collection=LineupCollection()

	for team in teams:
		team_constraints[team]={}
		team_constraints[team]['QB']=''
		team_constraints[team]['WR']=''
	print "Building logic"

	for rownum, row in player_data.iterrows():
		variable=str('x'+str(rownum))
		variable = pulp.LpVariable(str(variable), lowBound = 0, upBound = 1, cat= 'Integer')

		player=Player(row, str(variable))
		players[str(variable)]=player
		#print player.name

		num_players += variable

		player_points = player.projected*variable
		total_cost+= player.salary*variable
		objective_function += player_points
		 
		position_constraints[player.position]+=variable
		#Team Stacking Organization
		if player.position=='QB' and player.projected!=0:
			team_constraints[player.team]['QB']+=variable

		if player.position=='WR':
			team_constraints[player.team]['WR']+=variable


	prob += lpSum(objective_function)
	prob += (total_cost<=50000)
	prob += (num_players==9)
	min_limits=[1, 2, 3, 1, 1]
	print "Building Constraints"
	#Actual stacking constraints
	for team in team_constraints:
		print str(team_constraints[team]['WR']).replace(' ', '').split('+'), team 
		print [players[p].name for p in str(team_constraints[team]['WR']).replace(' ', '').split('+') ]
		print team_constraints[team]['QB']
		print [players[str(team_constraints[team]['QB'])].name, 'LESS THAN '] 


		prob += (team_constraints[team]['QB'] <= team_constraints[team]['WR'])
	print constraint_details
	time.sleep(100)
	for i, position in enumerate(positions):
		if position =="QB" or position=="DST":
			prob+= (position_constraints[position]<=1)
			prob+= (position_constraints[position]>=1)
		else:
			prob+= (position_constraints[position]>=min_limits[i])
			prob+= (position_constraints[position]<=min_limits[i]+1)
	lineups=[]
	num_lineups=2
	print "Writing Lineup"
	for i in range(1,num_lineups+1):
		print 'Iteration %d'% i
		fileLP="NFL_X%d.lp"%i			
		prob.writeLP(fileLP)
		optimization_result = prob.solve()
		#assert optimization_result == pulp.LpStatusOptimal

		lineup=[]
		selected_vars=[]

		diversity_constraint=''
		div_limit=3
		lineup_values=[]
		for var in prob.variables():
			if 'x' not in str(var):
				continue
			if var.varValue:
				player.count+=1
				frequency_constraint=''
				frequency_constraint+=player.count*var+var
				prob+=(frequency_constraint<=freq_limit)

				selected_vars.append(var)
				player=players[str(var)]
				#print player.name
				lineup.append(player)

				var.varValue=0
			#Force diversity s.t no than two lineups can share more than 3 players
		diversity_constraint=sum([var for var in selected_vars])				
		prob+=(diversity_constraint<=div_limit)
		#print len(lineup)
		lineups.append(lineup)
	write_output(lineups, "prediction_detailed.csv",prob)

def write_output(lineups, filename, prob):
    #Writes lineups to csv

    header_names=['QB', 'RB', 'RB', 'WR', 'WR', 'WR', 'TE', 'FLEX', 'DST']
    team_list=[header+' Team ' for header in header_names]
    salary_list=[header+' Salary ' for header in header_names]

    target=open(filename, 'w')
    #dfs_target=open('Dfslineups.csv', 'w')
    headers=header_names+team_list+salary_list+['Projected Value', 'Iteration'] 
    csvwriter=csv.writer(target)
    csvwriter.writerow(headers)
    
    #dfswriter=csv.writer(dfs_target)
    #dfswriter.writerow(headers)

    for iteration, lineup in enumerate(lineups):
      dfs_lineup=['']*29
      projected=0.0
      dfs_ids=[0]*9
      for player in lineup:
      	projected+=player.projected
      	if player.position=='QB':
      		index=0
      	elif player.position=='RB':
      		if dfs_lineup[1]=='':
      			index=1
      		elif dfs_lineup[2]=='':
      			index=2
      		else:
      			index=7
      	elif player.position=='WR':
       		if dfs_lineup[3]=='':
      			index=3
      		elif dfs_lineup[4]=='':
      			index=4
      		elif dfs_lineup[5]=='':
      			index=5
      		else:
      			index=7
      	elif player.position=='TE':
		    if dfs_lineup[6]=='':
				index=6
		    else:
				index=7
      	else:
      		index=8

      	dfs_lineup[index]=player.name
      	dfs_lineup[index+9]=player.team
      	dfs_lineup[index+18]=player.salary
      	#dfs_ids[index]=player.ID
      dfs_lineup[27]=round(projected,2)
      dfs_lineup[28]=iteration+1
      #final_output=names+teams+positions+salaries+[round(sum(projected),2), iteration+1]
      csvwriter.writerow(dfs_lineup)
      #dfswriter.writerow(dfs_ids)
    target.close()


optimize()