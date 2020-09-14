---
title: In which I demonstrate that they say "Oh My God" a lot in the show "Friends"
date: 2020-09-13
category: blog
slug: friends-omg
keywords: python, nlp, sqlite, omg
---

We were rewatching some old Friends episodes when I took notice that the phrase _"oh my god"_ comes up a lot in that show. I am a _professional data scientist_ ::chart_with_upwards_trend:: ::bar_chart:: , so I set to quantify exactly just how much more often they say "oh my god" in Friends compared to other shows.

I ended up building a whole website so that it would be easy to ask arbitrary questions about phrase frequency in different TV shows. I [deployed it on heroku](https://friends-omg.herokuapp.com/) so you can ask these questions too. 

This post describes the source data I'm using and looks into a few of my own curiosities! Enjoy,  friends ::right_pointing_magnifying_glass:: .

## Source data

Once you have well-structured data, answering the question "How much do they say phrase _X_ in each show?" is fairly easy. In the simplest case, you can count the number of lines containing a string (thats what I did). 

But as usual, obtaining said well-structured data is not easy.

Luckily, other smart people are asking similar questions of TV show script data, so it wasn't a nightmare to cobble together a script database.

- [Yusuf Sohoye](https://quotennial.github.io/friends-engineering/) had already set up some slick regex to parse through every Friends script.
- [Colin Pollock](https://github.com/colinpollock/seinfeld-scripts) had a ready-to-go sqlite database with every Seinfeld script.
- I found a Sex and the City script CSV on [Kaggle](https://www.kaggle.com/snapcrack/every-sex-and-the-city-script). It needed some manual cleaning and so now I'm pretty sure that I [host](http://nolanc.heliohost.org/omg-data/satc.csv) the cleanest Sex and the City database online.

I wrote out [a python module](https://github.com/nolanbconaway/friends-omg/tree/master/build) to transfer data from each of these sources into a single sqlite database. Each show has its own [table](https://github.com/nolanbconaway/friends-omg/blob/master/build/ddl.sql), and its own python script to transform the raw source data into a schema composed of these four columns:

| Column                | Type      | Example        |
|-----------------------|-----------|----------------|
| `episode_id`          | `varchar` | `"0105"`       |
| `character_name`      | `varchar` | `"monica"`     |
| `episode_line_number` | `integer` | `17`           |
| `line_text`           | `varchar` | `"Oh my god!"` |

Once those data are in place, it's easy to do a count of lines containing any phrase:

```sql
with t as (
  select 
    count(case when lower(line_text) like lower('%{phrase}%') then 1 end) as k,
    count(*) as n
  from "{show}"
)

select k, n, (k + 0.0) / n as p
from t
```

You can run that query once per show to get all the counts you want!

This approach doesn't really work with smaller phrases (e.g., if you want to count lines containing "dog", you'll also get lines containing "hotdog"). It also fails to account for how TV scripts use punctuation to express things differently (e.g., "Oh... My... God..." is not "Oh My God"). But whatever this is fast and easy.

You can download the full (gzipped) SQLite3 database [here](http://nolanc.heliohost.org/omg-data/data.db.gz) (it's not very large) ::face_with_tongue_wink_eye:: .

## Show Me the Numbers Already

You can compute the frequencies of any phrase you'd like using the [app](https://friends-omg.herokuapp.com/) but I've also taken the liberty of exploring some of my own curiosities!

### Oh My God ([click](https://friends-omg.herokuapp.com/?q=oh+my+god))


| Show             | Total Lines | Lines including "oh my god" | Probability of "oh my god" |
|------------------|-------------|-----------------------------|----------------------------|
| Friends          | 61161       | 920                         | 1.504%                     |
| Sex And The City | 39687       | 43                          | 0.108%                     |
| Seinfeld         | 52865       | 112                         | 0.212%                     |

Think about this: _More than 1 in 100 lines of Friends includes the phrase "oh my god"_. Less than **0.25%** of lines in Seinfeld and Sex and the City contain the same phrase.  So they're at least **6x** more likely to say Oh My God in Friends.

[Janice](https://www.youtube.com/watch?v=qSmp1ZSvelY) isn't even the top offender:

 - Rachel: 221 lines
 - Monica: 204 lines
 - Phoebe: 164 lines
 - Ross: 108 lines
 - Chandler: 71 lines
 - Joey: 63 lines

Together, the Friends account for 723/920 occurrences, which is 1.2% of all lines in the show. 

_Oh My God_.

### Talking about New York ([click](https://friends-omg.herokuapp.com/?q=new+york))

All three shows are set around the same time period in New York City. But characters in Sex and the City talk about New York the most:

| Show             | Total Lines | Lines including "new york" | Probability of "new york" |
|------------------|-------------|----------------------------|---------------------------|
| Sex And The City | 39687       | 337                        | 0.849%                    |
| Seinfeld         | 52865       | 83                         | 0.157%                    |
| Friends          | 61161       | 68                         | 0.111%                    |

The majority of occurrences in Sex and the City are via Carrie, who says the phrase in 220 of 14107 lines. That's **1.56%** of her lines, which is more often than they say "oh my god" in Friends! 

### Talking about Food

I checked on the line rates for different kinds of food and drink. Below is a bar chart of the probability that any line will contain the name of the food/drink:

<object type="image/svg+xml" data="{attach}food.svg"></object>


Not a lot to observe as far as I can tell, but it is a little surprising that Seinfeld talks about "coffee" more than Friends given that so much of Friends takes place in the coffee shop ::thinking_face:: .

## More Info

### "What about [some other TV show], Nolan?"

**Please, _please_ point me to the data for the show you'd like added!** 

The data needs to be at the line granularity, so that the `episode_id, character_name, episode_line_number, line_text` schema can be fulfilled. So long as the data can fit into that schema, there's no reason not to add it!

### The Normal Approximation is ::slightly_frowning_face:: for proportions close to 0!

**Please, _please_ submit a PR implementing the [wilson interval](https://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval#Wilson_score_interval)!** 

Or literally ask me once and I'll do it. I am a _professional data scientist_ ::chart_with_upwards_trend:: ::bar_chart:: ::chart_with_upwards_trend:: ::bar_chart:: .