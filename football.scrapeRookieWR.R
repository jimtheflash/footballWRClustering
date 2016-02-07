#### PURPOSE:
# script for scraping NFL wide receiver rookie data from 
# pro-football-reference.com and corresponding NCAA wide receiver data from
# college-football-reference.com


#### LIBRARIES:
library(caret)
library(XML)

#### GET TABLES: NFL
# url with search parameters specified via API
url <- 'http://www.pro-football-reference.com/play-index/psl_finder.cgi?request=1&match=single&year_min=2000&year_max=2015&season_start=1&season_end=1&age_min=14&age_max=48&league_id=&team_id=&is_active=&is_hof=&pos_is_wr=Y&c1stat=height_in&c1comp=gt&c1val=1&c2stat=weight&c2comp=gt&c2val=1&c3stat=g&c3comp=gt&c3val=1&c4stat=targets&c4comp=gt&c4val=1&c5comp=&c5gtlt=lt&c6mult=1.0&c6comp=&order_by=pass_td&draft=1&draft_year_min=2000&draft_year_max=2015&type=B&draft_round_min=1&draft_round_max=98&draft_slot_min=1&draft_slot_max=500&draft_pick_in_round=0&undrafted=1&draft_league_id=&draft_team_id=&college_id=all&conference=any&draft_pos_is_wr=Y&&&&&offset='
# list for storing data frames
dfNFLList <- list()
for (i in 0:5) {
  if (i == 0) {
    df <- readHTMLTable(paste0(url,i), which = 4)
    j <- 1
    dfNFLList[[j]] <- df
    df <- NULL
  } else {
    k <- i*100 # 100 players listed per page
    df <- readHTMLTable(paste0(url,k), which = 4)
    dfNFLList[[i]] <- df
  }
}
# merge lists
dfNFLComplete <- do.call("rbind" , dfNFLList)
# cleanup
rm(df, dfNFLList, i, j, k, url)

#### GET TABLES: NCAA
# url with search parameters specified via API
url1 <- 'http://www.sports-reference.com/cfb/years/'
url2 <- '-receiving.html'
# list for storing data frames
dfNCAAList <- list()
for (i in 1:21) { #set length of i to be span of years from NFL query
    j <- i+1994 # add 1-min year of desired range to i
    df <- readHTMLTable(paste0(url1,j,url2), which = 1)
    df$Year <- rep(j, nrow(df))
    dfNCAAList[[i]] <- df
}
# merge lists
dfNCAAComplete <- do.call("rbind" , dfNCAAList)
# cleanup
rm(df, dfNCAAList, i, j, url1, url2)

#### CLEAN TABLES: NFL
# fix column names
names(dfNFLComplete)[2] <- "Player"
clean1 <- dfNFLComplete[-which(dfNFLComplete$Rk == "Rk"), ]
clean1 <- clean1[-which(clean1$Player == "Ht & Wt"), ]
clean1 <- droplevels(clean1)
names(clean1)[1:38] <- c("Rk",
                         "Player",
                         "Year",
                         "Age",
                         "Draft",
                         "Tm",
                         "Lg",
                         "Ht",
                         "Wt",
                         "BMI",
                         "NFL.G",
                         "NFL.GS",
                         "NFL.Cmp",
                         "NFL.Att",
                         "NFL.CmpPerc",
                         "NFL.PassYds",
                         "NFL.PassTD",
                         "NFL.Int",
                         "NFL.PassTDPerc",
                         "NFL.IntPerc",
                         "NFL.PasserRating",
                         "NFL.SacksTaken",
                         "NFL.SackYds",
                         "NFL.YPA",
                         "NFL.AYPA",
                         "NFL.ANYPA",
                         "NFL.PassYdsPG",
                         "NFL.W",
                         "NFL.L",
                         "NFL.T",
                         "NFL.Tgt",
                         "NFL.Rec",
                         "NFL.RecYds",
                         "NFL.YPR",
                         "NFL.RecTD",
                         "NFL.RecYdsPG",
                         "NFL.CatchRate",
                         "NFL.YPT")
# convert columns from factor to numeric

# TODO: continue fixing column names; 
#  fix column classes; 
#  prepare for merging; 
#  prepare for inclusion of additional NCAA variables at team level

#### SCRATCH
test.df1 <- dfNFLComplete
test.df1$MergeYear <- as.numeric(test.df1$Year) - 1
test.df2 <- dfNCAAComplete
test.df2$MergeYear <- test.df2$Year
test.merge <- merge(x = test.df1, y = test.df2, by = c('Player', 'MergeYear'), all.x = TRUE)
