#load packages

library(readr)
library(caret)
library(rpart)

#load data
wrdata <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Github_DFS_Scripts/DFS_Scripts/data/wrdata.csv")
rbdata <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Github_DFS_Scripts/DFS_Scripts/data/rbdata.csv")
tedata <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Github_DFS_Scripts/DFS_Scripts/data/tedata.csv")
qbdata <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Github_DFS_Scripts/DFS_Scripts/data/qbdata.csv")



# WR Predictions
ct <- rpart.control(maxdepth = 30, cp = .002 )
dtqb <- rpart(fpts ~ ., method = "anova", data = wrdata, control = ct )

summary(dtwr)
printcp(dtwr)
plotcp(dtwr)

plot(dtwr,uniform = TRUE)
text(dtwr, pretty =2)

wrpreds <- as.data.frame(predict(dtwr, newdata = wrdata))

plot(wrpreds$`predict(dt, newdata = wrdata)`, wrdata$fpts)
mean((wrpreds-wrdata$fpts)^2)   # mean squared error
mean(abs(wrpreds$`predict(dt, newdata = wrdata)`-wrdata$fpts))  # mean absolute error
MAPE(as.vector(wrpreds$`predict(dt, newdata = wrdata)`), as.vector(wrdata$fpts))





#QB Predictions
ct <- rpart.control(maxdepth = 5, cp = .005 )
dtqb <- rpart(fpts ~ ., method = "anova", data = qbdata, control = ct )
plotcp(dtqb)
summary(dtqb)
printcp(dtqb)

plot(dtqb,uniform = TRUE)
text(dtqb, pretty =2)

qbpreds <- as.data.frame(predict(dtqb, newdata = qbdata))

plot(qbpreds$`predict(dtqb, newdata = qbdata)`, qbdata$fpts)
# mean squared error
mean((qbpreds-qbdata$fpts)^2)   
# mean absolute error
mean(abs(qbpreds$`predict(dtqb, newdata = qbdata)`-qbdata$fpts))
# mean absolute percent error
MAPE(as.vector(qbpreds$`predict(dtqb, newdata = qbdata)`), as.vector(qbdata$fpts))






#rb Predictions
ct <- rpart.control(maxdepth = 10, cp = .01 )
dtrb <- rpart(fpts ~ ., method = "anova", data = rbdata, control = ct )
plotcp(dtrb)


dtrb$variable.importance
printcp(dtrb)

plot(dtrb,uniform = TRUE)
text(dtrb, pretty =2)

rbpreds <- as.data.frame(predict(dtrb, newdata = rbdata))

plot(rbpreds$`predict(dtrb, newdata = rbdata)`, rbdata$fpts)
# mean squared error
mean((rbpreds-rbdata$fpts)^2)   
# mean absolute error
mean(abs(rbpreds$`predict(dtrb, newdata = rbdata)`-rbdata$fpts))
# mean absolute percent error
MAPE(as.vector(rbpreds$`predict(dtrb, newdata = rbdata)`), as.vector(rbdata$fpts))






#te Predictions
ct <- rpart.control(maxdepth = 10, cp = .01 )
dtte <- rpart(fpts ~ ., method = "anova", data = tedata, control = ct )
plotcp(dtte)
dtte$variable.importance
printcp(dtte)
plot(dtte,uniform = TRUE)
text(dtte, pretty =2)


tepreds <- as.data.frame(predict(dtte, newdata = tedata))

plot(tepreds$`predict(dtte, newdata = tedata)`, tedata$fpts)
# mean squared error
mean((tepreds-tedata$fpts)^2)   
# mean absolute error
mean(abs(tepreds$`predict(dtte, newdata = tedata)`-tedata$fpts))
# mean absolute percent error
MAPE(as.vector(tepreds$`predict(dtte, newdata = tedata)`), as.vector(tedata$fpts))

