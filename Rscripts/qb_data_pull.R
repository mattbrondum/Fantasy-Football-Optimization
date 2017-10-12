
library(sqldf) 
library(readr)
library(caret)


game <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Data/GAME.csv")
offense <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Data/OFFENSE.csv")
player <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Data/PLAYER.csv")
team <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Data/TEAM.csv")

# x: all the applicable games for QB's in game 6-16 of the season
# player_data: returns that players individual statistics

data <- sqldf(' 
with x as (

select 
  o.* 
  ,g.* 
  ,case when g.v = o.team then g.h else g.v end as opponent --logic to get the opposing team
  ,case when g.v = o.team then "away" else "home" end as homeaway
  ,t.sk -- as sacks against
from offense o
left join player p on o.player = p.player
left join game g on g.gid = o.gid
left join team t on t.gid = o.gid and t.tname = o.team
where 1=1
  and wk > 5 
  and wk < 18
  and pos1 = "QB"
  and fp3 > 7
),

player_data as (
select 
  x.year as year,
  x.wk as wk, 
  x.gid as gid,
  x.team as team,
  x.opponent as opponent, 
  x.player as player, 
  x.fp3 as fpts,
  x.py as py, 
  x.ry as ry, 
  x.tdp as tdp,
  x.tdr as tdr,
  case when x.homeaway = "home" then 1 else 0 end as ha,
  case when x.temp < 40 then -1 else 1 end as temp, 
  case when x.cond in ("Flurries", "Snow", "Rain", "Thunderstorms", "Windy")
              then -1 else 1 end as cond,

  avg(y.fp3) as l5g_avg_fpts, 

  -- passing statistics
  avg(y.ints) as l5g_avg_ints,
  avg(y.trg) as l5g_avg_trg,
  avg(y.tdp) as l5g_avg_tdp,
  avg(y.pa) as l5g_avg_pa,
  avg(y.py) as l5g_avg_py,
  avg(y.pc) as l5g_avg_pc,
  round(sum ( case when y.py > 300 then 1 else 0 end )/round(count(y.py),1),2) as l5g_pct_pyb,

  -- rushing statistics
  avg(x.sk) as l5g_avg_sacks,
  avg(y.tdr) as l5g_avg_tdr,
  avg(y.ra) as l5g_avg_ra,
  avg(y.ry) as l5g_avg_ry,
  avg(y.fuml) as l5g_avg_fuml,
  round(sum(case when y.ry > 100 then 1 else 0 end )/round(count(y.ry),1),2) as l5g_pct_ryb,

  -- receiving statistics
  avg(x.recy) as l5g_avg_recy,       -- receiving yds
  avg(x.rec) as l5g_avg_rec,         -- receptions
  round(sum(case when y.recy > 100 then 1 else 0 end )/round(count(y.recy),1),2) as l5g_pct_recyb,
  avg(x.tdrec) as l5g_avg_tdrec     -- receiving tds

from x 
left join (select * from offense o left join game g on g.gid = o.gid) as y
  on x.year = y.year
    and x.player = y.player
    and x.wk > y.wk
    and x.wk - y.wk <= 5
group by 1,2,3,4,5,6,7,8,9,10,11,12
order by x.player, x.wk, y.wk

),


tm_game as (
  select distinct gid, seas, wk, h as tm
  from game
  union 
  select distinct gid, seas, wk, v as tm
  from game 
),
              
def_gm as (
select
  tmg.gid, 
  tmg.seas, 
  tmg.wk, 
  tmg.tm,
  sum(pts) as pts,
  sum(ry) as rya, 
  sum(py) as pya,
  sum(fum) as fumforc,
  sum(sk) as sacksforc
from tm_game as tmg
left join team t on tmg.gid = t.gid and tmg.tm != t.tname
group by 1,2,3,4
)

select 
  pd.*, 
  avg(dg.pts) as l5g_oppdef_ptsa,
  avg(dg.rya) as l5g_oppdef_rya,
  avg(dg.pya) as l5g_oppdef_pya,
  avg(dg.fumforc) as l5g_oppdef_fumforc,
  avg(dg.sacksforc) as l5g_oppdef_sacksforc
from player_data as pd
left join def_gm dg on dg.wk < pd.wk 
                      and dg.wk >= pd.wk - 5
                      and dg.seas = pd.year
                      and dg.tm = pd.opponent
where l5g_avg_fpts > 5
group by 1,2,3,4,5,6,7,8,9,10
        ,11,12,13,14,15,16,17,18,19,20
        ,21,22,23,24,25,26,27,28
order by pd.player, pd.gid
      ')

# fix cond 
data$cond <-as.numeric(data$cond)



fit <- lm(fpts~ l5g_avg_tdp + l5g_avg_py + l5g_oppdef_pya + l5g_pct_pyb, data)
summary(fit)

# Find columns that can be removed due to linear separation
linearcombos <- findLinearCombos(data[,c(7:33)])
# (this returns only rush attempts column, so we keep it)

#remove rows with missing values
qbdata <- data[complete.cases(data),c(7:12,14:19,22:23,29:33)]

#narrow down to only top variables
qbdata2 <- qbdata[,c(1:4,7:12,15:17)]


#Normalize the data (center + scale)
qbproc <- preProcess(qbdata2, method = c("center", "scale"))
qbdata3 <- predict(qbproc, qbdata2)
qbdata4 <- predict(qbproc, qbdata3, type = "response")

qbfptsproc <- preProcess(qbdata2[c(1)], method = c("center", "scale"))

#prep formula
x <- names(qbdata3)[2]
for (i in names(qbdata3[,c(3:ncol(qbdata3))]))
  {  x <- paste(x, " + ", i)  }
formula <- as.character(paste("fpts ~ ",x))

pynn <- neuralnet(py ~ l5g_avg_pa + l5g_avg_py + l5g_oppdef_ptsa + l5g_oppdefpya + l5g_oppdefrya,
                  qbdata, hidden = 3, act.fct = 'tanh')

qbnn <- neuralnet(formula, 
                  qbdata3, 
                  hidden = 6, 
                  act.fct = 'tanh')

results <- compute(qbnn,qbdata3[,c(2:13)])
res <- as.data.frame(results$net.result, col.names = "fpts")
colnames(res) <- "fpts"
res <- predict(qbfptsproc, res, type = "response")


plot(qbdata$fpts, res$fpts)



brady <- subset(data, player =="TB-2300")#,  select=c(ID, Weight))

brd <- sqldf('
select sum(o.py)
from offense as o 
left join game as g on g.gid = o.gid
where o.py > 0 and o.player != "MC-0700" and o.player != "TB-2300" and (g.v = "NE" or g.h = "NE") and g.seas = 2005 and wk in (10,11,12,13,14)
             ')


# export data to txt
write.table(data, "C:\\Users\\Vicky\\Desktop\\mydata.csv", sep=",")
fit <- lm(fpts ~ ., data[,c(7:ncol(data))])
summary(fit)





