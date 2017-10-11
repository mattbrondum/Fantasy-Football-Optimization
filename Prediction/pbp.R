# This script uses nflscrapR to pull down all available data from NFL 2009-present
# You may need to occassioanally rerun lines if the NFL SHIELD API connection times out.
# Sleep times between lines ensure you aren't blocked from hitting SHIELD too often.

# data is at play-by-play resolution

# comment out these if you already have devtools & nflscrapR
install.packages('devtools')
library(devtools)
devtools::install_github(repo = "maksimhorowitz/nflscrapR")

# Setting WD & load pkg
setwd("C:/Users/bradd/Documents/FFL/nflscrapR/")
library(nflscrapR)
library(tidyverse)

# Dowloading Play-By-Play Data
pbp2009 <- season_play_by_play(2009)
Sys.sleep(sample(30:300, replace = TRUE))
pbp2010 <- season_play_by_play(2010)
Sys.sleep(sample(30:300, replace = TRUE))
pbp2011 <- season_play_by_play(2011)
Sys.sleep(sample(30:300, replace = TRUE))
pbp2012 <- season_play_by_play(2012)
Sys.sleep(sample(30:300, replace = TRUE))
pbp2013 <- season_play_by_play(2013)
Sys.sleep(sample(30:300, replace = TRUE))
pbp2014 <- season_play_by_play(2014)
 Sys.sleep(sample(30:300, replace = TRUE))
pbp2015 <- season_play_by_play(2015)
Sys.sleep(sample(30:300, replace = TRUE))
pbp2016 <- season_play_by_play(2016)
Sys.sleep(sample(30:300, replace = TRUE))
pbp2017 <- season_play_by_play(2017)

# Saving Data
save(pbp2009, file = "pbp2009.RData")
save(pbp2010, file = "pbp2010.RData")
save(pbp2011, file = "pbp2011.RData")
save(pbp2012, file = "pbp2012.RData")
save(pbp2013, file = "pbp2013.RData")
save(pbp2014, file = "pbp2014.RData")
save(pbp2015, file = "pbp2015.RData")
save(pbp2016, file = "pbp2016.RData")
save(pbp2017, file = "pbp2017.RData")

# combine dataframes for full seasons
pbp2009_2016 <- Reduce(function(x, y) merge(x, y, all=TRUE), list(pbp2009,pbp2010,pbp2011,pbp2012,pbp2013,pbp2014,pbp2015,pbp2016))

# push all data from before this season to CSV
write_excel_csv(pbp2009_2016,path = "pbp2009_2016.csv")
