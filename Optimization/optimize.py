from pulp import *
import collections

import numpy as np
import pandas as pd
import re 
import csv
import random
from draftkings import Player
from draftkings import *
import calendar
import datetime

def optimize():

	player_data=pd.read_csv("../Input/DKSalaries_Week2.csv")
	prob = pulp.LpProblem('NFL', pulp.LpMaximize)

	players={}
	total_budget=50000
	positions=["QB", "RB", "WR", "TE", "DST"]
	min_limits=[1, 2, 3, 1, 1]
	limits=[1, 2, 3, 1, 1]
	salaries={}
	position_constraints={}
	for position in positions:
		salaries[position]=''
		position_constraints[position]=''
	
	 
	num_players=''
	teams=player_data.teamAbbrev.unique()
	team_constraints={}
	player_to_vars={}
	objective_function=''
	total_cost=''
	l_collection=LineupCollection()
	for team in teams:
		team_constraints[team]=''

	for rownum, row in player_data.iterrows():
		variable=str('x'+str(rownum))
		variable = pulp.LpVariable(str(variable), lowBound = 0, upBound = 1, cat= 'Integer')

		player=Player(row, str(variable))
		players[str(variable)]=player
		#print player.name

		num_players += variable
		player_to_vars[player.name]=variable

		player_points = player.projected*variable
		total_cost+= player.salary*variable
		objective_function += player_points
		 
		position_constraints[player.position]+=variable
		team_constraints[player.team]+=variable
	prob +=  lpSum(objective_function)
	prob += (total_cost<=50000)
	prob += (num_players==9)

	for i, position in enumerate(positions):
		if position =="QB" or position=="DST":
			prob+= (position_constraints[position]<=1)
			prob+= (position_constraints[position]>=1)
		else:
			prob+= (position_constraints[position]>=min_limits[i])
			prob+= (position_constraints[position]<=min_limits[i]+1)
	lineups=[]
	for i in range(1, 11):
		print 'Iteration %d'% i
		#fileLP="NFL_X%d.lp"%i			
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
				
				selected_vars.append(var)
				player=players[str(var)]
				print player.name
				lineup.append(player)

				var.varValue=0
			#Force diversity s.t no than two lineups can share more than 3 players
		diversity_constraint=sum([var for var in selected_vars])				
		prob+=(diversity_constraint<=div_limit)
		print len(lineup)
		lineups.append(lineup)
	write_output(lineups, "prediction.csv",prob)

def write_output(lineups, filename, prob):
    #Writes lineups to csv
    player_list=[]
    team_list=[]
    pos_list=[]
    salary_list=[]
    for i in xrange(9):
      player_list.append('Player%s' %str(i+1))
      team_list.append('Team%s' %str(i+1))
      pos_list.append('Pos%s' %str(i+1))
      salary_list.append('Salary%s' %(str(i+1)))
    target=open(filename, 'w')
    headers=player_list+team_list+pos_list+salary_list+['Projected Value', 'Iteration'] 
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
        projected.append(player.projected)
        positions.append(player.position)
        salaries.append(player.salary)
      counter=collections.Counter(teams)

      final_output=names+teams+positions+salaries+[round(sum(projected),2), iteration+1]
      csvwriter.writerow(final_output)
    target.close()


optimize()