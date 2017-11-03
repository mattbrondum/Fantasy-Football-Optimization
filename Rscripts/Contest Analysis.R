library(xlsx)
library(dplyr)
library(readr)
library(sqldf) 


#load in lineup output as a data frame
wks <- 7
agg_lineup_data <- data.frame()

for (wk in 1:wks) 
  {
  lineupdata <- read_csv(paste("C:/Users/Vicky/Desktop/Draft Kings/Github_DFS_Scripts/Fantasy-Football-Optimization/Lineup Generations/PredictionsWeek", wk, ".csv",sep=""))
  lineupdata <- cbind(wk,lineupdata[complete.cases(lineupdata),])
  agg_lineup_data <- bind_rows(agg_lineup_data,lineupdata)
  }
rm(lineupdata)


# Load in contest data and format
compdata <- read.xlsx("C:/Users/Vicky/Desktop/Draft Kings/Github_Fantasy-Football-Optimization/Fantasy-Football-Optimization/DK Contests/DK 2017 Weeks 1-6 Contest Results/Contest Results Master.xlsx", 1)
compdata <- compdata[complete.cases(compdata),]
compdata[7] <- ifelse(grepl("double",tolower(compdata$Contest.Name)),"Double",
                      ifelse(grepl("triple",tolower(compdata$Contest.Name)),"Triple",
                             ifelse(grepl("quintuple",tolower(compdata$Contest.Name)),"Quintuple",NA)))
colnames(compdata)[7] <- "Multiplier"
colnames(compdata)[1] <- "wk"


# Fantasy Points Scored by each iteration
med <- tapply(agg_lineup_data$Actual,agg_lineup_data$Iteration,mean)
max <- tapply(agg_lineup_data$Actual,agg_lineup_data$wk,max)
plot(med, 
     xlab="Iteration",ylab="Avg FPT's",
     xlim=c(0,80),ylim=c(100,140),
     main="Fantasy Point Reduction by Iteration")
quantile(subset(agg_lineup_data,Iteration <= 25)[23],.71)
plot(max)
plot(mean(Actual),)
#Load in competition data

# Calculate Profit of each Scenario on each competition
# Profit = Money Won - Entry fees


s = 1
w = 1
scen = paste("Scenario", s, sep="")
quantile(filter(x, Scenario == scen & wk == w)[23], .9)

# Percentiles by Scenario - Week
by_scen_wk <- agg_lineup_data %>% group_by(Scenario, wk) %>%
    summarise(`50%`=quantile(Actual, probs=0.5),
            `90%`=quantile(Actual, probs=0.9))

# Percentiles by Scenario (across all weeks)
by_scen <- agg_lineup_data %>% group_by(Scenario) %>%
  summarise(`50%`=quantile(Actual, probs=0.5),
            `90%`=quantile(Actual, probs=0.9))


profit_by_entry <- sqldf ('
  select
      l.Scenario,
      c.Multiplier,
      c.[Buy.In],
      c.[Payout],
      c.[Pts.to.Win],
      l.Actual, 
      case when c.[Pts.to.Win] < l.Actual then (Payout - c.[Buy.In]) else - c.[Buy.In] end as Profit
  from compdata c
  left join agg_lineup_data l on l.wk = c.wk
                 ')

profit_by_scenario <- sqldf ('
  select
    l.Scenario,
    c.Multiplier,
    sum(case when c.[Pts.to.Win] < l.Actual then (Payout - c.[Buy.In]) else - c.[Buy.In] end) as Profit
  from compdata c
  left join agg_lineup_data l on l.wk = c.wk
  group by 1,2
                        ')
plot(profit_by_scenario$Profit)

profit_by_contest <- sqldf ('
    select
      c.[Contest.Name],
      c.[wk],
      l.Scenario,
     sum(case when c.[Pts.to.Win] < l.Actual then (Payout - c.[Buy.In]) else - c.[Buy.In] end) as Profit
   from compdata c
   left join agg_lineup_data l on l.wk = c.wk
   group by 1,2,3
                          ')

library(ggplot2)
library(grid)
library(reshape2)

g2 <- ggplot(subset(profit_by_scenario,Multiplier != 'Quintuple'), aes(x = Multiplier, y = Scenario)) +
  geom_tile(aes(fill = Profit)) +
  scale_fill_gradient(low = 'red', high = 'green')+theme_bw()

# avg points to win doubles / triples
mean(subset(compdata, Multiplier == "Double")$Pts.to.Win)
mean(subset(compdata, Multiplier == "Triple")$Pts.to.Win)

#whats our median 
quantile(subset(agg_lineup_data, Iteration < 100)$Actual, .5)

hist(subset(agg_lineup_data, Iteration < 26)$Actual)


