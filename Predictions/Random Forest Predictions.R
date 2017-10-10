
library(randomForest)


#load data
wrdata <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Github_DFS_Scripts/DFS_Scripts/data/wrdata.csv")
rbdata <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Github_DFS_Scripts/DFS_Scripts/data/rbdata.csv")
tedata <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Github_DFS_Scripts/DFS_Scripts/data/tedata.csv")
qbdata <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Github_DFS_Scripts/DFS_Scripts/data/qbdata.csv")


#QB predictions
qbtrain=sample(1:nrow(qbdata),nrow(qbdata)*.8)
qb.rf = randomForest(fpts ~ .,
                     data = qbdata,
                     subset = qbtrain)




















































