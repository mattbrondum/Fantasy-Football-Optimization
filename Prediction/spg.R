# This script uses nflscrapR to pull down all available data from NFL 2009-present
# You may need to occassioanally rerun lines if the NFL SHIELD API connection times out.
# Sleep times between lines ensure you aren't blocked from hitting SHIELD too often.

# data is at game box score resolution

# comment out these if you already have devtools & nflscrapR
install.packages('devtools')
library(devtools)
devtools::install_github(repo = "maksimhorowitz/nflscrapR")

# Setting WD & load pkg
setwd("C:/Users/bradd/Documents/FFL/nflscrapR/")
library(nflscrapR)
library(tidyverse)

spg2009 <- season_player_game(2009)
Sys.sleep(sample(30:300, replace = TRUE))
spg2010 <- season_player_game(2010)
Sys.sleep(sample(30:300, replace = TRUE))
spg2011 <- season_player_game(2011)
Sys.sleep(sample(30:300, replace = TRUE))
spg2012 <- season_player_game(2012)
Sys.sleep(sample(30:300, replace = TRUE))
spg2013 <- season_player_game(2013)
Sys.sleep(sample(30:300, replace = TRUE))
spg2014 <- season_player_game(2014)
Sys.sleep(sample(30:300, replace = TRUE))
spg2015 <- season_player_game(2015)
Sys.sleep(sample(30:300, replace = TRUE))
spg2016 <- season_player_game(2016)
Sys.sleep(sample(30:300, replace = TRUE))
spg2017 <- season_player_game(2017)

# save data frames
save(spg2009, file = "spg2009.RData")
save(spg2010, file = "spg2010.RData")
save(spg2011, file = "spg2011.RData")
save(spg2012, file = "spg2012.RData")
save(spg2013, file = "spg2013.RData")
save(spg2014, file = "spg2014.RData")
save(spg2015, file = "spg2015.RData")
save(spg2016, file = "spg2016.RData")
save(spg2017, file = "spg2017.RData")

# combine dataframes for full seasons
spg2009_2016 <- Reduce(function(x, y) merge(x, y, all=TRUE), list(spg2009,spg2010,spg2011,spg2012,spg2013,spg2014,spg2015,spg2016))
write_excel_csv(spg2009_2016,path = "spg2009_2016.csv")