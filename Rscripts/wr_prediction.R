

library(readr)
library(caret)
library(randomForest)
library(rpart)

wrdata <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Github_DFS_Scripts/DFS_Scripts/data/wrdata.csv")
rbdata <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Github_DFS_Scripts/DFS_Scripts/data/rbdata.csv")
tedata <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Github_DFS_Scripts/DFS_Scripts/data/tedata.csv")
qbdata <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Github_DFS_Scripts/DFS_Scripts/data/qbdata.csv")


summary(wrdata)
qb,rb
rm(team)

ct <- rpart.control(maxdepth = 25, cp = .002 )
dt <- rpart(fpts ~ ., method = "anova", data = wrdata, control = ct )
plot(dt,uniform = TRUE)
text(dt, pretty =2)

summary(dt)
printcp(dt)
plotcp(dt)

wrpreds <- as.data.frame(predict(dt, newdata = wrdata))

plot(wrpreds, wrdata$fpts)
mean((wrpreds-wrdata$fpts)^2)   # mean squared error
mean(abs(wrpreds-wrdata$fpts))  # mean absolute error
rowMeans(abs((wrdata$fpts-wrpreds)/wrdata$fpts) * 100)
MAPE(as.vector(wrpreds), as.vector(wrdata$fpts))

as.vector(wrpreds)

