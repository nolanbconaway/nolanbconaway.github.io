---
title: Pitchfork Roundup! What I found in 18,000 album reviews.
excerpt: Pitchfork roundup! Discovering biases within 18,000 album reviews.
tags: pitchfork, music, data
season: Summer 2017
assets: /blog/assets/pitchfork-roundup
type: blog
layout: post
mathy: true
---


>_Over the Winter of 2016-2017, I scraped over 18,000 reviews published on [Pitchfork](http://pitchfork.com/). I published the dataset on Github, and wrote [several](http://nbviewer.jupyter.org/github/nolanbconaway/pitchfork-data/blob/master/notebooks/author-autocorrelation.ipynb) [Jupyter](http://nbviewer.jupyter.org/github/nolanbconaway/pitchfork-data/blob/master/notebooks/best-new-music-iid.ipynb) [Notebooks](http://nbviewer.jupyter.org/github/nolanbconaway/pitchfork-data/blob/master/notebooks/artist-development.ipynb) [exploring](http://nbviewer.jupyter.org/github/nolanbconaway/pitchfork-data/blob/master/notebooks/review-score-exploration.ipynb) the data. This post provides a discussion about what I found. For a more code-driven approach, check out the notebooks on [Github](https://github.com/nolanbconaway/pitchfork-data)!_


## Introduction

As a person who reads a fair amount of music criticism, and as a scientist, I've long been curious about the degree of objectivity in reviews of new releases. There is of course no such thing as an _objective_ assessment for the quality of a piece music, and reviews are based on the personal taste of each reviewer. But also, readers clearly take something away from music reviews (otherwise why would they be read?), and major publications are thought to have wide influence on the behavior of listeners (though, as far as I can tell, there's no data to back up that claim).

