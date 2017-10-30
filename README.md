# (THIS README IS IN PROGRESS)

# Daily Fantasy Football Optimization
**tl;dr**  
* We developed an iterative integer programming model for generating lineups in daily fantasy football 
* We experienced limited success due to the NFL being a highly unpredictable league 
* This model is generalizable enough to apply to other fantasy sports and can easily be expanded on 

## Who cares?
Daily Fantasy Sports (DFS) have exploded since platforms like [Draftkings (2012)](www.draftkings.com) and [Fantasy Duel (2009)](www.fantasyduel.com) were created. These markets pay out millions of dollars and are exploding with growth. A majority of this money is payed out to a small percent of players who have developed strategies that are robust to market dynamics.   
![alt text](/Graphics/DraftKings_Payout_Breakdown.png "Source: www.draftkings.com")

## Background
The goal of any fantasy sports league is to select a group of players that will maximize the number of points that you score. Fantasy points are calculated based off of real sporting events. Traditionally, decisions were made on lineups at the beginng of a season with minor changes made on a weekly basis. Fantasy points were then accumulated by a user on a weekly basis and totaled at the end of the season. With Daily Fantasy Sports, lineups are chosen on a more frequent basis (i.e. weekly in the NFL) and thus the number of decisions to be made (and $$$) has increased dramatically. If you're still confused, check out [Draft Kings tutorial](https://www.youtube.com/watch?v=W_0rEGbJVbE).   

We have decided to focus on the NFL for now due to the highly unpredictable nature leading to larger market inefficiencies, as well as our team's interest in the sport. 

## Model Formulation
* Our goal is to maximize the total number of points scored (p_i) by all of our selected players  
* Assign a binary decision variable (X_i) to each player  
  ..* X_i = 1 if player i is in the lineup  
  ..* X_i = 0 otherwise     
* The total sum of all salaries (S_i) for chosen players is constrained to a budget (B)  
*  The lineup must adhere to position constraints  
![alt text](/Graphics/lineup_reqs.png "Source: www.draftkings.com")
* It is common in fantasy football to stack quarter backs and wide receivers that are on the same team. This has to do with their point production correlation. We can acheive through adding a constraint for each team such that the number of WR's >= QB's. 
In mathematical notation this model looks like:

![alt text](/Graphics/basic_model_formulation.png)  
  
All of our data so far come right from DraftKings except the expected number of points for each player (our p_i’s). Expected points could come from any projections website such as Yahoo, FantasySharks,  Rotogrinders, etc. A quick sanity check by plotting projected points scored versus actual points scored shows us just how unpredictable this game is:  

![alt text](/Graphics/predicted_versus_actual.png)
  
So by solving the problem above, we could get one sub-optimal solution and enter that weekly hoping we get lucky. Instead of waiting for our big break, a smarter thing to do would be to re-solve this problem a bunch of times (let's call this M), adding a constraint to the model each time that says the new solution must have an objective function lower than the previous solution. This is of course a pretty cheap way of forcing our lineup to change, but for now it's easy to integrate:
	
![alt text](/Graphics/improved_model_formulation.png)

By solving this problem 50 times using a solver, we get lineups that look a lot like: 
	
![alt text](/Graphics/need_diversity.png)
  
Unfortunately, our lineups don’t show much variation. Check out how many times Victor Cruz and Antonio Brown get into our portfolio... By relying on the same players over and over we really aren’t diversifying our ‘portfolio’ of lineups. Rather than putting all my money on one or two players, let’s consider some more constraints that might help with that.   
*	**Player Frequency:** set a maximum number of times any player can show up in X% of lineups (5%, 10%, 25%)
*	**Lineup Overlap:** set a maximum number of players between any two lineups that can overlap (2,3,4)  
Since we really don't know what the values of these constraints should be, we'll have to test a bunch of different options. We've listed our initial guesses in parenthess. We develop a full factorial design of experiments so that we can easily loop through all of the different combinations of constraints to find the optimal combination. 


We developed this model in Python using the [PuLP package](https://pythonhosted.org/PuLP/index.html). First we import our predefined data set which has information about the player's salary, position, team, and projected points. We then create a PuLP LP object named *NFL* with a maximization objective function.    
```python
player_data = pd.read_csv(projection_filepath)
prob = pulp.LpProblem('NFL', pulp.LpMaximize)
```  
We'll also initiate a bunch of lists and dictionaries which will help us keep track of players, positions, and their teams. 
```python
constraint_details=[]
        players={}
        total_budget=50000
        positions=["QB", "RB", "WR", "TE", "DST"]
        salaries={}
        position_constraints={}
```
We then loop through each row in our player_data.csv file and create a variable in the model for him, adding him and his projected points to our objective function.    
```
 for rownum, row in player_data.iterrows():
            variable=str('x'+str(rownum))
            variable = pulp.LpVariable(str(variable),cat= 'Binary')
            
            player_points = player.projected*variable
            total_cost+= player.salary*variable
            
            objective_function += player_points
```



## Who We Are
**Matt Brondum**  
Matt is   
*www.linkedin.com/in/matthewbrondum*    

**Kyle Cunningham**  
Aside from being the Buffalo Bills #1 Fan, Kyle is a Junior Analytics Consultant at GE Healthcare. Kyle holds a B.S. in Industrial & Systems Engineering from SUNY University at Buffalo and an M.S. in Operations Research from Northeastern University.    
*www.linkedin.com/in/kyle-cunningham-62012383*  

**Sakib Alam**  
Python guru and NBA fanboy, Sakib is currently completing his M.S. in Applied Mathematics at Rice University.   

**Matt Wood**
Matt is a Research Psychologist at the US Army Corps of Engineers Research & Development Center. He holds a PhD in Cognitive Psychology from Carnegie Mellon University and an M.S. in Psychology from Villanova.
*https://www.linkedin.com/in/matthewdwooderdc*
