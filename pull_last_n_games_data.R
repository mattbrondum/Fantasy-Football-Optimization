
library(RODBC)
channel <- odbcConnectAccess("C:\\Users\\Vicky\\Desktop\\draftkings\\dfsdata")


game <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Data/GAME.csv")
off <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Data/OFFENSE.csv")
p <- read_csv("C:/Users/Vicky/Desktop/Draft Kings/Data/PLAYER.csv")

big <- merge(off, game, by ="gid")
big <- merge(big, p, by = "player")


bigqb <- subset(big, pos1 == "QB" & fp3 > 5)

# how many games to look back?
lng <- 7 
preddataB <- data.frame(
                        gid=character(), 
                        player=character(),
                        fpts=double(),
                        ln_fpts_avg=double(),
                        ln_fpts_med=double(),
                        ln_fpts_stdev=double()
                       )


for (i in 1:nrow(bigqb))
{
  avg   <- mean(subset(bigqb, player == bigqb[i,"player"] 
                  & (seas < bigqb[i,"seas"] 
                  | (seas == bigqb[i,"seas"] & wk < bigqb[i,"wk"]))
                  #& wk < bigqb[i, "wk"]
                  #& wk >= bigqb[i, "wk"] - lng
                  ,select=c(fp3))[,1])
  med   <- median(subset(bigqb, player == bigqb[i,"player"] 
                  & (seas < bigqb[i,"seas"] 
                  | (seas == bigqb[i,"seas"] & wk < bigqb[i,"wk"]))
                  #& wk < bigqb[i, "wk"]
                  #& wk >= bigqb[i, "wk"] - lng
                  ,select=c(fp3))[,1])
  stdev <- sd(subset(bigqb, player == bigqb[i,"player"] 
                  & (seas < bigqb[i,"seas"]
                    | (seas == bigqb[i,"seas"] & wk < bigqb[i,"wk"]))
                  #& wk < bigqb[i, "wk"]
                  #& wk >= bigqb[i, "wk"] - lng
                  ,select=c(fp3))[,1])
  preddataB <- rbind(preddataB,list(
                    bigqb[i,"gid"],
                    bigqb[i,"player"],
                    bigqb[i,"fp3"],
                    as.numeric(avg),
                    as.numeric(med),
                    as.numeric(stdev)))
} 

colnames(preddataB) <- c("gid", "player","fpts",
                        "lng_fpts_avg",
                        "lng_fpts_med",
                        "lng_fpts_stdev")



plot(preddataB[1:8000,4],preddata3[1:8000,4])


fit <- lm(fpts ~ lng_fpts_avg, data = preddataB)

coefficients(fit)
summary(fit)



















