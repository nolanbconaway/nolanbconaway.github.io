---
title: An update on the softmax function for numpy.
date: 2019-01-05
category: blog
slug: softmax-numpy-update
keywords: numpy, softmax, python, scipy
---

As of early 2019, my post on a [softmax function for numpy](/blog/2017/softmax-numpy) accounts for 83% of traffic to my website (~16k views in 2018). I recently found that, as of version 1.2.0, scipy has included an implementation of the softmax in its special functions.

Some info on the change:

 - [SciPy docs](https://docs.scipy.org/doc/scipy/reference/generated/scipy.special.softmax.html#scipy.special.softmax).
- [Merged pull request](https://github.com/scipy/scipy/pull/8872).
- [Feeding my ego](https://github.com/scipy/scipy/pull/8556/commits/02d0ac2dea6bd2ad11ddf6c6022b3bae881c961a#diff-86dbed1918e224062ad4239fe5d14041R188).

Originally, the proposed function looked very much like the one I had posted, but then [a very smart person](https://github.com/pv) realized that you could use existing tooling around [scipy.special.logsumexp](https://docs.scipy.org/doc/scipy/reference/generated/scipy.special.logsumexp.html#scipy.special.logsumexp) to make things much cleaner.

So now the function is [a freaking one-liner](https://github.com/scipy/scipy/blob/master/scipy/special/_logsumexp.py#L215).

```python
def softmax(x, axis=None):
     return np.exp(x - logsumexp(x, axis=axis, keepdims=True))
```

I 100% prefer importing a function from scipy over pasting a hand-written one. Especially given the beauty of that puppy. But the two functions are not totally swappable, there are a couple important changes in behavior:

1. **SciPy computes the softmax over _all_ array elements by default**. It will keep the shape but the _entire_ result will sum to 1. My old function computed the softmax over the first non-singleton dimension like in MATLAB.
2. **There is no `theta` multiplier**. In my function, a `theta` parameter was accepted to control determinism, but that was not implemented in the scipy function. No biggie, you'll just need to do `softmax(X*theta)` instead of `softmax(X, theta=theta)`.

## A quick performance comparison

I figured scipy had some magic stuff going on with `logsumexp`, and their function would be both more beautiful _and_ performant than mine.

But I ran a quick handful of tests just for kicks. First I wrote up a decorator to print function exec time to the console and wrapped my softmax and scipy softmax in it.

```python
from functools import wraps
import time
import numpy as np
import scipy.special


def timeit(f):
    """Decorator to print function exec time."""
    @wraps(f)
    def wrap(*args, **kw):
        ts = time.time()
        result = f(*args, **kw)
        te = time.time()
        print(f'{f.__name__} took: {te-ts:2.4f}s')
        return result
    return wrap


@timeit
def softmax_nolan(X, theta=1.0, axis=None):
    """My func without those pesky comments and docs."""
    y = np.atleast_2d(X)
    if axis is None:
        axis = next(j[0] for j in enumerate(y.shape) if j[1] > 1)
    y = y * float(theta)
    y = y - np.expand_dims(np.max(y, axis=axis), axis)
    y = np.exp(y)
    ax_sum = np.expand_dims(np.sum(y, axis=axis), axis)
    p = y / ax_sum
    if len(X.shape) == 1:
        p = p.flatten()
    return p


@timeit
def softmax_scipy(X, theta=1.0, axis=None):
    """Scipy softmax with the axis inference and theta included."""
    y = np.atleast_2d(X)
    if axis is None:
        axis = next(j[0] for j in enumerate(y.shape) if j[1] > 1)
    return scipy.special.softmax(X * theta, axis=0)
```


I ran each function on 2D arrays of varying sizes and checked for differences in the results.

```python
sizes = [
    (10000,),
    (1000, 1000),
    (10000, 100),
    (100, 10000),
    (100000, 100),
    (100, 100000),
    (10, 1000000),
    (10, 10000000),
]

for size in sizes:
    arr = np.random.normal(size=size)

    print(f'Running: {size}')
    result_nolan = softmax_nolan(arr)
    result_scipy = softmax_scipy(arr)
    print()

    # check for differences
    max_diff = np.max(np.abs(result_scipy - result_nolan))
    assert max_diff < 1e-10, max_diff
```

[Here is the full script]({attach}numpy-softmax-update/test.py), in case you want to toy around with it.

### Results

My function was ... faster?

```txt
Running: (10000,)
softmax_nolan took: 0.0004s
softmax_scipy took: 0.0162s

Running: (1000, 1000)
softmax_nolan took: 0.0210s
softmax_scipy took: 0.0259s

Running: (10000, 100)
softmax_nolan took: 0.0132s
softmax_scipy took: 0.0233s

Running: (100, 10000)
softmax_nolan took: 0.0141s
softmax_scipy took: 0.0198s

Running: (100000, 100)
softmax_nolan took: 0.2186s
softmax_scipy took: 0.2869s

Running: (100, 100000)
softmax_nolan took: 0.1633s
softmax_scipy took: 0.2740s

Running: (10, 1000000)
softmax_nolan took: 0.1962s
softmax_scipy took: 0.2792s

Running: (10, 10000000)
softmax_nolan took: 3.3774s
softmax_scipy took: 4.4439s
```

My function runs an exponential one time, whereas scipy runs the array through `logsumexp` and then exponentializes again. So maybe that's why we get these results? I don't really know what `logsumexp` does under the hood.

Anyway, I still prefer scipy softmax to reduce the dependency on a handwritten function.

Some notes:

- I get similar results every time I ran the script.
- I use a cruddy pip install on python 3.7.1. I don't know what would happen if those speedy conda optimizations were in play.
