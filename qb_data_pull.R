
library(sqldf) 
library(tidyr) 
game <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Data/GAME.csv")
offense <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Data/OFFENSE.csv")
player <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Data/PLAYER.csv")

# x: all the applicable games for QB's in game 6-16 of the season
# player_data: returns that players individual statistics

data <- sqldf(' 
with x as (

select 
  o.*, 
  g.*, 
  case when g.v = o.team then g.h else g.v end as opponent --logic to get the opposing team
from offense o
left join player p on o.player = p.player
left join game g on g.gid = o.gid
where 1=1 -- seas > 2005
  and wk > 5 
  and wk < 17
  and pos1 = "QB"
  and fp3 > 10
),

player_data as (
select 
  x.player as player, 
  x.team as team,
  x.opponent as opponent, 
  x.year as year,
  x.wk as wk, 
  x.gid as gid, 
  x.fp3 as fpts,

  avg(y.fp3) as l5g_avg_fpts, 

  -- passing statistics
  avg(y.ints) as l5g_avg_ints,
  avg(y.tdp) as l5g_avg_tdp,
  avg(y.py) as l5g_avg_py,
  avg(y.pc) as l5g_avg_pc,
  sum ( case when y.py > 300 then 1 else 0 end )/count(y.py) as l5g_pct_pyb,

  -- rushing statistics
  avg(y.tdr) as l5g_avg_tdr,
  avg(y.ry) as l5g_avg_ry,
  avg(y.fuml) as l5g_avg_fuml

from x 
left join (select * from offense o left join game g on g.gid = o.gid) as y
  on x.year = y.year
    and x.player = y.player
    and x.wk > y.wk
    and x.wk - y.wk <= 5
group by 1,2,3,4,5,6,7
order by x.player, x.wk, y.wk

)


select 
  pd.*, 
  avg(sck) as l5g_oppdef_sck,
from player_data as pd
left join (
  select * 
  from defense d 
  left join game g on g.gid = d.gid
  ) as d on d.year = pd.year
  and 
  and pd.wk > d.wk
  and pd.wk - y.wk <= 5
  and d.
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14



      ')



fit <- lm(fpts ~ ., data[,c(3:ncol(data))])
summary(fit)













