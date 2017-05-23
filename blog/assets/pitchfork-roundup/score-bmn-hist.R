rm(list=ls())

library(sqldf)
library(ggplot2)

# grab the data
con = dbConnect(SQLite(), dbname="pitchfork.db")
reviews = dbGetQuery( con,
	'SELECT score, best_new_music FROM reviews' 
)
dbDisconnect(con)

print(summary(reviews))


# print quantiles of each point
ecdf_fun <- function(x,perc) ecdf(x)(perc)
for (i in seq(0.0,10.0,0.1)) {
	print(c(i, ecdf_fun(reviews$score,i)))
}

# print percentage of scores that are bnm
attach(reviews)
print(aggregate(reviews, by=list(score), FUN=mean))
print(aggregate(reviews, by=list(best_new_music), FUN=mean))

# convert to counts for plotting
counts = as.data.frame(table(reviews))

plot = ggplot(counts, aes(x=score, y = Freq, fill = best_new_music,  colour=best_new_music)) + 
	geom_bar(stat = 'identity', width = 1) + 
	xlab("Score") +
	ylab("Number of Reviews") +
	scale_x_discrete(breaks = seq(from=0,to=10,by=1)) +
	scale_y_continuous(breaks = seq(from=0,to=1000,by=100)) +
	theme_bw(base_size = 10) +
	theme(
	  	legend.title = element_blank(),
	  	legend.position = c(0.2, 0.8),
	  	panel.grid.minor.y = element_blank()
	  ) + 
	scale_fill_manual(
		values=c("#004D40", "#4DB6AC"),
		labels = c("Regular Review", "Best New Music")
	) + 
	scale_colour_manual(values=c("#004D40", "#4DB6AC"), guide=FALSE
	)

# set up save params, save as svg and png
args = list(
	plot = plot,  
	width = 7.5, 
	height = 3.5, 
	units = 'in'
)
for (ext in c('png','svg')) {
	fname = paste0('score-bmn-hist.',ext)
	curr_args = c(fname, args)	
	if (ext=='png') curr_args = c(curr_args, list(dpi = 100))	
	do.call(ggsave, curr_args)
}
