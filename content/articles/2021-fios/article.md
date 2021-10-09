---
title: I switched telecom providers and have the data
date: 2021-10-09
category: blog
keywords: fios, spectrum, extremely petty
---

In 2019 I started using the python [speedtest-cli](https://github.com/sivel/speedtest-cli) to log network stats to a MySQL database. The original purpose was to visualize the data in a [home network speed webapp](https://nolans-network-speed.herokuapp.com/today) so that I could check on my network every now and again.

Charter Spectrum had been my service provider for a long time, and casually viewing the app frequently revealed service throttling. My contract was for 200mbits download, and there were often hours during the day where my service was throttled beyond 50% of the contract speed.

Here's an example:

<object type="image/svg+xml" data="{attach}spectrum.svg"></object>

Deeply uncool. ::grimacing_face_with_smile_eyes::

So, I switched providers as soon as Verizon Fios set up shop in my neighborhood. This post raises the question: _Is Fios any better?_

## The data

I append speedtest-cli stats to my database every 15 minutes within an airflow job which runs on my raspberry pi. The raspberry pi is connected directly to my router via ethernet and ought to have speeds as fast as I'll get on my network.

I aggregated the speeds to the hour (so each point is the average of four samples) and plotted the timeseries:

<object type="image/svg+xml" data="{attach}raw.svg"></object>

You can notice several things from this view:

1. My contract speed went up to 300 mbits when I switched to Fios (_and_ I am paying less ::winking_face::).
2. Even Fios does not provide its full speed at all times
3. There are obviously fewer throttled periods in the Fios section.

Fios is visibly more reliable, but _how much more reliable_? I calculated average speeds per provider and compared those to the contract speeds:

| Provider | Download (mbits) | Contract Speed | Download / Contract | Download - Contract |
| :------- | ---------------: | -------------: | ------------------: | ------------------: |
| Fios     |            282.3 |            300 |               94.1% |               -17.7 |
| Spectrum |            173.4 |            200 |               86.7% |               -26.6 |

I think that goes a long way in terms of quantifying the improvement in service reliability, but the reliability question itself is better posed as the probability that a provider will perform at some X% of the contract value. I won't notice anything if I'm at 95%, but might notice some sluggishness when it gets down to 50%.

That makes the question a little more specific: _what is the % of hours in which each provider realized service at X% of the contracted value?_

<object type="image/svg+xml" data="{attach}auc.svg"></object>

Both providers provide >0% service 100% of the time (duh), and both provide >100% of the contract service some amount of the time (you can see values above the contract speed above; I am not sure if this is noise or not). 

Crucially, there is a large swath in which Fios outperforms Spectrum. At the most extreme, Fios provided > 47% of service in 99% of hours, whereas Spectrum provided the same level of service only 77% of the time.

This is an extremely Petty analysis and, to be clear, I **do not work for Verizon**; I'm just one of many people happy to enjoy improved network reliability ::smiling_face_with_halo::. You can find my analysis in [this deepnote](https://deepnote.com/project/Spectrum-Vs-FIOS-BD1Vf-OLRbqIDpZyVI1T9Q/%2Fnotebook.ipynb/#00008-fc4d1b26-157c-40d6-afc5-e694ca06987e) (BTW, I ::sparkling_heart:: deepnote). I'm happy to send the data to whomever asks, so ask if you want it!

