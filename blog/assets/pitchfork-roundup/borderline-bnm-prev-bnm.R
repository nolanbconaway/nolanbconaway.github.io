rm(list=ls())
# this.dir <- dirname(parent.frame(2)$ofile)
# setwd(this.dir)

# GOAL: see if p(bnm_{n} | borderline, author) changes as
# a function of p(bnm_{n-1} | author)

suppressMessages(library(tidyverse))

p4k_db = DBI::dbConnect(RSQLite::SQLite(),"pitchfork.db")
reviews = tbl(p4k_db, "reviews")
years = tbl(p4k_db, "years")

# reviews that are not special cases (rre-relases, etc)
regular_reviews = years %>%
	group_by(reviewid) %>%
	summarise(maxyear = max(year), nyears = count(year)) %>%
	inner_join(select(reviews, reviewid, pub_year), by = 'reviewid') %>%
	filter(maxyear >= pub_year-1) %>%
	filter(nyears == 1) %>%
	collect %>% 
	.[['reviewid']]

all_reviews = reviews %>%
	filter(pub_weekday < 6) %>%
	filter(pub_date > '2003-01-14') %>%
	select(reviewid, score, pub_date, best_new_music, author)

borderline = all_reviews %>%
	filter(reviewid %in% regular_reviews) %>%
	filter(score > 8.0 & score <8.6)

authors = borderline %>%
	group_by(author) %>%
	summarise(overall_p = mean(best_new_music), n = count()) 
	# %>% filter(n > 5)

# collect and disconnect
all_reviews = collect(all_reviews)
borderline = collect(borderline)
authors = collect(authors)
DBI::dbDisconnect(p4k_db)

authorproc = function(row) {
	border = filter(borderline, author==row[['author']])
	out = t(apply(border, 1, borderproc))

	# p(bnm|bnm), p(bnm|reg)
	pbnm = mean(out[out[,1]==TRUE,2], na.rm=TRUE)
	preg = mean(out[out[,1]==FALSE,2], na.rm=TRUE)
	return (c(pbnm,preg))
}

borderproc = function(row) {
	prev_review = all_reviews %>%
		filter(author==row[['author']]) %>%
		filter(pub_date<row[['pub_date']]) %>%
		arrange(desc(pub_date)) %>%
		filter(pub_date==max(pub_date)) 

	if (dim(prev_review)[1] == 0) out = NA
	else out = any(prev_review$best_new_music)

	# returns previous best new music, current best new music
	return(c(out, row[['best_new_music']]==1))

}

# compute relevant stats
# authors = authors[1:5,]
proportions = apply(authors, 1, authorproc)

authors = authors %>%
	mutate(prev_bnm = proportions[1,] ) %>%
	mutate(prev_reg = proportions[2,] ) %>%
	mutate(pdiff = prev_bnm - prev_reg ) %>%
	filter(!is.na(pdiff)) %>%
	select(pdiff, prev_reg, prev_bnm)

print(authors)
print(summary(authors))
print(t.test(authors$pdiff,mu=0))
plot = ggplot(authors, aes(pdiff)) + 
	geom_histogram(binwidth = 0.1, center = 0, fill="#004D40") +
	geom_vline(xintercept = 0, color = 'gray', linetype = 'dashed') + 
	xlab("p(Best New Music | Best New Music) - p(Best New Music | ~Best New Music)") +
	ylab("Number of Authors") +
	scale_x_continuous(limits = c(-1, 1)) +
	theme_bw(base_size = 12) +
	theme(
	  	panel.grid.minor.y = element_blank(),
	  	panel.grid.minor.x = element_blank(),
	  	panel.grid.major.x = element_blank(),
	  	axis.title.x = element_text(family='serif')) 

# set up save params, save as svg and png
args = list(
	plot = plot,  
	width = 7.5, 
	height = 3.5, 
	units = 'in'
)
for (ext in c('png','svg')) {
	fname = paste0('borderline-bnm-prev-bnm.',ext)
	curr_args = c(fname, args)	
	if (ext=='png') curr_args = c(curr_args, list(dpi = 100))	
	do.call(ggsave, curr_args)
}
