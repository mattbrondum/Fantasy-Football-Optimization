import pulp
import pandas as pd
import re , csv
from draftkings import *
from multiprocessing import Process


# scenario_parameters=scenario['scenario']
# projection_filepath=scenario['filepath']
# week_num=scenario['week']
import time

def optimize(scenario_parameters, projection_filepath, week):
   # scenario_parameters=scenario['scenario']
   # projection_filepath=scenario['filepath']
   # week_num=scenario['week'] 
   for scenario in sorted(scenario_parameters.iterkeys()):
        scenario_name=scenario
        #print scenario_name
        num_lineups=scenario_parameters[scenario]['Lineups']
        freq_limit=scenario_parameters[scenario]["Frequency"]
        overlap=scenario_parameters[scenario]['Overlap']
        stacking=scenario_parameters[scenario]['Stacking']
        ownership_limit=scenario_parameters[scenario]['Ownership']
        objective_type=scenario_parameters[scenario]['Objective']
        
        # print "Starting optimization model"
        # print "----------------------------------"
        # print "Reading Data!"
        player_data=pd.read_csv(projection_filepath)
        #print objective_type
        if "Maximize" in objective_type:
        	prob = pulp.LpProblem('NFL', pulp.LpMaximize)
        else:
        	prob = pulp.LpProblem('NFL', pulp.LpMinimize)
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
        #print "Building logic"
        ownership_constraints={}
        ownership_constraints['L']=''
        expected_points_constraint=''
        for rownum, row in player_data.iterrows():
            variable=str('x'+str(rownum))
            variable = pulp.LpVariable(str(variable),cat= 'Binary')

            player=Player(row, str(variable))
            players[str(variable)]=player
            #print player.name

            num_players += variable

            player_points = player.projected*variable
            total_cost+= player.salary*variable
            if "Points" in objective_type:
            	objective_function += player_points
            else:#Must be an ownership type
            	objective_function += player.OwnershipPercent*variable
            	expected_points_constraint+=player_points
             
            position_constraints[player.position]+=variable
            #Team Stacking Organization
            if player.position=='QB' and player.projected!=0:
                team_constraints[player.team]['QB']+=variable

            if player.position=='WR':
                team_constraints[player.team]['WR']+=variable
            if ownership_limit != "None":
                if player.OwnershipTier=="L":
                	ownership_constraints["L"]+=variable

        prob += pulp.lpSum(objective_function)
        
        if "Ownership" in objective_type:
        	#print "added here"
        	prob+=(expected_points_constraint>=100.0)

        prob += (total_cost<=50000)
        prob += (num_players==9)
        min_limits=[1, 2, 3, 1, 1]
        #print "Building Constraints,"
        #Actual stacking constraints

        if stacking=='QB Needs WR':
            for team in team_constraints:
                prob += (team_constraints[team]['QB'] <=team_constraints[team]['WR'])
        elif stacking=='Forced Unconstrained':
            for team in team_constraints:
                pass
        else:
            pass
            #print "NONE"

        for i, position in enumerate(positions):
            if position =="QB" or position=="DST":
                prob+= (position_constraints[position]<=1)
                prob+= (position_constraints[position]>=1)
            else:
                prob+= (position_constraints[position]>=min_limits[i])
                prob+= (position_constraints[position]<=min_limits[i]+1)
        lineups=[]
        #print "limit is ", ownership_limit, type(ownership_limit)
        if ownership_limit !="None":
        	#print "adding ownership constraints"
        	prob+=(ownership_constraints["L"]<=ownership_limit)
        	prob+=(ownership_constraints["L"]>=ownership_limit)
        	#print ownership_constraints["L"]
 		    #prob+=(ownership_constraints["L"]=ownership_limit)
        #print "Writing Lineup"
        for i in range(1,num_lineups+1):
            print '%s Iteration %d, week%d'% (scenario_name, i, week)
            #fileLP="NFL_X%d.lp"%i          
            #prob.writeLP(fileLP)
            optimization_result=prob.solve(solver=pulp.PULP_CBC_CMD())
            #solver=pulp.GUROBI()
            #prob.setSolver(solver)
            #optimization_result = prob.solve(pulp.GLPK(msg=False))
            #print "WOAHHH", pulp.LpStatusOptimal, optimization_result
            if optimization_result!=1:
            	print "Solutions are infeasible, move on to next scenario"
            	break

            lineup=[]
            selected_vars=[]

            diversity_constraint=''
            div_limit=overlap
            lineup_values=[]
            freq_limit=freq_limit
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
                 
            #print "-----"
                #Force diversity s.t no than two lineups can share more than 3 players
            diversity_constraint=sum([var for var in selected_vars])                
            prob+=(diversity_constraint<=div_limit)
            #print len(lineup)
            lineups.append(lineup)
     
 

        write_output(lineups, scenario_parameters, scenario,prob,week_num)

def write_output(lineups, scenario_parameters, scenario, prob,week_num):
    #Writes lineups to csv
    filename='PredictionsWeek%d.csv' % week_num
    
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
      #print scenario , "HERE", iteration
      dfs_lineup=['']*31
      projected=0.0
      actual=0.0
      dfs_ids=[0]*9
      for player in lineup:
        projected+=player.projected
        actual+=player.actual


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
df=pd.read_csv('../Input/fullfactorial.csv')
scenario_parameters={}
for scenario, row in df.iterrows():
    Title=row['Scenario']
    scenario_parameters[Title]={}
    scenario_parameters[Title]['Lineups']=row['Lineups']
    scenario_parameters[Title]["Frequency"]=row['Frequency']
    scenario_parameters[Title]['Overlap']=row['Overlap']
    scenario_parameters[Title]['Stacking']=row['Stacking']
    scenario_parameters[Title]["Ownership"]=row['Ownership']
    scenario_parameters[Title]["Objective"]=row['ObjectiveFunction']
#print(scenario_parameters['Scenario54'])

#exit()
# Run one week only
# week_num=7
# projection_filepath="../Input/LineupCO/Week%d_LU.csv" % week_num
# #optimize(scenario_parameters, projection_filepath, week_num)
# parameters=[]
# processes = []
# for week in range(1,6):
# 	fp="../Input/LineupCO/Week%d_LU.csv" % week
# 	p = Process(target=optimize, args=(scenario_parameters, fp, week))
# 	p.start()
# 	processes.append(p)
# for p in processes:
# 	p.join()
# print parameters
# pool = ThreadPool(3)
# pool.map(optimize, parameters)

# Run multiple weeks at a time
for wk in range(1, 2):
    print "Current week: %d" % wk
    projection_filepath="../Input/LineupCO/Week%d_LU.csv" % wk
    optimize(scenario_parameters, projection_filepath, wk)
 
