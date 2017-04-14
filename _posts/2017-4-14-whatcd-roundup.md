---
title: What.CD Hip Hop Roundup.
description: What I've found through analyses of 75,000 torrents tagged 'hip.hop' on What.CD.
keywords: gazelle, music, data
season: Spring 2017
assets: /blog/assets/whatcd-roundup
type: blog
layout: post
mathy: true
---

> _On October 22 2016, I posted a dataset containing metadata for 75,719 music releases that were tagged as "hip.hop" by the What.CD torrent community. My timing could not have been much better: on November 17 2016, What.CD was [shut down](http://www.theverge.com/2016/11/17/13669832/what-cd-music-torrent-website-shut-down) by the French authorities. In the following weeks I [posted](http://nbviewer.jupyter.org/github/nolanbconaway/hip.hop.data/blob/master/hiphop-per-person.ipynb) [several](http://nbviewer.jupyter.org/github/nolanbconaway/hip.hop.data/blob/master/coastal-timeline.ipynb) [Jupyter](http://nbviewer.jupyter.org/github/nolanbconaway/hip.hop.data/blob/master/mixtape-versus-album.ipynb) [Notebooks](https://github.com/nolanbconaway/hip.hop.data/blob/master/most-prolific-artists.ipynb) of my analyses. In this post, I'll describe what I found in a less code-driven fashion. If you'd prefer a more technical read, check out the dataset on [GitHub](https://github.com/nolanbconaway/hip.hop.data)!_

## Introduction

What.CD was an invite-only online music community and bittorrent tracker that operated from October 27, 2007 to November 17, 2016. A [screencap](http://imgur.com/a/YJ5C5) floating around of the site statistics from the morning of the shutdown shows that What.CD possessed a collection of 1,091,186 releases, divided among 885,561 artists. The What.CD community took pride in their large collection of high quality audio: the website had nearly anything you could want, and it had it in several high quality formats.

I thought that the What.CD collection would be a great tool to satisfy a few of my curiosities about hip hop music. The collection was comprehensive, accurately labeled (for the most part), and What.CD users took care to tag each release with genre labels, the release's city or region of origin, and other relevant keywords. Best of all, the data could be accessed and stored programatically through the [What.CD API](https://github.com/WhatCD/Gazelle/wiki/JSON-API-Documentation).


## The Most Popular Releases

First thing that I wanted to know was what the most downloaded releases were. I'll just show the top-10 in list form.

{:.datatable}
|  Artist  |  Release   |  Downloads   |  Staff Pick  |
|---       |---         |---           |---           |
| Various Artists | The What Cd | 76457 |  |
| The Avalanches | Since I Left You | 66193 | *** |
| Various Artists | The What Cd Volume 2 | 52645 |  |
| Gorillaz | Plastic Beach | 50743 |  |
| Kanye West | My Beautiful Dark Twisted Fantasy | 50697 |  |
| Macklemore & Ryan Lewis | The Heist | 48438 | *** |
| Wu-Tang Clan | Enter The Wu-Tang (36 Chambers) | 46770 | *** |
| Jay-Z & Kanye West | Watch The Throne | 42070 |  |
| Kanye West | Yeezus | 40701 |  |
| Run The Jewels | Run The Jewels | 38618 | *** |

>_Note_: "The What CD" is a collection of music produced by members of What.CD.

These data reveal a surprisingly mainstream hip hop audience, given that What.CD users are far from a representative sample of music consumers in general. These are individuals who, in the service of obtaining high-fidelity downloads, are (A) motivated to learn about bittorrent technology, (B) willing to invest time in a private tracker's website. So I was expecting a somewhat niche-driven audience.

The non-representativeness of the What.CD user-base raises questions about how strongly What.CD download numbers generalize: _If a release is popular on What.CD, can you expect it to be popular outside of What.CD?_ To answer that question, you'd need to connect these numbers to album sales, review scores, or something likewise. I haven't done that (_yet_). But looking through the list informally, I have found that the most frequently downloaded releases on What.CD tend to be huge commercial (and usually critical) successes. 

The only case where this principle seems to be violated (again, I'm pretty much eyeballing things here) is when a somewhat unknown release was tagged as a "staff pick". Staff picks were a collection of releases selected by staff members of What.CD, and released to the community under a "free-leech" status, so that downloading the release did not affect the user's download/upload ratio (which had to be kept at a certain level). Staff picks were widely anticipated and downloaded by users, hence the inflated download rate.

Speaking of staff picks, I think it says something about Kanye's popularity that you can find him three times in the top 10, but never on a staff pick. Out of the top 10 most popular releases, six are not a staff pick, and two of those are an in-house compilation called "The What CD" which was not eligible for a staff pick. So that leaves only four releases in the top 10 that _could_ have been a staff pick but were not, and Kanye West accounts for three of them. Obviously, the users of What.CD were interested in Kanye West, but the staff was not. (FYI: I checked: that's not indicative of a more systematic divide between the users and staff.)

## Who is the most prolific artist in hip hop?

The second thing I wanted to know was who the hardest working artists are: "hardest working" being defined as the number of albums and mixtapes released. I didn't count singles, EPs, compilations, and so on because the amount of new music published on these release types is not as significant. So I just counted the number of albums and mixtapes released by each artist, here are the top-10s:

<p><img src="{{page.assets}}/prolific-artists.png"></p>

If you look at the overall number of releases (left), the list is dominated by well-known artists who have had reasonably long careers, but there's also a few lesser-known artists who have been grinding away at new content for some time. It's also worth noting that [Dj Screw](https://en.wikipedia.org/wiki/DJ_Screw) produced more releases than the next six artists combined, which is remarkable when you consider that his career was cut short when he was only 29 years old.

 I think the "true" metric of hard work is in the number of releases per year. The cumulative total numbers favor artists with longer careers (hence, more time to make music) and penalize artists who have produced a lot of music in a shorter span of time. The dataset only offers a rough measurement of releases per year: each artist's total output, divided by the range of years the albums/mixtapes were released between. 

 These data (on the right) yield an entirely different picture. Dj Screw is still in the top spot, but his lead is not _crushingly_ huge. None of the other artists on the list are in the cumulative top 10. Likewise, excepting Dj Screw, nearly all of their music was released within the last couple of years. [Bruce Lee](https://brucelee315.bandcamp.com/), for example, released 20 mixtapes in 2016 (many of which were separate discs of the '_Dragon_' series). If you exclude artists with less than 3 years of activity, the listing looks a lot more like the cumulative total. Regardless, this pattern suggests that there's something of a new breed of proflific producers on the scene.

So who is the most prolific artist in hip hop? Obviously, the answer is **Dj Screw**.

<div class="videoembed">
<iframe src="https://www.youtube.com/embed/K_h55O66uf0" allowfullscreen></iframe>
</div>

## Where is hip hop coming from?
<!-- citypop vs hip hop -->
<!-- east vs west vs third coast -->




