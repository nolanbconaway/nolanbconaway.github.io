---
title: Pitchfork Roundup! What I found in 18,000 Pitchfork Reviews.
excerpt: Pitchfork roundup! On the biases in review scores.
tags: pitchfork, music, data
season: Spring 2017
assets: /blog/assets/pitchfork-roundup
type: blog
layout: post
mathy: true
---


>_Over the Winter of 2016-2017, I scraped over 18,000 reviews published on [Pitchfork](http://pitchfork.com/). I published the dataset on Github, and wrote [several](http://nbviewer.jupyter.org/github/nolanbconaway/pitchfork-data/blob/master/notebooks/author-autocorrelation.ipynb) [Jupyter](http://nbviewer.jupyter.org/github/nolanbconaway/pitchfork-data/blob/master/notebooks/best-new-music-iid.ipynb) [Notebooks](http://nbviewer.jupyter.org/github/nolanbconaway/pitchfork-data/blob/master/notebooks/artist-development.ipynb) [exploring](http://nbviewer.jupyter.org/github/nolanbconaway/pitchfork-data/blob/master/notebooks/review-score-exploration.ipynb) the data. I acquired the data to satisfy a few long-held curiosities about potential biases influencing reviews. This post provides a more in-depth investigation into those questions. For a more code-driven approach, check out the notebooks on [Github](https://github.com/nolanbconaway/pitchfork-data)!_


## Introduction

<!-- Like a lot of people, I have a strong interest in music. I keep up with new releases from my favorite artists, and I make an effort to learn about new artists and genres. In pursuit of these ends, I've found online music media indispensable: through college and much of grad school, I checked [Pitchfork](http://pitchfork.com/) daily. These days I rely more on recommender systems (e.g., Spotify, Apple Music), but I still often browse Pitchfork to read reviews about albums I'm interested in.
 -->
As a person who reads a fair amount of music criticism, and as a scientist, I've long been curious about the degree of objectivity in reviews of new releases. In a trivial sense, there is of course no such thing as an _objective_ assessment for the quality of a piece music, and obviously reviews are subject to the personal taste of each reviewer. But that subjectivity does not render the review useless. Clearly, readers take something away from music reviews (otherwise why would they be read?), and major publications are thought to have wide influence on the behavior of listeners (though, as far as I can tell, there's no data to back up that claim).

