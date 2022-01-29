---
title: 2021: The high and low temperatures
date: 2022-01-29
category: blog
keywords: thermometer
---

Three years ago I hooked up a thermometer to a Raspberry Pi, and I set up a cron job to save the temperature in my postgres database every minute. Since then, I've posted year-in-review style articles once annually ([2019](/blog/2020/2019-the-high-and-low-temperatures), [2020](/blog/2021/2020-the-high-and-low-temperatures)) describing the data I had obtained from running the cron job for a full calendar year. 

This is another one of those posts!

(FYI- You can still check out a real time view of the data via [my heroku webapp](https://temp-in-nolans-apartment.herokuapp.com/).)

## ::fire:: the warmest day

<object type="image/svg+xml" data="{attach}warmest.svg"></object>

Usually I record the warmest daily temperatures in early July, when summer is in full swing and we've shut off the AC over the July 4 weekend. This year we stuck around NYC for July 4, and instead are looking at June 7 for the warmest day  ::information_desk_person::.

## ::snow_flake:: the coldest day

<object type="image/svg+xml" data="{attach}coldest.svg"></object>

2020's coldest day in the apartment was December 31. Like with the warmest day, we had left town for the holiday and shut off the heat. Interestingly (??), the coldest day in 2021 was _the very next day_: January 1, 2021.

## ::chart_with_upwards_trend:: The most variable day

<object type="image/svg+xml" data="{attach}variable.svg"></object>

Our apartment is southwestern facing, and has floor-to-ceiling windows. We get _a lot_ of sunlight. As a result, I find that the days with the most variance in temperature are sunny days in Spring/Autumn, when temperatures start out cold but the sun quickly heats up the apartment.

March 7, the most variable day of 2021, is one of those such cases: the day started out at a chilly 57&#8457; but rose to a toasty 81&#8457; in the span of five hours!

## All together!

I found it interesting to plot these days on the same axis so that the changes in temperature over time can be appreciated. Take a look!

<object type="image/svg+xml" data="{attach}everybody.svg"></object>

::waving_hands:: cya in 2023!