rm(list=ls())

library(sqldf)
library(ggplot2)

# grab the data
con = dbConnect(SQLite(), dbname="pitchfork.db")
borderline = dbGetQuery( con,
	paste('SELECT reviewid, pub_date, score, best_new_music, author FROM reviews', 
		'WHERE (score BETWEEN 8.1 AND 8.5)',
		'AND (pub_weekday < 6)',
		'AND substr(pub_date,1,4)|| substr(pub_date,6,2)|| substr(pub_date,9,2) > "20030114"')
)
all_reviews = dbGetQuery( con,
	'SELECT reviewid, pub_date, best_new_music, score, author FROM reviews'
)
author_info = dbGetQuery( con,
	paste('SELECT author, AVG(best_new_music), COUNT(*) FROM reviews', 
		'WHERE (pub_weekday < 6)',
		'AND substr(pub_date,1,4)|| substr(pub_date,6,2)|| substr(pub_date,9,2) > "20030114"',
		'GROUP BY author')
)
colnames(author_info) = c('author','proportion', 'count')
dbDisconnect(con)


# convert dates to integers
borderline$unixtime = as.numeric(as.POSIXct(borderline$pub_date , format="%Y-%m-%d"))
all_reviews$unixtime = as.numeric(as.POSIXct(all_reviews$pub_date , format="%Y-%m-%d"))

n = dim(borderline)[1]

# construct a table for regressing
df = data.frame(
	reviewid = integer(n),
	author = character(n),
	score = logical(n),
	bnm = logical(n),
	p  = double(n),
	prev_score = double(n),
	prev_bnm = logical(n),
	stringsAsFactors=FALSE
)

for (i in 1:n) {
	row = borderline[i,]

	# get authors pubs
	idx = all_reviews$author == row$author & all_reviews$unix < row$unix
	author_pubs = all_reviews[idx,]

	# move on if there is no previous publication
	if (dim(author_pubs)[1] == 0 ) { next }

	# get most recent best new music, score
	idx = author_pubs$unix == max(author_pubs$unix)
	most_recent = author_pubs[idx,]
	prev_bnm = any(most_recent$best_new_music)
	prev_score = round(mean(most_recent$score),1)

	author_p = author_info$proportion[author_info$author == row$author]

	# add data to df
	df$reviewid[i] = row$reviewid
	df$author[i] = row$author
	df$score[i] = row$score
	df$p[i] = author_p
	df$bnm[i] = row$best_new_music == 1
	df$prev_bnm[i] = prev_bnm
	df$prev_score[i] = prev_score
}

t = table(df$bnm, df$prev_bnm)
prop.table(t,2)