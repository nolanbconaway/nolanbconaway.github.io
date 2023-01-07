---
title: 2022: The high and low temperatures
date: 2023-01-07
category: blog
keywords: thermometer
---

Four years ago I hooked up a thermometer to a Raspberry Pi, and I set up a cron job to save the temperature in my postgres database every minute. Since then, I've posted year-in-review style articles once annually ([2019](/blog/2020/2019-the-high-and-low-temperatures), [2020](/blog/2021/2020-the-high-and-low-temperatures), [2021](/blog/2022/2021-the-high-and-low-temperatures)) describing the data I had obtained from running the cron job for a full calendar year. 

This is another one of those posts!

(FYI- You can still check out a real time view of the data via [my heroku webapp](https://temp-in-nolans-apartment.herokuapp.com/).)

## ::fire:: the warmest day

<object type="image/svg+xml" data="{attach}warmest.svg"></object>

Usually I record the warmest daily temperatures during whatever week we shut off the AC and leave town for a vacation. This year we left in August and let the apartment roast.

## ::snow_flake:: the coldest day

<object type="image/svg+xml" data="{attach}coldest.svg"></object>

Late December was _cold_; anyone in NYC can attest to this. Again, we left town and shut off the heat, so temperatures dropped lower than I've ever seen them in the apartment (<50&#8457;!).

I think it's wild that even on this day, with an outside high temp of 27&#8457;, the sunlight supported 62&#8457; indoor temperatures at one point in the afternoon.

## ::chart_with_upwards_trend:: The most variable day

<object type="image/svg+xml" data="{attach}variable.svg"></object>

The most variable day was an another Fall day with heavy sunlight coming in; quickly warming the apartment from 63&#8457; to 82&#8457; in the space of a few hours.

## All together!

I found it interesting to plot these days on the same axis so that the changes in temperature over time can be appreciated. Take a look!

<object type="image/svg+xml" data="{attach}everybody.svg"></object>

::waving_hands:: cya in 2024!