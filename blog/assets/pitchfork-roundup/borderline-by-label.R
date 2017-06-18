rm(list=ls())
suppressMessages(library(tidyverse))

p4k_db = DBI::dbConnect(RSQLite::SQLite(),"pitchfork.db")
reviews = tbl(p4k_db, "reviews")
labels = tbl(p4k_db, "labels")
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
	filter(score > 8.0, score < 8.5) %>% # score range
	filter(pub_weekday < 6) %>%
	filter(pub_date > '2003-01-14') %>% # not sunday, after start
	filter(reviewid %in% regular_reviews) %>% # is not a reissue
	select(reviewid, score, best_new_music) %>%
	inner_join(labels, by = 'reviewid') %>%
	collect

DBI::dbDisconnect(p4k_db)
borderline

sum(borderline$best_new_music)
overall_p = mean(borderline$best_new_music)

plotdata = borderline %>%
	group_by(label) %>%
	summarise(proportion = mean(best_new_music), avg = mean(score), n = n(), bnm = sum(best_new_music)) %>%
	ungroup() %>%
	filter(n>9) %>%
	mutate(p = dbinom(bnm, n, overall_p)) %>%
	arrange(desc(proportion))
plotdata$countstr = paste0(plotdata$bnm, '/', plotdata$n ,', p=' , round(plotdata$p,2))
plotdata$strcol = plotdata$proportion > 0
plotdata
summary(plotdata$avg)


annot = paste0('Overall probability = ', as.character(round(overall_p,3)))


plot = ggplot(plotdata, aes(reorder(label, proportion), proportion, fill = p)) +
	geom_hline(yintercept = overall_p, color = 'gray', linetype = 'dashed') +  
	geom_col() + 
	geom_text(aes(x = label, y = 0.002, label = countstr, colour = strcol), size = 3, hjust='inward')+ 
	geom_label(aes(x = 1.5, y = overall_p, label = annot), size = 3, fill='white') + 
	ylab('Proportion Best New Music') + 
    xlab('') + 
    ggtitle("Proportion Best New Music Awarded To Borderline Scores (8.1-8.4)") + 
    scale_y_continuous(limit=c(0,0.7), breaks = seq(0,0.7,0.1), expand = c(0.01,0.005)) +
	theme_bw(base_size = 12) +
    theme(
    	axis.text.y = element_text(size=11),
    	panel.grid.major.y = element_blank(),
    	panel.grid.minor.y = element_blank(),
    	legend.position = c(0.85, 0.4),
    	legend.background = element_rect(
    		color = "black", 
    		linetype = "solid")
    ) +
    scale_colour_manual(values = c('black','white'), guide = FALSE) + 
    scale_fill_gradient(
    	low= "#004D40", 
    	high = "#4DB6AC",
    	guide = guide_colorbar(
    		title = 'Binomial Probability',
    		reverse = TRUE
    		))  + 
    coord_flip()

# set up save params, save as svg and png
args = list(
	plot = plot,  
	width = 7.5, 
	height = 3.5, 
	units = 'in'
)
for (ext in c('png', 'svg')) {
	fname = paste0('borderline-by-label.',ext)
	curr_args = c(fname, args)	
	if (ext=='png') curr_args = c(curr_args, list(dpi = 100))	
	do.call(ggsave, curr_args)
}