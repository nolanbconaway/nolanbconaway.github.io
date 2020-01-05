---
title: 2019: The high and low temperatures
date: 2020-01-05
category: blog
keywords: retrospective, thermometer
---

Last winter I hooked up a [DS18B20](https://www.adafruit.com/product/374) thermometer to a Raspberry Pi. I set up a [python library](https://github.com/nolanbconaway/thermometer) to read the temperature, and a cron job to save the temperature in my postgres database every minute. Then I built a [webapp](https://temp-in-nolans-apartment.herokuapp.com/) to display the last 24 hours of data. The first stable readings were stored on Jan 5 2019, so we have arrived at one full year of readings from my thermometer project ::tada::!

The data are probably uninteresting to anyone who does not live in my apartment. Actually, they're not even interesting to all the people who _do_ live here ::thinking_face::.

But I think the data can tell a story. At least some of it. This post tells the stories of unusual days in my apartment, from the perspective of temperature measurements.

## Describing a day's temperatures

Early on, I wrote out a SQL view that computes summary statistics on each day's temperature readings. It shows me descriptives like:

| dt         | readings | min  | max  | range | avg  | stddev | avg\_minute\_delta | day\_delta |
|------------|----------|------|------|-------|------|--------|--------------------|------------|
| 2019-01-05 | 1440     | 67.9 | 74.9 | 7     | 71.5 | 1.7    | 0.002              | -3.4       |
| 2019-01-06 | 1440     | 71.2 | 74.8 | 3.6   | 73   | 0.7    | -0.001             | 1.2        |
| 2019-01-07 | 1440     | 68.9 | 73.5 | 4.6   | 70.7 | 1      | -0.003             | 3.7        |
| 2019-01-08 | 1440     | 67.8 | 72.5 | 4.7   | 70.3 | 1.1    | 0.002              | -2.4       |
| 2019-01-09 | 1440     | 69.5 | 73   | 3.5   | 71.6 | 0.8    | 0                  | 0.3        |

Most of those columns have sensible names. `avg_minute_delta` describes the average difference in temperature per minute across adjacent readings. `day_delta` is the difference between the first and last reading in the day.

I looked into these summary stats for days which stand out, days like:

## ::fire:: the warmest day

<object type="image/svg+xml" data="{attach}last-year-in-temperatures/warmest.svg"></object>

The day with the highest average temperature was [July 5](https://temp-in-nolans-apartment.herokuapp.com/date/2019-07-05). We were in Baltimore to celebrate July 4 with my family, so we closed up the windows and shut off the AC and the apartment absolutely _roasted_.

## ::snow_flake:: the coldest day

<object type="image/svg+xml" data="{attach}last-year-in-temperatures/coldest.svg"></object>

Per NYC regulation, landlords are required to maintain a temperature of 68&#8457; during the day in the winter, but on [Feb 1](https://temp-in-nolans-apartment.herokuapp.com/date/2019-02-01) the temperature hung below 66&#8457; all day long. 

## The most variable day

<object type="image/svg+xml" data="{attach}last-year-in-temperatures/most_stddev.svg"></object>

On December 16 we were burgled (**everyone was ok!**). The burglar entered through the fire escape window, which is near where the Raspberry Pi thermometer is tucked away. That huge dip in the temperature is exactly the time the burglar entered the apartment. The detective that caught our case thought this was _awesome_!

## Anomaly Detection

We can also use statistics to identify days with unusual properties. I queried my database with Python like:


```python
import os
import pandas as pd
from sqlalchemy import create_engine

engine = create_engine(os.environ['SQLALCHEMY_DATABASE_URI'])
daily_stats = (
  pd.read_sql_table("daily_stats", engine)
  .assign(dt=lambda x: pd.to_datetime(x.dt))
  .set_index('dt')
)

print(daily_stats.round(2).head())
#             readings    min    max  range    avg  stddev  avg_minute_delta  day_delta
# dt                                                                                   
# 2019-01-05      1440  67.89  74.86   6.98  71.54    1.65               0.0      -3.38
# 2019-01-06      1440  71.15  74.75   3.60  72.96    0.75              -0.0       1.24
# 2019-01-07      1440  68.90  73.51   4.61  70.65    0.95              -0.0       3.71
# 2019-01-08      1440  67.78  72.50   4.72  70.28    1.12               0.0      -2.36
# 2019-01-09      1440  69.46  72.95   3.49  71.62    0.79              -0.0       0.34
```

If we assume all days are drawn from a multivariate normal distribution across the summary stat metrics, \\(x \sim \mathcal{N}\left(\mu, \Sigma\right) \\), outliers would be considered dates with very low \\( p\left(x \vert  \mathcal{N}\left(\mu, \Sigma\right)\right) \\).

I normalized the stats and calculated the empirical parameters for the multivariate Normal distribution. Then I used `scipy.stats` to do the heavy lifting.

```python
import numpy as np
import scipy.stats

zscores = (
    daily_stats
    .drop(columns=['readings'])  # I don't care about reading count
    .apply(lambda col: (col - col.mean()) / col.std())
)

mu = zscores.values.mean(axis=0)
sigma = np.cov(zscores.values.transpose())
density = scipy.stats.multivariate_normal.pdf(zscores.values, mu, sigma)
```

Then I picked out the days with the lowest densities! Here are those dates:

| dt                                                                           | readings | min    | max    | range  | avg    | stddev | avg\_minute\_delta | day\_delta |
|------------------------------------------------------------------------------|----------|--------|--------|--------|--------|--------|--------------------|------------|
| [2019-12-16](https://temp-in-nolans-apartment.herokuapp.com/date/2019-12-16) | 1440     | 50.787 | 71.15  | 20.363 | 65.003 | 6.334  | -0.003             | 3.6        |
| [2019-09-12](https://temp-in-nolans-apartment.herokuapp.com/date/2019-09-12) | 1440     | 74.862 | 86.9   | 12.038 | 83.073 | 3.715  | -0.008             | 11.925     |
| [2019-09-19](https://temp-in-nolans-apartment.herokuapp.com/date/2019-09-19) | 1440     | 65.187 | 77.9   | 12.713 | 73.059 | 4.709  | 0.005              | -7.987     |
| [2019-09-11](https://temp-in-nolans-apartment.herokuapp.com/date/2019-09-11) | 1440     | 77.9   | 87.125 | 9.225  | 82.538 | 3.736  | 0.006              | -8.1       |
| [2019-10-01](https://temp-in-nolans-apartment.herokuapp.com/date/2019-10-01) | 1440     | 73.287 | 82.737 | 9.45   | 78.11  | 3.643  | 0.005              | -7.313     |

The first anomaly is an obvious one: the most variable day of the year which I wrote about above. See below for plots of the other four:

<object type="image/svg+xml" data="{attach}last-year-in-temperatures/anomaly-2019-09-12.svg"></object>
<object type="image/svg+xml" data="{attach}last-year-in-temperatures/anomaly-2019-09-19.svg"></object>
<object type="image/svg+xml" data="{attach}last-year-in-temperatures/anomaly-2019-09-11.svg"></object>
<object type="image/svg+xml" data="{attach}last-year-in-temperatures/anomaly-2019-10-01.svg"></object>

And for good measure, [here](https://temp-in-nolans-apartment.herokuapp.com/date/2019-03-22) is the least anomalous date according to my very naive model.

<object type="image/svg+xml" data="{attach}last-year-in-temperatures/nonanomaly.svg"></object>
