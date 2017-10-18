# Create full factorial using lists

Lineups   <-  c(25, 50, 75)
Frequency <-  c(.05,.1,.25)
Overlap   <-  c(2,3,4)
Stacking  <-  c("None", "QB needs WR")
Ownership <-  c("None")
ObjFct    <-  c('Maximize Points')

scen <- 1
fullfact <- data.frame(   Scenario=character(),
                          Lineups=numeric(),
                          Frequency=numeric(),
                          Overlap=numeric(), 
                          Stacking=character(),
                          Ownership=character(),
                          ObjectiveFunction=character(),
                          stringsAsFactors=FALSE) 

for (lineup in Lineups)
{
  for (freq in Frequency)
  {
    for (over in Overlap)
    {
      for (stack in Stacking)
      {
        for (own in Ownership)
        { 
         for (obj in ObjFct)
          {
            fullfact[nrow(fullfact)+1, ] <- 
                as.list(c(paste("Scenario",scen,sep=""), 
                        lineup, freq, over, stack, own, obj))
            scen <- scen + 1
          }
        }  
      } 
    }
  }
}


write.table(fullfact, "C:\\Users\\Vicky\\Desktop\\Draft Kings\\Github_DFS_Scripts\\DFS_Scripts\\Input\\fullfactorial.csv"
              ,row.names=FALSE, sep=",")

