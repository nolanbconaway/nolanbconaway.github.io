rm(list=ls())

library(sqldf)
library(ggplot2)

# grab the data
con = dbConnect(SQLite(), dbname="pitchfork.db")
scores = dbGetQuery( con,
	'SELECT score FROM reviews' 
)
dbDisconnect(con)

# count each decimal place
value = round(as.vector(scores$score) %% 1.0, 1)
observed = print(as.data.frame(table(value)))
colnames(observed) <- c('decimal','count')

# compute expected values assuming uniform choices
uniform = as.data.frame(table(round(seq(0,10,0.1) %% 1.0,1)))
colnames(uniform) <- c('decimal','count')
uniform$proportion = uniform$count / sum(uniform$count)
uniform$count = uniform$proportion * sum(observed$count)

# compute expected values assuming uniform choices
x = seq(0,10,0.1)
m = mean(scores$score)
s = sd(scores$score)
density = dnorm(x, mean = m, sd = s)
p = density / sum(density)
idx = round(x %% 1.0,1)
normal = data.frame(list(score = x, decimal = idx, prob = p))
normal = aggregate(normal$prob, by=list(normal$decimal), FUN=sum)
colnames(normal) = c('decimal','proportion')
normal$count = normal$proportion * sum(observed$count)

# get x ticks !
xticklabs = character()
for (i in 0:9) {
	xticklabs = c(xticklabs, paste0('*.',toString(i)))
}

# plot it
plot = ggplot(NULL, aes(x = decimal, y = count)) + 
	geom_bar(data = observed, stat = 'identity', colour = '#004D40' , fill = '#004D40') + 
	geom_point(data = uniform, aes(colour = 'Uniform Sampling'), 
		stroke = 1.25, size = 4, shape = 23) + 
	geom_point(data = normal, aes(x = 1:10, colour = 'Normal Sampling   '), 
		stroke = 1.25, size = 6, shape = 23) + 
	ylab("Number of Reviews") +
	scale_y_continuous(breaks = seq(from=0,to=3000,by=500)) +
	scale_x_discrete(breaks=observed$decimal, labels=xticklabs) +
	theme_bw(base_size = 10) +
	theme(
		axis.title.x=element_blank(),
		panel.grid.major.x = element_blank(),
		legend.direction="horizontal", 
		legend.title = element_blank(),
	  	legend.position = c(0.5, 0.9),
	  	panel.grid.minor.y = element_blank(),
	  	axis.text.x  = element_text(size=10),
	  ) + 
	scale_colour_manual(values=c("#009688", "#FFB300"))


args = list(
	plot = plot,  
	width = 7.5, 
	height = 3.5, 
	units = 'in'
)
for (ext in c('png','svg')) {
	fname = paste0('score-anchor-points.',ext)
	curr_args = c(fname, args)	
	if (ext=='png') curr_args = c(curr_args, list(dpi = 100))	
	do.call(ggsave, curr_args)
}

