import pulp
import pandas as pd
import re , csv
from draftkings import *


import time

def optimize(scenario_parameters):


    for scenario in sorted(scenario_parameters.iterkeys()):
        scenario_name=scenario
        num_lineups=scenario_parameters[scenario]['Lineups']
        overlap=scenario_parameters[scenario]['Overlap']
        stacking=scenario_parameters[scenario]['Stacking']
        ownership_limit=scenario_parameters[scenario]['Ownership']
        print "Starting optimization model"
        print "----------------------------------"
        print "Reading Data!"
        player_data=pd.read_csv("../Input/Week3Ownership.csv")
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

        objective_function=''
        total_cost=''
        l_collection=LineupCollection()

        for team in teams:
            team_constraints[team]={}
            team_constraints[team]['QB']=''
            team_constraints[team]['WR']=''
        print "Building logic"
        ownership_constraints={}
        ownership_constraints['L']=''
        for rownum, row in player_data.iterrows():
            variable=str('x'+str(rownum))
            variable = pulp.LpVariable(str(variable), lowBound = 0, upBound = 1, cat= pulp.LpBinary)

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

            if player.OwnershipTier=="L":
            	ownership_constraints["L"]+=variable

        prob += pulp.lpSum(objective_function)
        prob += (total_cost<=50000)
        prob += (num_players==9)
        min_limits=[1, 2, 3, 1, 1]
        print "Building Constraints,"
        #Actual stacking constraints

        if stacking=='QB Needs WR':
            for team in team_constraints:
                prob += (team_constraints[team]['QB'] <=team_constraints[team]['WR'])
        elif stacking=='Forced Unconstrained':
            for team in team_constraints:
                pass
        else:
            print "NONE"

        for i, position in enumerate(positions):
            if position =="QB" or position=="DST":
                prob+= (position_constraints[position]<=1)
                prob+= (position_constraints[position]>=1)
            else:
                prob+= (position_constraints[position]>=min_limits[i])
                prob+= (position_constraints[position]<=min_limits[i]+1)
        lineups=[]
        print "limit is ", ownership_limit, type(ownership_limit)
        if ownership_limit !="None":
        	print "adding ownership constraints"
        	prob+=(ownership_constraints["L"]<=ownership_limit)
        	prob+=(ownership_constraints["L"]>=ownership_limit)
        	#print ownership_constraints["L"]
 		    #prob+=(ownership_constraints["L"]=ownership_limit)
        print "Writing Lineup"
        for i in range(1,num_lineups+1):
            print 'Iteration %d'% i
            #fileLP="NFL_X%d.lp"%i          
            #prob.writeLP(fileLP)
            optimization_result = prob.solve()
            #assert optimization_result == pulp.LpStatusOptimal

            lineup=[]
            selected_vars=[]

            diversity_constraint=''
            div_limit=overlap
            lineup_values=[]
            freq_limit=5
            for var in prob.variables():
                if var.varValue:
                    #print var, var.varValue, players[str(var)].name
                    player=players[str(var)]
                    player.count+=1
                    #print player.count
                    prob+=(((player.count)+1)*var <=freq_limit), 'cap_%s_%s' %(str(var), str(player.count+1))

                    selected_vars.append(var)
                    
                    #print player.name
                    lineup.append(player)
                 
            print "-----"
                #Force diversity s.t no than two lineups can share more than 3 players
            diversity_constraint=sum([var for var in selected_vars])                
            prob+=(diversity_constraint<=div_limit)
            #print len(lineup)
            lineups.append(lineup)
     
 

        write_output(lineups, scenario_parameters, scenario,prob)

def write_output(lineups, scenario_parameters, scenario, prob):
    #Writes lineups to csv
    filename='MegaPredictions.csv'
    
    time.sleep(1)
    if scenario=='Scenario1':
        header_names=['QB', 'RB', 'RB', 'WR', 'WR', 'WR', 'TE', 'FLEX', 'DST']
        team_list=[header+' Team ' for header in header_names]
        salary_list=[header+' Salary ' for header in header_names]
        target=open(filename, 'w')
        #dfs_target=open('Dfslineups.csv', 'w')
        headers=header_names+team_list+salary_list+['Projected Value', 'Scenario', 'Iteration', 'Actual'] 
        csvwriter=csv.writer(target)
        csvwriter.writerow(headers)  
    #dfswriter=csv.writer(dfs_target)
    #dfswriter.writerow(headers)
    else:
        target=open(filename, 'a')
        csvwriter=csv.writer(target)

    for iteration, lineup in enumerate(lineups):
      print scenario , "HERE", iteration
      dfs_lineup=['']*31
      projected=0.0
      actual=0.0
      dfs_ids=[0]*9
      for player in lineup:
        projected+=player.projected
        actual+=player.actual
        #print player.projected

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


      dfs_lineup[28]=scenario
      dfs_lineup[29]=iteration+1
      dfs_lineup[30]=round(actual,2)

      #final_output=names+teams+positions+salaries+[round(sum(projected),2), iteration+1]
      csvwriter.writerow(dfs_lineup)
      #dfswriter.writerow(dfs_ids)
    target.close()

#Initializiation
df=pd.read_excel('../Input/Optimization Parameters Table Demo.xlsx')
scenario_parameters={}
for scenario, row in df.iterrows():
    Title=row['Title']
    scenario_parameters[Title]={}
    scenario_parameters[Title]['Lineups']=row['Lineups']
    scenario_parameters[Title]['Overlap']=row[3]
    scenario_parameters[Title]['Stacking']=row[4]
    scenario_parameters[Title]["Ownership"]=row[5]
optimize(scenario_parameters)
 