library(readr)
library(ggplot2)
library(plyr)

# Load data 
path = "C:/Users/Vicky/Desktop/Draft Kings/Github_DFS_Scripts/DFS_Scripts/Lineup Generations/"
aggdata<-""
currdata.names <- paste(path,dir(path, pattern =".csv"),sep="")
for(wk in 1:length(currdata.names)){
  currdata <- read_csv(currdata.names[wk])
  aggdata <- rbind(aggdata, cbind(wk,currdata))
}
# Cleanup
rm(currdata,currdata.names, path)
aggdata <- aggdata[2:nrow(aggdata),]

# Type conversion for numeric columns
indx <- grepl('wk|Salary|Value|Iteration|Actual', colnames(aggdata))
aggdata[indx] <- lapply(aggdata[indx],as.numeric)

# --------------------------------------------------
# --------------------------------------------------
# --------------------------------------------------
#                  Generic Plots 
# --------------------------------------------------
# --------------------------------------------------
# --------------------------------------------------

# Predicted versus Actual plot
plot(aggdata$`Projected Value`,aggdata$Actual,
     xlim=c(50,200), ylim=c(50,200),
     xlab="Projected",ylab="Actual")

# Boxplots of Fantasy Pts by scenario
qplot(Scenario, Actual, data=aggdata, geom=c("boxplot"), 
      fill=Scenario, main="Fantasy Pts per Scenario",
      xlab="Scenario", ylab="Actual Fantasy Pts Scored")

cor.test(aggdata$`Projected Value`, aggdata$Actual)



# Now for each scenario we calculate the following statistics
#   - Average # of FPTS scored
#   - % of lineups over N fpts
#   - 90th percentile of FPTS 


g <- group_by(aggdata, Scenario)
avg_by_scen <- summarize(g,
                avg_actual = mean(Actual), ninety_pct = quantile(Actual, .9))


# Average # of FPTS scored
ddply(aggdata$Actual, 'Scenario', mean)

# % of lineups over N fpts

table(aggdata$wk, aggdata$Scenario)

# 90th percentile of FPTS 





