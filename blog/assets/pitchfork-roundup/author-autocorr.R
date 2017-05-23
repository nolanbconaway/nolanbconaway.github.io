rm(list=ls())

library(sqldf)
library(ggplot2)

# grab the data
con = dbConnect(SQLite(), dbname="pitchfork.db")
extremes = dbGetQuery( con,
	paste('SELECT reviewid, pub_date, best_new_music, score, author FROM reviews', 
		'WHERE (score < 5.4)', # bottom 10%
		'OR (score > 8.2)', # top 10%
		'AND (pub_weekday < 6)')
)
all_reviews = dbGetQuery( con,
	'SELECT reviewid, pub_date, best_new_music, score, author FROM reviews WHERE'
)
dbDisconnect(con)

# convert dates to integers
extremes$unixtime = as.numeric(as.POSIXct(extremes$pub_date , format="%Y-%m-%d"))
all_reviews$unixtime = as.numeric(as.POSIXct(all_reviews$pub_date , format="%Y-%m-%d"))

n = dim(extremes)[1]

# construct a table for regressing
df = data.frame(
	reviewid = integer(n),
	author = character(n),
	score = logical(n),
	bnm = logical(n),
	prev_score = double(n),
	prev_bnm = logical(n))

for (i in 1:n) {
	row = extremes[i,]

	# get authors pubs
	idx = all_reviews$author == row$author & all_reviews$unix > row$unix
	author_pubs = all_reviews[idx,]

	# move on if there is no previous publication
	if (dim(author_pubs)[1] == 0 ) { next }

	# get most recent best new music, score
	idx = author_pubs$unix == max(author_pubs$unix)
	most_recent = author_pubs[idx,]
	prev_bnm = any(most_recent$best_new_music)
	prev_score = round(mean(most_recent$score),1)

	# add data to df
	contingency$reviewid[i] = row$reviewid
	contingency$this_bnm[i] = row$best_new_music == 1
	contingency$prev_bnm[i] = prev_bnm
	contingency$prev_score[i] = prev_score
}

# remove rows for borderlines withour a previous review
contingency = contingency[contingency$reviewid>0,]

idx = (contingency$prev_score < 8.6) & (contingency$prev_score > 8.0)
subset = contingency[idx,]


# aggregate into table format
tab = table(subset$this_bnm,subset$prev_bnm)
tab
round(prop.table(tab,2),2)

colnames(tab) = c('this_bnm','prev_score','count')

