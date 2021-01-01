---
title: Binoculars, a python package for Binomial confidence intervals.
date: 2021-01-01
category: blog
slug: binoculars
keywords: python, statistics, binomial, confidence
---

I recently published a package ([::package:: click](https://pypi.org/project/binoculars/)) called "binoculars", and all it does is calculate confidence intervals for binomial proportions. You can `pip install binoculars` or contribute via [GitHub](https://github.com/nolanbconaway/binoculars), etc. 

Usage is pretty simple:


```python
from binoculars import binomial_confidence

N, p = 100, 0.2

binomial_confidence(p, N, method='jeffrey') # (0.1307892803998113, 0.28628125447599173)
binomial_confidence(p, N, method='normal')  # (0.12160000000000001, 0.2784)
binomial_confidence(p, N, method='wilson')  # (0.1333659225590988, 0.28883096192650237)
```

Et-cetra.

::black_question_mark_ornament::::black_question_mark_ornament::::black_question_mark_ornament:: But _why the heck did I write a whole package to calculate confidence intervals for binomial proportions?_

## Reason 1: Binomial certainty comes up constantly.

Lots of statistics problems come around to the issue of certainty in the estimation of a binomial proportion. We all have data in which there are some \\(N\\) observations, out of which some \\(k\\) successfully do something, and so you want to understand the success rate \\(\hat{p}= k \div N\\). In the simplest case, you have some reference \\(p\\) value and you want to know if your \\(\hat{p}\\) is very different from that. Let's be concrete with some examples:

- You've got an ecommerce site and you want to determine if the conversion rate, \\(\text{purchases} \div \text{visits}\\), this month is different from last year.
- You want to know if the employment rate of a subpopulation, \\(\text{employed} \div \text{people}\\), is different from the national average.

This comes up entirely too often in my work and it probably does in yours. It _ought to be_ super easy to calculate a confidence interval on \\(\text{Binomial}(p, N )\\), where \\(p\\) is set to your reference proportion and \\(N\\) is the number of observations in your sample. Then you check if your \\(\hat{p}\\) is within the confidence interval and report those numbers. But it is _not_ that.

## Reason 2: Lots of people get this wrong.

A casual google search for "binomial confidence interval" will invariably lead you to this [_outstanding wikipedia page_](https://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval). I have returned to this page more times than I can count.

Most people end up implementing the **"Normal Approximation"** which is super easy and super terrible.

$$
p \pm z \sqrt{\frac{p (1 - p)}{N}}
$$

That math is not a lot, so you can do one-liners in python and SQL. Also, it is _symmetrical_, which means you write clean code like:

```py
ci = 1.96 * np.sqrt((p * (1 - p)) / N)
lower, upper = p - ci, p + ci
```

But the _symmetry_ is the problem! By way of demonstrating the terribleness here, I calculated ([::notebook:: click](https://deepnote.com/project/e17fa473-51c6-45aa-8de0-980be7d2dc5f)) the lower bound of 95% confidence with the Normal approximation as a function of \\(N\\) with a static \\(\hat{p}\\) of 0.01, 0.05, and 0.1:

<object type="image/svg+xml" data="{attach}Normal.svg"></object>

I took the liberty of annotating exactly where it is terrible. You can see that in _many real world cases_ the Normal approximation produces a lower bound < 0. We'd also see upper bounds > 1 if we had looked at \\(\hat{p} = 0.99, 0.95, 0.9\\), etc, because of the _symmetry_.

That's troubling not only because it should be impossible, but also because it suggests an **underestimation** of the uncertainty at the upper bound. Using the normal approximation in these cases might lead you to a fully incorrect conclusion ::grimacing_face::. 

I don't know about y'all, but I commonly deal with Binomials at \\(N<100\\) and \\(\hat{p}<0.1\\), so this is super concerning for me.

## Back to Binoculars...

We have a situation in which the easiest method for computing Binomial uncertainty is both the most popular and is patently _wrong_ in many common cases. It _ought to be_ just as easy to choose a more accurate method, and with Binoculars, it is!

So, what method should _you_ use?

1. Do **not** use the normal approximation if you have any other option.

2. If you are using Python, you have other options! (thanks to Binoculars ::grinning_face::). I like Jeffrey's interval because I am partial to Bayes but the Wilson interval is also very good.


### In SQL?

Binoculars won't help if you're doing this in SQL. But I often find myself needing a quick confidence interval for a dashboard, etc. If this sounds like you, the Wilson interval is your jam. Jeffrey's interval involves a lot of Beta distribution math which gets _narsty_. 

The Wilson interval isn't exactly _pretty_, but you can probably implement it as a user-defined-function on your database without a lot of hassle. 

If you're using DBT, you can also implement it as a macro!

```
{%- macro wilson_interval(col_p, col_n, tail, z=1.96) -%}

{%- if tail == 'lower' -%}
 (
   {{col_p}} + {{z}} * {{z}} / (2 * {{col_n}}) 
   - {{z}} * sqrt(({{col_p}} * (1 - {{col_p}}) + {{z}} * {{z}} / (4 * {{col_n}})) / {{col_n}})
  ) / (1 + {{z}} * {{z}} / {{col_n}})

{%- elif tail == 'upper' -%}
 (
   {{col_p}} + {{z}} * {{z}} / (2 * {{col_n}}) 
   + {{z}} * sqrt(({{col_p}} * (1 - {{col_p}}) + {{z}} * {{z}} / (4 * {{col_n}})) / {{col_n}})
  ) / (1 + {{z}} * {{z}} / {{col_n}})

{%- endif -%}
{%- endmacro -%}
```

Which gets called like:

```
with t as ( select 500 as n, 0.2 as p )
select 
  t.*,
  {{ wilson_interval('p', 'n', 'lower') }} as ci_lower,
  {{ wilson_interval('p', 'n', 'upper') }} as ci_upper
from t
```

That sort of math is is exactly what you'd _want_ to hide in a macro, anyway ::winking_face::.

### ::folded_hands:: Please contribute!

Binoculars currently focuses on estimating uncertainty given \\(\text{Binomial}(\hat{p}, N)\\). It's missing several well-defined methods on that [awesome wiki page](https://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval), and there are a lot of similar questions to be asked! Such as:

- *Uncertainty about the odds-ratio between two binomial samples?*

$$
\text{odds} = \frac{k_1}{N_1} \div \frac{k_2}{N_2}
$$

- *Uncertainty about the difference between two binomial samples?*

$$
\text{diff} = \frac{k_1}{N_1} - \frac{k_2}{N_2}
$$

I've found some [Normal Approximation-looking math](https://www.ncbi.nlm.nih.gov/books/NBK431098/) for this stuff, and it'd be great to work out a function to make this available generally!

Binoculars is open sourced on [GitHub](https://github.com/nolanbconaway/binoculars), submit issues with your complaints or PRs with your solutions ::kissing_face::.