So, while subjective, reviews are at least _interpreted_ as authoritative. Setting aside routine subjectivity having to do with taste, the scientist in me wonders about sources of bias observable across many authors. To address my curiosity, I collected over 18,000 reviews published on [Pitchfork](http://pitchfork.com/) between January 1999 and January 2017. I chose Pitchfork because it is widely viewed as authoritative, publishes a large amount of content (25+ reviews per week), and offers a precise scoring (0.0-10.0) of each album. In this post, I'll describe what I found.

## The Reviews

Since 1998, Pitchfork has published five new reviews every weekday. In 2016, Pitchfork added an additional five reviews on Saturdays, as well as a "Sunday Reviews" section containing long-form articles on a classic albums (one review per week, published on Sundays). They've also occasionally published more targeted series of reviews (such as following the deaths of [David Bowie](http://pitchfork.com/artists/438-david-bowie/) and [Prince](http://pitchfork.com/artists/3397-prince/)).

The typical review addresses a single release by a specific artist, and is attributed to a single author. All reviews are given a numerical score (0.0-10.0), are labeled by genre, report the record label (if any), and contain several paragraphs of text (the review itself). Since 2003, authors have awarded some releases the title "_Best New Music_", which means what you'd think. Best New Music albums are displayed prominently on Pitchfork, and even have their own [page](http://pitchfork.com/reviews/best/albums/).

Album scores and Best New Music awards will be the focus of my analysis, so it's worth taking a look at those distributions.

{% include svg.html content="score-bmn-hist.svg" %}

> Note: Most high scoring albums that are _not_ Best New Music are from reviews prior to the advent of Best New Music, or are reviews of classic releases.

A little more than 5% of reviews are awarded Best New Music. Most scores lie between 6.4 and 7.8, with the average review getting a score of 7.0. Best New Music is typically awarded to albums scoring greater than 8.4. Scores between 8.1 and 8.4 have a decent shot at Best New Music, but many albums in that range are not given the title. 

## Statistical Heaping

Inspired by [this really cool blog post](https://gutterstats.wordpress.com/2015/11/03/are-nfl-officials-biased-with-their-ball-placement/), I thought about what a reviewer might do if they have a _general_ sense of an album's score, but they need to pick a _specific_ value. Is this a 7.8? 7.9? 7.7? The above mentioned post found that NFL officials tend to place the line of scrimmage at tidy yard numbers (i.e., 10s and 5s). The technical term for this is [statistical heaping](http://ww2.amstat.org/sections/SRMS/Proceedings/y1958/Patterns%20Of%20Heaping%20In%20The%20Reporting%20Of%20Numerical%20Data.pdf), and its observed commonly in survey data. So maybe Pitchfork reviewers behave similarly? I counted the number of scores at each decimal place (e.g., \\( *.0, *.1... *.9 \\)), here's the result:

{% include svg.html content="score-anchor-points.svg" %}

Those diamond markers show what you'd expect if Pitchfork reviewers were totally unbiased. The _Uniform Sampling_ model is what you'd get if you picked scores at random; the _Normal Sampling_ model shows what you'd get if you picked scores around a normal distribution  based on the observed scores (\\(\mu=7.006, \sigma = 1.294\\)). *.0 gets a slight bump in the uniform model because 10.0 is a possibility, but 10.1-10.9 are not. 

Obviously, the tidy, round *.0 value is much more frequently chosen than you'd expect given either sampling technique: _It's nearly twice as frequent as *.1_. There's also a slight bump at the *0.5 and *.8  marks, but those values are a bit weaker. The point is, Pitchfork reviewers absolutely show the heaping behavior: at least in this sense, the review scores are biased. 

## Borderline Best New Music Decisions

Still, its important to consider that the impact of the heaping is not _huge_. We're taking about a reviewer picking between, for example, a score of 7.0 or 7.1. A more impactful difference lies in the choice to award _Best New Music_. As I noted above, while most releases scoring 8.5 or better are given the award, releases scoring between 8.1 and 8.4 have a shot but it is not guaranteed. I've long wondered about how are these decisions made, so I looked into it.

I reduced the dataset to the borderline Best New Music candidates: there are 1223 in all, 269 (22%) of which are Best New Music. I checked out a bunch of possible explanations for why some get Best New Music and some do not; for full disclosure I'll list them here:

- Are "tougher" authors (who give out lower scores) more or less likely to award Best New Music? _No_.
- Is an artist's first album more likely be awarded Best New Music? _No_.
- Are authors less likely to grant the award if they have less expertise in the genre? _No_.
- Are authors less likely to grant the award if they recently awarded it to another album? _No_.

To Pitchfork's credit: all of these would be reasonable biases to observe and I found little evidence of each. I _did_ find that [some genres are more likely to be considered Best New Music](https://twitter.com/nolanbconaway/status/875568013050658818), but I'm not sure if that constitutes bias or just Pitchfork's focus.

But when I looked into whether some record labels where favored over others, the results were striking. I computed the proportion of borderline cases from each label that were Best new Music; most only had one or two borderlines cases, but here are the labels with at least ten:

{% include svg.html content="borderline-by-label.svg" %}

The first thing to note is that the labels are all major labels or at least big-name indie labels (with the exception of "self-released"). The second thing to note is the huge degree of differences between labels: [4AD](https://en.wikipedia.org/wiki/4AD) got Best New Music on 8/14 borderline cases, and [Thrill Jockey](https://en.wikipedia.org/wiki/Thrill_Jockey), [Relapse](https://en.wikipedia.org/wiki/Relapse_Records), [Nonesuch](https://en.wikipedia.org/wiki/Nonesuch_Records), and [Anti-](https://en.wikipedia.org/wiki/Anti-_(record_label)) collectively went 0 out of 44. 

That _feels_ unlikely, but are those differences routine? I sent each label's data through an unbiased model, where the probability of \\(k\\) Best New Musics out of \\(n\\) borderline cases follows a Binomial distribution, with \\( p=0.22 \\) (the overall proportion of Best New Music among borderline cases). This model (depicted in the figure) shows how likely each label's data is _individually_, but it does not really address the question: How probable is the data _collectively_?  How likely are we to observe four labels with zero Best New Music? How likely are we to observe four labels with more than 40% Best new Music? How likely are we to observe both scenarios simultaneously?

So I did some Monte Carlo sampling. I simulated each label's Best New Music record 1 million times using the above Binomial distributions. Out of the 1,000,000 samples, 4523 (0.4523%) contained four or more labels with zero Best New Music, 22469 (2.2469%) contained four or more labels with more than 30% Best New Music, and only _42_ (_0.0042%_) had both. Obviously, the data we have is _very unlikely_ to occur, assuming each label were awarded Best New Music with equal probability.

Unfortunately, I do not have a clear idea as to why record labels are treated differently. I certainty wouldn't go as far as to suggest that there is _overt_ favoritism. My best theory is that maybe authors _expect_ Best New Music from some labels and they do not expect it from others. These expectations wouldn't usually influence decisions because most releases are clearly Best new Music or they are not, but they emerge in borderline cases. [Let me know](mailto:nolanbconaway@gmail.com) if you can think of a way to test that theory!


## Wrapping Up

The reason why I was interested in revealing these sources of biases is that music reviews carry with them a sense of authority: that the favorability of a review is in some sense objective. But, obviously, authors are people, and [people are biased](https://en.wikipedia.org/wiki/List_of_cognitive_biases#Decision-making.2C_belief.2C_and_behavioral_biases). So it's no surprise that, once you get digging into the data, you can find evidence of all sorts of biases. 

To their credit, in this post I did _not_ report many of the analyses I conducted which uncovered no evidence of bias (like [this one](https://twitter.com/nolanbconaway/status/873754026080436224), or [this one](http://nbviewer.jupyter.org/github/nolanbconaway/pitchfork-data/blob/master/notebooks/reviewer-development.ipynb), or [this one](http://nbviewer.jupyter.org/github/nolanbconaway/pitchfork-data/blob/master/notebooks/best-new-music-iid.ipynb)). Of course, that's not exactly evidence that there is _no_ bias. But, Pitchfork reviewers are professionals, and my guess is that many of them have considered these sorts of biases before, and may even attempt to combat their influence.

As always, feel free to [get in touch](mailto:nolanbconaway@gmail.com) if you have comments/questions, or even if you're just curious about some aspect of the data and you don't want to do the analysis yourself.