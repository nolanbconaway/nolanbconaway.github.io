rm(list=ls())
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

library(tidyverse)
p4k_db <- src_sqlite(path = 'pitchfork.db')
my_tbl <- tbl(p4k_db, sql(
	paste('SELECT reviewid, pub_date, best_new_music, score, author FROM reviews', 
		'WHERE (score < 5.4)', # bottom 10%
		'OR (score > 8.2)', # top 10%
		'AND (pub_weekday < 6)')
	)
)
