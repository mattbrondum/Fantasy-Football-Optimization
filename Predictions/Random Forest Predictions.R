
library(randomForest)
library(readr)
library(ggplot2)

#load data
wrdata <- read_csv("C:\\Users\\Vicky\\Desktop\\Draft Kings\\Github_DFS_Scripts\\DFS_Scripts\\Predictions\\wrdata.csv")
rbdata <- read_csv("C:\\Users\\Vicky\\Desktop\\Draft Kings\\Github_DFS_Scripts\\DFS_Scripts\\Predictions\\rbdata.csv")
tedata <- read_csv("C:\\Users\\Vicky\\Desktop\\Draft Kings\\Github_DFS_Scripts\\DFS_Scripts\\Predictions\\tedata.csv")
qbdata <- read_csv("C:\\Users\\Vicky\\Desktop\\Draft Kings\\Github_DFS_Scripts\\DFS_Scripts\\Predictions\\qbdata.csv")


#wr predictions
set.seed(123)
samplesize <- floor(.75*nrow(wrdata)) 
train_ind <- sample(seq_len(nrow(wrdata)), size = samplesize)
wrtrain <- wrdata[train_ind,c(1,8:13)]
wrtest <- wrdata[-train_ind,c(1,8:13)] 
wr.rf = randomForest(fpts ~ .
                     ,data = wrtrain
                     ,importance = TRUE
                     ,ntree = 100)

plot(wrtrain$fpts, wr.rf$predicted)
mean(wr.rf$mse)

# plot MSE and RSQ
plot(wr.rf$mse)
plot(wr.rf$rsq)


# Plot test predictions
varImpPlot(wr.rf)
res <- predict(wr.rf, wrtest)
plot(res,wrtest$fpts     
     ,xlab = "Random Forest Predicted (fpts)"
     ,ylab = "Actual Fantasy Points Scored"
     ,xlim = c(5,50)
     ,ylim = c(5,50))


newx <- seq(min(wrtest$fpts), max(wrtest$fpts), length.out=100)
preds <- predict(wr.rf, newdata = wrtest, 
                 interval = 'confidence')



#qb predictions
set.seed(123)
samplesize <- floor(.9*nrow(qbdata)) 
train_ind <- sample(seq_len(nrow(qbdata)), size = samplesize)
qbtrain <- qbdata[train_ind,]
qbtest <- qbdata[-train_ind,] 
qb.rf = randomForest(fpts ~ .
                     ,data = qbtrain
                     ,importance = TRUE
                     ,ntree = 100)

plot(qbtrain$fpts, qb.rf$predicted)
sqrt(mean(qb.rf$mse))

plot(qb.rf$mse)

varImpPlot(qb.rf)
res <- predict(qb.rf, qbtest)
plot(res,qbtest$fpts,
     ,xlab = "Random Forest Predicted (fpts)"
     ,ylab = "Actual Fantasy Points Scored"
     ,xlim = c(5,50)
     ,ylim = c(5,50)
)

cor(res,qbtest$fpts)




#te predictions
set.seed(123)
samplesize <- floor(.75*nrow(tedata)) 
train_ind <- sample(seq_len(nrow(tedata)), size = samplesize)
tetrain <- tedata[train_ind,]
tetest <- tedata[-train_ind,] 
te.rf <- randomForest(fpts ~ l5g_avg_tdrec + l5g_avg_recy + l5g_avg_rec
                     ,data = tetrain
                     ,importance = TRUE
                     ,ntree = 50)

plot(tetrain$fpts, te.rf$predicted)
sqrt(mean(te.rf$mse))

plot(te.rf$mse)

varImpPlot(te.rf)
res <- predict(te.rf, tetest)
plot(res,tetest$fpts 
      ,xlab = "Actual Fantasy Points Scored"
      ,ylab = "Random Forest Predicted (fpts)"
      ,xlim = c(5,40)
      ,ylim = c(5,40)
    )

cor(res,tetest$fpts)


#rb predictions
set.seed(123)
samplesize <- floor(.75*nrow(rbdata)) 
train_ind <- sample(seq_len(nrow(rbdata)), size = samplesize)
rbtrain <- rbdata[train_ind,]
rbtest <- rbdata[-train_ind,] 
rb.rf = randomForest(fpts ~ .
                     ,data = rbtrain
                     ,importance = TRUE
                     ,ntree = 100
                     )

plot(rbtrain$fpts, rb.rf$predicted)
sqrt(mean(rb.rf$mse))

plot(rb.rf$mse)

varImpPlot(rb.rf)
res <- predict(rb.rf, rbtest)
plot(res,rbtest$fpts)

cor(res,rbtest$fpts)











#Prepare data for plotting
pos <- c("QB","WR","TE","RB")

for (p in pos) {
  df <- data.frame()
}

# Plot player predictions

qplot(hp, mpg, data=mtcars, shape=am, color=am, 
      facets=pos, size=I(3),
      xlab="Horsepower", ylab="Miles per Gallon") 

















