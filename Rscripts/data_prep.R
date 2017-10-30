# Load libraries
library(sqldf) 
library(readr)
library(caret)

# Load csv's from Armchair Analytics
game <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Data/GAME.csv")
offense <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Data/OFFENSE.csv")
player <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Data/PLAYER.csv")
team <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Data/TEAM.csv")

# x: all the applicable games for QB's in game 6-17 of the season
# player_data: returns that players individual statistics for previous games in season



plot(subset(data, pname =="B.Favre")$fpts,subset(data, pname =="B.Favre")$l5g_avg_fpts)
data <- sqldf(' 
with x as (

select 
  o.* 
  ,g.* 
  ,p.pname
  ,case when g.v = o.team then g.h else g.v end as opponent --logic to get the opposing team
  ,case when g.v = o.team then "away" else "home" end as homeaway
  ,t.sk -- as sacks against
  ,p.pos1 as pos
from offense o
left join player p on o.player = p.player
left join game g on g.gid = o.gid
left join team t on t.gid = o.gid and t.tname = o.team
where 1=1
  and wk > 5 
  and wk < 18
  and pos1 in ("QB","WR","RB","TE")
  and fp3 >= 
        (case when pos = "QB" then 10
              when pos = "WR" then 1
              when pos = "RB" then  7
              else 5 end) 
),

player_data as (
select 
  x.year as year,
  x.wk as wk, 
  x.gid as gid,
  x.team as team,
  x.opponent as opponent, 
  x.player as player, 
  x.pname,
  x.pos,
  x.fp3 as fpts,
  x.py, 
  x.ry, 
  x.tdp,
  x.tdr,
  case when x.homeaway = "home" then 1 else 0 end as ha,
  case when x.temp < 40 then -1 else 1 end as temp, 
  case when x.cond in ("Flurries", "Snow", "Rain", "Thunderstorms", "Windy")
              then -1 else 1 end as cond,

  avg(y.fp3) as l5g_avg_fpts, 
  max(y.fp3) as l5g_max_fpts, 

  -- passing statistics
  avg(round(cast(y.ints as decimal),2)) as l5g_avg_ints,
  avg(round(cast(y.trg as decimal),2)) as l5g_avg_trg,
  avg(round(cast(y.tdp as decimal),2)) as l5g_avg_tdp,
  avg(round(cast(y.pa as decimal),2)) as l5g_avg_pa,
  avg(round(cast(y.py as decimal),2)) as l5g_avg_py,
  avg(round(cast(y.pc as decimal),2)) as l5g_avg_pc,

  max(y.ints) as l5g_max_ints,
  max(y.trg) as l5g_max_trg,
  max(y.tdp) as l5g_max_tdp,
  max(y.pa) as l5g_max_pa,
  max(y.py) as l5g_max_py,
  max(y.pc) as l5g_max_pc,

  round(sum ( case when y.py > 300 then 1 else 0 end )/round(count(y.py),1),2) as l5g_pct_pyb,

  -- rushing statistics
  avg(round(cast(y.tdr as decimal),2)) as l5g_avg_tdr,
  avg(round(cast(y.ra as decimal),2)) as l5g_avg_ra,
  avg(round(cast(y.ry as decimal),2)) as l5g_avg_ry,
  avg(round(cast(y.fuml as decimal),2)) as l5g_avg_fuml,

  max(y.tdr) as l5g_max_tdr,
  max(y.ra) as l5g_max_ra,
  max(y.ry) as l5g_max_ry,
  max(y.fuml) as l5g_max_fuml,

  round(sum ( case when y.ry > 100 then 1 else 0 end )/round(count(y.ry),1),2) as l5g_pct_ryb,

  -- receiving statistics
  avg(round(cast(y.recy as decimal),2)) as l5g_avg_recy,     -- avg receiving yds
  avg(round(cast(y.rec as decimal),2)) as l5g_avg_rec,       -- avg receptions
  avg(round(cast(y.tdrec as decimal),2)) as l5g_avg_tdrec,   -- avg receiving tds

  max(y.recy) as l5g_max_recy,                -- max receiving yds
  max(y.rec) as l5g_max_rec,                  -- max receptions
  max(y.tdrec) as l5g_max_tdrec,              -- max receiving tds

  round(sum(case when y.recy > 100 then 1 else 0 end )/round(count(y.recy),1),2) as l5g_pct_recyb


from x 
left join (select * from offense o left join game g on g.gid = o.gid) as y
  on x.year = y.year
    and x.player = y.player
    and x.wk > y.wk
    --and x.wk - y.wk <= 5
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
having count(distinct y.gid) >= 3
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
  avg(dg.pts) as avg_oppdef_ptsa,
  avg(dg.rya) as avg_oppdef_rya,
  avg(dg.pya) as avg_oppdef_pya,
  avg(dg.fumforc) as avg_oppdef_fumforc,
  avg(dg.sacksforc) as avg_oppdef_sacksforc,

  max(dg.pts) as max_oppdef_ptsa,
  max(dg.rya) as max_oppdef_rya,
  max(dg.pya) as max_oppdef_pya,
  max(dg.fumforc) as max_oppdef_fumforc,
  max(dg.sacksforc) as max_oppdef_sacksforc

from player_data as pd
left join def_gm dg on dg.wk < pd.wk 
                      --and dg.wk >= pd.wk - 5
                      and dg.seas = pd.year
                      and dg.tm = pd.opponent
where l5g_avg_fpts > 
        (case when pos = "QB" then 10
              when pos = "WR" then 12
              when pos = "RB" then  7
              else 5 end) 
group by 1,2,3,4,5,6,7,8,9,10
        ,11,12,13,14,15,16,17,18,19,20
        ,21,22,23,24,25,26,27,28,29,30
        ,31,32,33,34,35,36,37,38,39,40
        ,41,42,43,44,45
order by pd.player, pd.gid
      ')


# fix cond 
data$cond <-as.numeric(data$cond)

#QB columns to remove
drops <- c("year","wk","team","player","pname","pos","tdr","ry","temp","py","tdp","year","wk","gid","team","opponent","player",
           "l5g_avg_trg","l5g_avg_tdr","l5g_avg_ra",
           "l5g_avg_recy","l5g_avg_tdr","l5g_pct_recyb",
           "l5g_avg_tdrec", "l5g_max_trg","l5g_max_tdr","l5g_max_recy","l5g_max_rec","l5g_max_tdrec")
write.table(subset(data, pos == "QB")[ , !(names(data) %in% drops)], 
            "C:\\Users\\Vicky\\Desktop\\Draft Kings\\Github_DFS_Scripts\\DFS_Scripts\\Predictions\\qbdata.csv", 
            sep=",")#, row.names = FALSE)

#WR columns to remove
drops <- c("year","wk","team","player","pname","pos","gid","opponent","py","ry","tdp","tdr","temp",
           "l5g_avg_tdr","l5g_avg_ra","l5g_avg_ry","l5g_pct_pyb",
           "l5g_pct_ryb", "l5g_avg_ints","l5g_avg_tdp","l5g_avg_pa","l5g_avg_py",
           "l5g_avg_pc","l5g_avg_pyb","l5g_avg_sacks","l5g_avg_fuml"
           ,"l5g_max_ints", "l5g_max_tdp", "l5g_max_pa", "l5g_max_py", "l5g_max_pc"
           ,"l5g_max_tdr","l5g_max_ra","l5g_max_fuml","l5g_max_tdr","l5g_max_ra","l5g_max_ry")
write.table(subset(data, pos=="WR")[ , !(names(data) %in% drops)], 
            "C:\\Users\\Vicky\\Desktop\\Draft Kings\\Github_DFS_Scripts\\DFS_Scripts\\Predictions\\wrdata.csv", 
            sep=",", row.names = FALSE)

#TE columns to remove
drops <- c("team","player","pname","pos","year","wk","gid","team","opponent","player","py","ry","tdp","tdr","temp",
           "l5g_pct_ryb","l5g_avg_ints","l5g_avg_tdp","l5g_max_ry","l5g_pct_pyb",
           "l5g_avg_pa","l5g_avg_py","l5g_avg_pc","l5g_avg_pyb","l5g_avg_sacks","l5g_avg_fuml"
           ,"l5g_max_ints", "l5g_max_tdp", "l5g_max_pa", "l5g_max_py", "l5g_max_pc",
           "l5g_max_ra","l5g_max_fuml","l5g_max_tdr","l5g_max_ra","l5g_max_ry","l5g_max_fuml")
write.table(subset(data, pos=="TE")[ , !(names(data) %in% drops)], 
            "C:\\Users\\Vicky\\Desktop\\Draft Kings\\Github_DFS_Scripts\\DFS_Scripts\\Predictions\\tedata.csv", 
            sep=",", row.names = FALSE)

#RB columns to remove
drops <- c("year","wk","team","player","pname","pos","year","wk","gid","team","opponent","player","py","ry","tdp","tdr","temp",
           "l5g_avg_ints","l5g_avg_tdp","l5g_avg_pa","l5g_avg_py","l5g_avg_pc","l5g_avg_pyb",
           "l5g_avg_sacks","l5g_avg_fuml","l5g_max_ints", "l5g_max_tdp","l5g_pct_pyb", "l5g_max_pa"
           , "l5g_max_py", "l5g_max_pc","l5g_max_fuml","l5g_max_recy","l5g_max_rec","l5g_max_tdrec")
write.table(subset(data, pos=="RB")[ , !(names(data) %in% drops)], 
            "C:\\Users\\Vicky\\Desktop\\Draft Kings\\Github_DFS_Scripts\\DFS_Scripts\\Predictions\\rbdata.csv", 
            sep=",", row.names = FALSE)







