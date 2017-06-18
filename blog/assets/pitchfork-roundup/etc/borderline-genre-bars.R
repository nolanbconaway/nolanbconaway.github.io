rm(list=ls())
suppressMessages(library(tidyverse))

p4k_db = DBI::dbConnect(RSQLite::SQLite(),"../pitchfork.db")
reviews = tbl(p4k_db, "reviews")
genres = tbl(p4k_db, "genres")
years = tbl(p4k_db, "years")

# reviews that are not special cases (re-relases, etc):
# 	- no only one year listing, which is the pub year or the year before
# 	- no various artists
regular_reviews = years %>%
	group_by(reviewid) %>%
	summarise(maxyear = max(year), nyears = n()) %>%
	filter(nyears==1) %>% # no reissues
	inner_join(select(reviews, artist, reviewid, pub_year), by = 'reviewid') %>%
	filter(maxyear >= pub_year-1,) %>% # no VA
	filter(artist != 'various artists') %>% # no compilations
	collect %>% 
	.[['reviewid']]

# borderlines:
#  - in score range
#  - not sundays
#  - published after start of bnm
#  - are not reissues
borderline = reviews %>%
	filter(score > 8.0, score < 8.6) %>% # score range
	filter(pub_weekday < 6) %>%
	filter(pub_date > '2003-01-14') %>% # not sunday, after start
	filter(reviewid %in% regular_reviews) %>% # is not a reissue
	inner_join(genres,  by = 'reviewid' ) %>%
	group_by(genre) %>%
	summarise(p = mean(best_new_music), bnm = sum(best_new_music), total = n()) %>%
	ungroup() %>%
	arrange(desc(p)) %>%
	collect

DBI::dbDisconnect(p4k_db)

borderline$label = paste0(borderline$bnm, '/', borderline$total)

plot = ggplot(borderline, aes(reorder(genre, p), p)) + 
	geom_col(fill = '#004D40') + 
	geom_text(aes(x = genre, y = 0.01, label = borderline$label), size = 3, colour='white', hjust='inward')+ 
	ylab('Proportion Best New Music') + 
    xlab('') + 
    ggtitle("Borderline Score (8.1-8.6) Best New Music Proportion") + 
    scale_y_continuous(limit=c(0,0.5)) +
    theme_bw(base_size = 10) +
    theme(axis.text.y = element_text(size=11))+
    coord_flip()
	

# set up save params, save as svg and png
args = list(
	plot = plot,  
	width = 5.5, 
	height = 3, 
	units = 'in'
)
for (ext in c('png')) {
	fname = paste0('borderline-genre-bars.',ext)
	fname
	curr_args = c(fname, args)	
	if (ext=='png') curr_args = c(curr_args, list(dpi = 100))	
	do.call(ggsave, curr_args)
}
