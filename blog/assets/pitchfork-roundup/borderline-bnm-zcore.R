rm(list=ls())
# this.dir <- dirname(parent.frame(2)$ofile)
# setwd(this.dir)

library(ggplot2)
library(tibble)
library(dplyr)
library(RSQLite)

p4k_db = dbConnect(drv=RSQLite::SQLite(), dbname="pitchfork.db")
cmd = "SELECT score, best_new_music, author
FROM reviews
WHERE score BETWEEN 8.1 AND 8.5
AND pub_weekday < 6
AND pub_date > '2003-01-14'
AND reviewid IN (
	SELECT reviewid 
	FROM years 
	GROUP BY reviewid 
	HAVING COUNT(year)==1
)"
borderline <- as_tibble(dbGetQuery(p4k_db, cmd))

cmd = "
SELECT best_new_music, score, author 
FROM reviews
WHERE author in (
	SELECT author 
	FROM reviews 
	GROUP BY AUTHOR
	HAVING COUNT(author)>4
);"
author_scores <- as_tibble(dbGetQuery(p4k_db, cmd))

dbDisconnect(p4k_db)

n = dim(borderline)[1]
print(n)

# compute author distribution params
author_params = author_scores %>%
  group_by(author) %>%
  summarize(
  		mu = mean(score),
  		sig = sd(score)
  )

data = inner_join(
		borderline, 
		author_params,
		by = 'author'
	)

data$zscore = (data$score- data$mu) / data$sig
# data$best_new_music[data$best_new_music==1] = 'Best New Music'
# data$best_new_music[data$best_new_music==0] = 'Regular Review'

breaks = seq(-1.0,3.5,by=0.2)
bnm = hist(data$zscore[data$best_new_music==1], breaks=breaks, plot=FALSE)
notbnm = hist(data$zscore[data$best_new_music==0], breaks, plot=FALSE)

df = data.frame(
	zscore = bnm$mids,
	best_new_music = bnm$counts,
	regular_review = notbnm$counts
	)
df$p_bnm = df$best_new_music / (df$best_new_music + df$regular_review)
df$n = df$best_new_music + df$regular_review
df = df[df$n>1,]
df$p_bnm_smooth = smooth.spline(x = df$zscore, y= df$p_bnm)$y


print(df)
print(sum(df$n))
print(sum(df$best_new_music))

plot = ggplot(df, 
		aes(x=zscore, 
			y=p_bnm_smooth,
			colour = n
		)
	) + 
	# geom_vline(xintercept = 0, color = '#90A4AE', linetype="dashed") +
	geom_line() +
	geom_point(size = 5) + 
	xlab("Review Z Score") +
	ylab("Proportion Best New Music") +
	scale_x_continuous(breaks = seq(from=-1,to=3,by=0.25)) +
	scale_y_continuous(breaks = seq(from=0,to=1,by=0.1)) +
	scale_colour_gradient(low="#B2DFDB",high="#004D40") + 
	theme_bw(base_size = 12) +
	theme(
		panel.grid.minor.x = element_blank(),
		panel.grid.major.x = element_blank(),
		legend.direction="horizontal", 
	  	legend.position = c(0.3, 0.9),
	  	panel.grid.minor.y = element_blank(),
	  	axis.title=element_text(size=13)
	) + 
	guides(color=guide_legend(title="Number of Reviews"))

# set up save params, save as svg and png
args = list(
	plot = plot,  
	width = 7.5, 
	height = 3.5, 
	units = 'in'
)
for (ext in c('svg','png')) {
	fname = paste0('borderline-bnm-zscore.',ext)
	curr_args = c(fname, args)	
	if (ext=='png') curr_args = c(curr_args, list(dpi = 100))	
	do.call(ggsave, curr_args)
}