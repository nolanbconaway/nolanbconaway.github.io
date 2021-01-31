---
title: 2020: The high and low temperatures
date: 2021-01-31
category: blog
keywords: thermometer
---

Two years ago, I hooked up a DS18B20 thermometer to a Raspberry Pi, and I set up a cron job to save the temperature in my postgres database every minute.

A year later, in early 2020, I posted a [year-in-review style article](/blog/2020/2019-the-high-and-low-temperatures) describing the data I had obtained from running the cron job for a full calendar year. Well, we have another year of data and so here I am describing the latest in temperatures from my apartment!

(FYI- You can still check out a real time view of the data via [my heroku webapp](https://temp-in-nolans-apartment.herokuapp.com/).)

## ::fire:: the warmest day

<object type="image/svg+xml" data="{attach}warmest.svg"></object>

In 2019, July 5 was the warmest day I recorded, with temperatures in the ~88&#8457 range. We were out of town that day and had shut off our air conditioning. This year is a similar story, with high temps in early July at about ~88&#8457 . Interestingly (? ::thinking_face::), we were _not_ out of town that day, so we must've roasted pretty good in the apartment.

## ::snow_flake:: the coldest day

<object type="image/svg+xml" data="{attach}coldest.svg"></object>

In 2019 our apartment's heat come from old-school radiators, and we had no control over the temperature. The coldest day (Feb 1 2029, for those keeping track) was the coldest day because the heat simply did not come on as much.

We moved out of that apartment though! Now, we control our own heat (+ and pay for it ::smirking_face::). We were lucky enough to be able to spend New Years Eve with family this year, so we shut off our heat while we were gone. That makes Dec 31 the coldest day I recorded. 

## ::chart_with_upwards_trend:: The most variable day

<object type="image/svg+xml" data="{attach}variable.svg"></object>

In 2019, the most variable day was due to a burglar who **literally left the window open**. We were ::folded_hands:: **not burgled in 2020** ::folded_hands::, so the most variable day was one in which the temperature moved a lot naturally. Our new apartment gets more sun, so the temperature much more strongly follows a daily cycle on sunny days.

## All together!

I found it interesting to plot these days on the same axis so that the changes in temperature over time can be appreciated. Take a look!

<object type="image/svg+xml" data="{attach}everybody.svg"></object>

::waving_hands:: cya in 2022!