So, while subjective, music reviews are at least _interpreted_ as an authoritative opinion. Setting aside the routine subjectivity having to do with personal taste, the cognitive scientist in me wonders about sources of systematic bias in how favorably albums are reviewed. To address my curiosity, I collected over 18,000 reviews published on [Pitchfork](http://pitchfork.com/) between January 1999 and January 2017. I chose Pitchfork because it is widely viewed as authoritative, publishes a large amount of content (25+ reviews per week), and offers a precise scoring (0.0-10.0) of each album (so I don't need to dive into the NLP). In this post, I'll describe what I found.

## The Reviews

It's worth briefly describing what a Pitchfork review entails, and establishing some basic descriptives. Since 1998, Pitchfork has published five new reviews every weekday. In 2016, Pitchfork added an additional five reviews on Saturdays, as well as a "Sunday Reviews" section containing single, long-form article on a classic album (one review per week, published on Sundays). They've also occasionally published more targeted series of reviews on individual artists or groups (such as following the deaths of [David Bowie](http://pitchfork.com/artists/438-david-bowie/) and [Prince](http://pitchfork.com/artists/3397-prince/))

The typical review addresses a single release by a specific artist, and is attributed to a single author. However, sometimes reviews are published for multiple albums, or by multiple artists, or are authored by multiple individuals. All reviews are given a numerical score (0.0-10.0), are labeled by one or more genre tags, report the record label (if any), and contain several paragraphs of text (the review itself). Since 2003, authors have awarded some releases the title "_Best New Music_", which means what you'd think. Best New Music albums are displayed prominently on Pitchfork, and even have their own [page](http://pitchfork.com/reviews/best/albums/).

Album scores and Best New Music awards will be the focus of my analysis, so it's worth taking a look at those distributions.

{% include svg.html content="score-bmn-hist.svg" %}

> Note: Most high scoring albums that are _not_ Best New Music are from reviews prior to the advent of Best New Music, or are reviews of classic releases.

A little more than 5% of reviews are awarded Best New Music. Most scores lie between 6.4 and 7.8, with the average review getting a score of 7.0. Best New Music is typically awarded to albums scoring greater than 8.5. Scores between 8.1 and 8.5 have a decent shot at Best New Music, but many albums in that range are not given the title. 

## Authorship Biases

The first source of bias I considered was the authors of the reviews themselves. We know from research in cognitive psychology that decisions made by people are [all sorts of biased](https://en.wikipedia.org/wiki/List_of_cognitive_biases#Decision-making.2C_belief.2C_and_behavioral_biases), and I imagine that deciding ob an album's score and the Best New Music status is subject to those biases just like anything else.

### Statistical Heaping

Partly inspired by a [really cool blog post](https://gutterstats.wordpress.com/2015/11/03/are-nfl-officials-biased-with-their-ball-placement/) about bias in decisions about the line of scrimmage in American Football, I thought about what a reviewer might do if they have a _general_ sense of the album's score, but they need to pick a _specific_ value. Is this a 7.8? 7.9? 7.7? The above mentioned post found that NFL officials tend to place the line of scrimmage at tidy yard numbers (i.e., 10s and 5s). The technical term for this is [statistical heaping](http://ww2.amstat.org/sections/SRMS/Proceedings/y1958/Patterns%20Of%20Heaping%20In%20The%20Reporting%20Of%20Numerical%20Data.pdf), and its observed commonly in survey data. So maybe Pitchfork reviewers behave similarly? I counted the number of scores at each decimal place (e.g., \\( *.0, *.1... *.9 \\)), here's the result:

{% include svg.html content="score-anchor-points.svg" %}

Those diamond markers show what you'd expect if Pitchfork reviewers were totally unbiased. The _Uniform Sampling_ model is what you'd get if you picked scores at random; the _Normal Sampling_ model shows what you'd get if you picked scores around a normal distribution  based on the observed scores (\\(\mu=7.006, \sigma = 1.294\\)). *.0 gets a slight bump in the uniform model because 10.0 is a possibility, but 10.1-10.9 are not. 

Obviously, the tidy, round *.0 value is much more frequently chosen than you'd expect given either sampling technique. _Its very nearly twice as frequent as *.1_. There's also a slight bump at the *0.5 and *.8  marks, but those values are a bit weaker. The point is, Pitchfork reviewers absolutely show the heaping behavior: at least in this sense, the review scores are biased. 

### Borderline Best New Music Decisions

Still, its important to consider that the impact of the heaping bias is not _huge_. We're taking about a reviewer picking between, for example, a score of 6.9 or 7.0, which is not a big difference overall. A more impactful difference lies in the choice to award a release the title of Best New Music. As I noted above, while most releases scoring better than 8.5 are given the award, releases scoring between 8.1 and 8.5 may be Best New Music but it is not in any sense guaranteed. I wonder about how are these decisions made, and if there are any sources of bias guiding the decision-making of reviewers.

I reduced the dataset to only the reviews posted after the advent of Best New Music, excepting those posted on Sundays (which are often high scoring but not Best New Music), within the critical 8.1-8.5 range. There are 1565 such cases, only 408 of which (26.1%) are Best New Music. My guess is that granting Best New Music status is somewhat reserved at Pitchfork; Best New Music is only meaningful if it is relatively scarce. So maybe authors would be less likely to award Best New Music to a new release if they had recently awarded it in another review? 

Answering this question is tricky, since authors vary in how frequently they award Best New Music. For each borderline Best New Music, I tracked down the author's previous review to see if _that_ was Best New Music. The result is a contingency table, but the numbers are a deceptive. In the interest of full disclosure, I'll report the results here:

{:.datatable}
|                 |   Prior Regular Review   |  Prior Best New Music   |  
|  ---            |   :---:                  |  :---:                  |  
|  Regular Review |     1061 (*76%*)         |  72 (*56%*)             | 
|  Best New Music |     345  (*24%*)         |  57 (*44%*)             | 

> Note: Although there are 1565 borderline Best New Music candidates, 30 of these are from the first review posted by an author, and so there is no prior review to reference. These candidates are excluded from the above data.


When the author's previous article was _not_ best New Music, there's a 24% chance that a borderline album will be awarded Best New Music. but when the author's previous article _was_ Best New Music, that chance shoots up to 44%. That is in no sense a _small_ difference, and its obviously inconsistent with my intuition (that a recent Best New Music will decrease the probability of an award to a borderline album). But I wonder if this is really indicating something about individual author behavior









- How are borderline BNM decided on?

### Autocorrelations

- Influence of a recent negative or positive score on the following review. 



## Institutional Biases

How does the Pitchfork institution influence reviews?

- Distribution of scores / best new music per day / week.
- What gets reviewed? What doesn't? 
