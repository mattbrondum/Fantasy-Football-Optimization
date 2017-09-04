
library(sqldf) 
library(tidyr) 
rm(p)
game <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Data/GAME.csv")
offense <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Data/OFFENSE.csv")
player <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Data/PLAYER.csv")

rm(data2)

# x gives all the rows where player-games were in 2008-2016 and week was 6-16
# y returns that players individual statistics
data <- sqldf('
with x as (

select o.*, g.*
from offense o
left join game g 
  on g.gid = o.gid
where seas > 2008
  and wk > 5 
  and wk < 17
)

select 
  x.[player], 
  x.[wk] as wk, 
  y.[wk] as prevwk 
from x 
left join 
  (select * from offense o left join game g on g.gid = o.gid) as y
  on x.seas = y.seas
    and x.player = y.player
    and x.wk > y.wk
    and x.wk - y.wk <= 5
order by x.player, x.wk, y.wk

      ')


















