# Load libraries
library(sqldf) 
library(nflscrapR)
library(dplyr)

current_week <- 16
#wr:  avg and max recy, rec, tdrec 

nfldata <- season_player_game(2016, Weeks = current_week)

# Add week and fantasy points
startdate <- as.Date("2016-09-07")
#startdate <- as.Date("2017-09-06")
nfldata$wk <- ceiling(as.numeric(nfldata$date - startdate)/7)
nfldata$fpts <- with(nfldata,(  
                  recyds*.1  
                + recept                
                + rec.tds*6  
                
                + ifelse(recyds > 100,3,0)

                + rushyds*.1  
                + rushtds*6 
                + ifelse(rushyds > 100,3,0)
                - fumbslost
                
                + passyds*.04
                + pass.tds*4
                + ifelse(passyds > 300,3,0)
                - pass.ints
                
                + pass.twoptm*2
                + rec.twoptm*6
                + kickret.tds*6))

newd <- sqldf('
with x as (
  select 
  Season
  ,Wk
  ,Date
  ,Team
  ,Name
  ,Fpts
from nfldata
where wk > 5
)        

select 
  x.*
  ,avg(n.fpts) as l5g_avg_fpts
  ,avg(recyds) as l5g_avg_recy
  ,max(recyds) as l5g_max_recy
  ,avg([rec.tds]) as l5g_avg_tdrec
  ,max([rec.tds]) as l5g_max_tdrec
  ,avg(recept) as l5g_avg_rec
from x
left join nfldata n on 1=1 and
  x.season = n.season and 
  x.wk > n.wk and 
  x.team = n.team and 
  x.name = n.name
GROUP BY 1,2,3,4,5,6
HAVING max(recyds) > 10
              ') 


wrdata <- read_csv("C:\\Users\\Vicky\\Desktop\\Draft Kings\\Github_DFS_Scripts\\DFS_Scripts\\Predictions\\wrdata.csv")

match <- sqldf('

select 
  n.name,
  n.wk,
  n.[l5g_avg_fpts] as scrpr_avg_fpts,
  w.[l5g_avg_fpts] as aa_avg_fpts,
  n.[l5g_avg_rec] as scrpr_avg_rec,
  w.[l5g_avg_rec] as aa_avg_rec,
  n.[l5g_avg_recy] as scrpr_avg_recy,
  w.[l5g_avg_recy] as aa_avg_recy,
  n.[l5g_max_recy] as scrpr_max_recy,
  w.[l5g_max_recy] as aa_max_recy
from newd n
inner join wrdata w on 
  n.wk = w.wk
  and n.team = w.team  
  and n.name = w.pname
where w.year = 2016

               ')


plot(match$aa_avg_rec,match$scrpr_avg_rec)


#Get Wide Receiver Summary Statistics
aggwr <- subset(nfldata, wk < 6 & recyds > 0 ) %>% group_by(playerID,name,Team) %>%
  summarise(l5g_avg_fpts = mean(fpts)
            ,l5g_avg_recy  = mean(recyds) 
            ,l5g_max_recy  = max(recyds)
            ,l5g_avg_tdrec   = mean(rec.tds)
            ,l5g_max_tdrec   = max(rec.tds)
            ,l5g_avg_rec   = mean(recept)
            #,l5g_max_rec   = max(recept)
            )
aggwr <- subset(aggwr, l5g_avg_fpts > 5 & l5g_avg_recy > 3)
                
currweek <- subset(nfldata, wk == current_week)[,c(4:6,59)]
currwkdata <- inner_join(aggwr, currweek, by = "playerID")

currwkdata <- currwkdata[,c(5,9,7,6,8,12)]


write.table(currwkdata,"C:\\Users\\Vicky\\Desktop\\Draft Kings\\Github_DFS_Scripts\\DFS_Scripts\\Predictions\\currwkdata.csv", 
            sep=",", row.names = FALSE)






#Use PLAYER file to verify we are only pulling a guy 
# based on his position in the AA data
player <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Data/PLAYER.csv")
wrs <- subset(player, pos1 == "WR")[,c(4,22)]
wrs$nandt <- paste(wrs$cteam,wrs$pname,sep="_")

currwkdata$nandt <- paste(currwkdata$Team.x,currwkdata$name.x,sep="_")

currwkdata <- inner_join(currwkdata, wrs, by="nandt")



new <- subset(data, year ==2016)[,c("wk", "player","fpts"
                                    ,"l5g_avg_recy"
                                    ,"l5g_max_recy"
                                    ,"l5g_avg_tdrec"
                                    ,"l5g_max_tdrec"
                                    ,"l5g_avg_rec")]


