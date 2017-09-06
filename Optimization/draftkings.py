class Player:
    def __init__(self, projection, variable):
        self.pulp_var = variable

        self.position = projection.Position
        self.name = projection.Name
        self.salary = projection.Salary
        self.GameInfo=projection.GameInfo
        self.projected = projection.AvgPointsPerGame
        self.team = projection.teamAbbrev
        

class LineupCollection:

  def __init__(self):
    self.lineups=[]

  def add_lineup(lineup):
    self.lineups.append(lineup)

  

class Constraints:

  def __init__(self, contraint_type):
    self.constraints={}

  def add_dfs_position(prob, position_constraints):
      positions=["QB", "RB", "WR", "TE", "DST"]
     
