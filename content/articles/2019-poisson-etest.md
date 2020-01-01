---
title: A python implementation of the Poisson exact test (e-test).
date: 2019-03-24
category: blog
---

At work we are doing tests on different paid search optimization tools. We wanted to see if a new tool offered improvements over what we had been using. In reality we are comparing the two on all sorts of metrics, but as an example we can focus on comparisons with respect to the cost paid per click, _CPC_, measured in USD.

Cost per click is an example of a Poisson distributed variable. We started measuring the CPC during some control period using the current tools, then switched to the new tool in a test period.

Those data might look something like:

|        | Control | Test |
|--------|---------|------|
| CPC    | $10     | $9   |
| Cost   | $400    | $450 |
| Clicks | 40      | 50   |

The question is: How likely are we to obtain those data under the assumption that there was no change in overall CPC?

That question specifies the null hypothesis: the two periods of data were generated from the same distribution. Under the alternative hypothesis the test period data might have a greater or lesser CPC.

The [Poisson Exact Test](http://www.ucs.louisiana.edu/~kxk4695/JSPI-04.pdf) (E-Test) is a hypothesis test for answering this kind of question. In R, you can use [`poisson.test`](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/poisson.test.html), which implements the similar but inexact Poisson C-Test. But in Python, no such implementation exists.

I dug up the original [Fortran code](http://www.ucs.louisiana.edu/~kxk4695/statcalc/pois2pval.for) posted to the academic website belonging to one of the authors of the test. I edited it very minimally so that it could be wrapped by the Numpy [Fortran to Python interface generator](https://docs.scipy.org/doc/numpy/f2py/index.html). Then I packaged it and posted on pypi, so you can use it too!

- [Github](https://github.com/nolanbconaway/poisson-etest)
- [PyPi](https://pypi.org/project/poisson-etest/0.0/)
- [Travis CI](https://travis-ci.org/nolanbconaway/poisson-etest)

## Usage

Just plug in the numbers to get your answer!

```python
from poisson_etest import poisson_etest

control_cost = 400
control_clicks = 40
test_cost = 450
test_clicks = 50

p = poisson_etest(control_cost, test_cost, control_clicks, test_clicks)

print(p)
# 0.12732580695256054
```

We believe more in the estimate of each period's CPC if we have more clicks. That is, I wouldn't say we know much about the CPC of the Test period after only obtaining a single click. Conversely, we have a strong estimate of the CPC after many hundreds.

This test is useful in that it accounts for the sample size accordingly. Keeping the CPC's the same, lets check on the results if we had over 100 clicks in each period:

```python
control_clicks = 105
test_clicks = 100
control_cost = control_clicks * 10
test_cost = test_clicks * 9
```

Now, the probability that the two were generated from the same distribution is much smaller:

```python
p = poisson_etest(control_cost, test_cost, control_clicks, test_clicks)

print(p)
# 0.0034409891789582165
```
