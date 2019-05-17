---
title: A single sample poisson test.
excerpt: Computing sample probabilities from a Poisson distribution.
tags: python, poisson
season: Summer 2019
type: blog
layout: post
mathy: true
---

I am working with a lot of Poisson data recently. The more I encounter these data, the more I realize that data scientists often incorrectly treat Poisson data as normally or linearly distributed variables.

I recently added a new tool to my Poisson kit, which I think of as a "Single Sample Poisson test". The question being asked is:

> What is the probability of drawing \\(N\\) samples with mean \\(\bar{x}=\sum_i{N_i} \div N\\) from a Poisson distribution with mean \\(\mu\\)?

An example to make things more concrete. Search platforms like google/bing/yahoo allow you to bid a certain amount to show an ad when someone searches for a given keyword. You only pay the search engine if the ad is clicked on. They usually won't charge you the full price of the bid, but some unknown lower amount that we refer to as the cost-per-click (CPC).

Imagine we are hoping to pay a 100 cent ($1 USD) CPC.  We can measure how much we actually paid for each click, but as clicks come in they have variable prices:

{:.datatable}
|  Time  | Price (cents) |
| --- | --- |
| 9:01am | 120 |
| 9:01am | 95  |
| 9:01am | 99  |
| 9:02am | 101 |
| 9:02am | 98  |

Above are 5 samples with an average CPC of 102.6 cents. How likely are we to obtain 5 samples with an average of 102.6, assuming that the true CPC is 100? If \\(N=5\\) samples with \\(\bar{x}=102.6\\) is unlikely given a distribution with \\(\mu=100\\), then clearly we are not correctly targeting the CPC value.

## The Test

A traditional approach to this question might treat the samples as normally distributed and use a Student's T-Test or a Sign test. This works a lot of the time due to the fact that [Poisson data are approximately normal when \\(\mu > 20\\)](http://socr.ucla.edu/Applets.dir/NormalApprox2PoissonApplet.html).

If you want a "pure-Poisson" approach, you need to think about it another way. I took part in a [very interesting SO discussion](https://stats.stackexchange.com/questions/399803/compute-sample-probabilities-given-a-poisson-distribution) in which a [Very Smart Person](https://stats.stackexchange.com/users/85665/bruceet) basically gave me the answer. I will relate that answer here.

In short, drawing \\(N\\) samples with an average of \\(\bar{x}\\) is like drawing a single sample from a higher distribution, which has the value \\(\sum_i{x_i} = N\bar{x}\\). We can think about that value within the context of a distribution \\(\mathsf{Poisson}(N \mu)\\), which would tell us how unlikely our samples are:

$$
N \bar x \sim \mathsf{Poisson}(N \mu).
$$

For example, the CDF of \\(\mathsf{Poisson}(N \mu)\\) would tell us the proportion of values which are greater than or less than \\(N\bar{x}\\).

If only a small proportion of values from the CPC distribution \\(\mathsf{Poisson}(5 \cdot 100)\\) are greater than \\(5 \cdot 102.6\\), this would indicate that it is unlikely to have obtained \\(\bar{x}=102.6\\) by chance and thus maybe there's something wrong with the CPC targeting.

### In Python

```python
>>> from scipy.stats import poisson
>>>
>>> N = 5
>>> xbar = 102.6
>>> mu = 100
>>> p = poisson.cdf(N * xbar, N * mu)
0.7285633495908114
>>>
```

That shows that 72.9% of \\(N=5\\) samples from a distribution with \\(\mu=100\\) would have an average value of less than \\(\bar{x}=102.6\\). Conversely, 27.1% of samples would have a greater value. So our samples aren't very unlikely given a CPC of 100.

As you increase the number of samples you'd expect \\(\bar{x}=102.6\\) to become more and more unlikely.

```python
>>> for n in [10, 20, 30, 40, 50]:
...     print(n, poisson.cdf(n * xbar, n * mu))
...
10 0.7994310510662929
20 0.8795150478303122
30 0.9236492476438214
40 0.9503028216143891
50 0.9671124727069668
>>>
```

When \\(N=50\\), 96.7% of samples from the distribution would have a lower average value (conversely, only 3.3% of samples would have a greater value). We're much less likely to obtain \\(\bar{x}=102.6\\) by chance, and I might suggest looking into how CPCs are being targeted.
