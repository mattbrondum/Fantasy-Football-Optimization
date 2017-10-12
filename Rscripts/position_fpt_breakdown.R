
f <- sqldf ('
            
select 
  p.pos1
  ,percentile_cont (0.25) WITHIN GROUP
		(ORDER BY o.fp3 ASC) OVER(PARTITION BY p.pos1) as percentile_25
  ,o.fp3
  ,o.py * .04 as py 
  ,o.tdp * 4 as tdp
  ,case when o.py > 300 then 3 else 0 end as pyb 
  ,o.ry * .1 as ry
  ,o.tdr * 6 as tdr
  ,case when o.ry > 100 then 3 else 0 end as ryb 
  ,o.rec * 1 as rec
  ,o.tdrec * 6 as tdrec
  ,o.recy * .1 as recy
  ,case when o.recy > 100 then 3 else 0 end as recb 
  ,o.ints * -1 as int
  ,o.fuml * - 1 as fuml
from offense o
left join player p on p.player = o.player
where o.fp3 > 15
group by 1
            ')
write.table(f, "C:\\Users\\Vicky\\Desktop\\pointsdata.csv", sep=",")
