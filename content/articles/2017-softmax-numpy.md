---
title: A softmax function for numpy.
date: 2017-03-15
category: blog
slug: softmax-numpy
keywords: numpy, softmax, python
---

> #### Update (Jan 2019): SciPy (1.2.0) now includes the softmax as a special function. It's really slick. Use it. [Here are some notes](/blog/2019/softmax-numpy-update).

---

I use the [softmax](https://en.wikipedia.org/wiki/Softmax_function) function _constantly_. It's handy anytime I need to model choice among a set of mutually exclusive options. In the canonical example, you have some metric of evidence, \\(X = \\{ X_1, X_2, ... X_n\\} \\), that an item belongs to each of \\(N\\) classes: \\( C = \\{C_1, C_2, ... C_n\\} \\). \\(X\\) can only belong to one class, and larger values indicate more evidence for class membership. So you need to convert the relative amounts of evidence into probabilities of membership within each of the classes.

That's what the softmax function is for. Below I have written the mathematics, but idea is simple: you divide each element of \\(X\\) by the sum of all the elements:

$$
p(C_n) =
\frac{ \exp\{\theta \cdot X_n\} }
{ \sum_{i=1}^{N}{\exp \{\theta \cdot X_i\} } }
$$

The use of exponentials serves to normalize \\(X\\), and it also allows the function to be parameterized. In the above equation, I threw in a free parameter, \\(\theta\\) (\\(\theta \geq 0\\)), that broadly controls _determinism_. Within the exponentiation, \\(\theta\\) makes larger values of  \\(X\\) larger-er, so if you set \\(\theta\\) to a large value, the softmax really squashes things: Elements of \\(X\\) with anything but the largest values will have a probability very close to zero. When \\(\theta = 1\\), it's as if the parameter was never there.

I use this sort of function all the time to simulate how people make decisions based on evidence. But unfortunately, there is no built in `numpy` function to compute the softmax. For years I have been writing code like this:

```python
import numpy as np
X = np.array([1.1, 5.0, 2.8, 7.3])  # evidence for each choice
theta = 2.0                         # determinism parameter

ps = np.exp(X * theta)
ps /= np.sum(ps)
```

Of course, usually `X` and `theta` come from somewhere else. This works well if you are only simulating one decision: the softmax requires literally two lines of code and its easily readable. But things get thornier if you want to simulate many choices. For example, what if `X` is a matrix where rows correspond to the different choices, and the columns correspond to the options?

In the 2D case, you can either run a loop through the rows of `X` or use `numpy` matrix [broadcasting](https://docs.scipy.org/doc/numpy/user/basics.broadcasting.html). Here's the loop solution:

```python
X = np.array([
    [1.1, 5.0, 2.2, 7.3],
    [6.5, 3.2, 8.8, 5.3],
    [2.7, 5.1, 9.6, 7.4],
    ])  

# looping through rows of X
ps = np.empty(X.shape)
for i in range(X.shape[0]):
    ps[i,:]  = np.exp(X[i,:] * theta)
    ps[i,:] /= np.sum(ps[i,:])
```

That's not _terrible_, but you can imagine that it's annoying to write one of those _every time_ you need to softmax. Likewise, you'd have to change up the code if you wanted to softmax over columns rather than rows. Or for that matter, what if `X` was a 3D-array, and you wanted to compute softmax over the third dimension?

At this point it feels more useful to write a generalized softmax function.

## My softmax function

After years of copying one-off softmax code between scripts, I decided to make things a little [dry](https://en.wikipedia.org/wiki/Don't_repeat_yourself)-er: I sat down and wrote a darn softmax function. The goal was to support \\(X\\) of any dimensionality, and to allow the user to softmax over an arbitrary axis. Here's the function:

```python
def softmax(X, theta = 1.0, axis = None):
    """
    Compute the softmax of each element along an axis of X.

    Parameters
    ----------
    X: ND-Array. Probably should be floats.
    theta (optional): float parameter, used as a multiplier
        prior to exponentiation. Default = 1.0
    axis (optional): axis to compute values along. Default is the
        first non-singleton axis.

    Returns an array the same size as X. The result will sum to 1
    along the specified axis.
    """

    # make X at least 2d
    y = np.atleast_2d(X)

    # find axis
    if axis is None:
        axis = next(j[0] for j in enumerate(y.shape) if j[1] > 1)

    # multiply y against the theta parameter,
    y = y * float(theta)

    # subtract the max for numerical stability
    y = y - np.expand_dims(np.max(y, axis = axis), axis)

    # exponentiate y
    y = np.exp(y)

    # take the sum along the specified axis
    ax_sum = np.expand_dims(np.sum(y, axis = axis), axis)

    # finally: divide elementwise
    p = y / ax_sum

    # flatten if X was 1D
    if len(X.shape) == 1: p = p.flatten()

    return p
```


## What's up with that max subtraction?

The only aspect of this function that does not directly correspond to something in the softmax equation is the subtraction of the maximum from each of the elements of `X`. This is done for stability reasons: when you exponentiate even large-ish numbers, the result can be quite large. `numpy` will return `inf` when you exponentiate values over 710 or so. So if values of `X` aren't limited to some fixed range (e.g., \\([0...1]\\)), or even if you let `theta` take on any value, you run the distinct possibility of hitting the `inf` ceiling.

But! If you subtract the maximum value from each element, the largest pre-exponential value will be zero, thus avoiding numerical instability.

So that solves the numerical stability problem, but is it _mathematically_ correct? To clear this up, let's write out the softmax equation with the subtraction terms in there. To keep it simple, I've also removed the \\(\theta\\) parameter:

$$
p(C_n) =
\frac{ \exp\{ X_n - \max(X) \} }
{ \sum_{i=1}^{N}{\exp \{ X_i - \max(X) \} } }
$$

Subtracting within an exponent is the same as dividing between exponents ([remember](http://www.rapidtables.com/math/number/exponent.htm)? \\(e^{a-b} = e^a / e^b\\)), so:

$$
\frac{ \exp\{ X_n - \max(X) \}  }
{ \sum_{i=1}^{N}{\exp \{ X_i - \max(X) \} } }
= \frac{ \exp \{ X_n  \} \div \exp \{ \max(X) \} }
{ \sum_{i=1}^{N}{\exp \{ X_i \} \div \exp \{ \max(X) \} } }
$$

Then you just cancel out the maximum terms, and you're left with the original equation:

$$
\frac{ \exp \{ X_n  \} \div \exp \{ \max(X) \} }
{ \sum_{i=1}^{N}{\exp \{ X_i \} \div \exp \{ \max(X) \} } } =
\frac{ \exp\{ X_n \} }
{ \sum_{i=1}^{N}{\exp \{ X_i \} } }
$$

## Summary

The function works beautifully and has a nice safeguard against overflow in the exponential. And, if you're like me, including it will prevent you from writing a handful of one-off implementations of the softmax. I'll round this out with a few examples of its usage:


### 2D Usage
```python
X = np.array([
    [1.1, 5.0, 2.2, 7.3],
    [6.5, 3.2, 8.8, 5.3],
    [2.7, 5.1, 9.6, 7.4],
    ])

# softmax over rows
softmax(X, theta = 0.5, axis = 0)
>>> array([[ 0.055,  0.407,  0.015,  0.413],
           [ 0.822,  0.165,  0.395,  0.152],
           [ 0.123,  0.428,  0.59 ,  0.435]])

# softmax over columns
softmax(X, theta = 0.5, axis = 1)
>>> array([[ 0.031,  0.22 ,  0.054,  0.695],
           [ 0.204,  0.039,  0.645,  0.112],
           [ 0.022,  0.072,  0.68 ,  0.226]])

# softmax over columns, and squash it!
softmax(X, theta = 500.0, axis = 1)
>>> array([[ 0.,  0.,  0.,  1.],
           [ 0.,  0.,  1.,  0.],
           [ 0.,  0.,  1.,  0.]])
```

### 3D (and beyond!)

```python
X = np.random.uniform(size = (3,3,2))
>>> X
array([[[ 0.844,  0.237],
        [ 0.364,  0.768],
        [ 0.811,  0.959]],

       [[ 0.511,  0.06 ],
        [ 0.594,  0.029],
        [ 0.963,  0.292]],

       [[ 0.463,  0.869],
        [ 0.704,  0.786],
        [ 0.173,  0.89 ]]])


softmax(X, theta = 0.5, axis = 2)
>>> array([[[ 0.575,  0.425],
            [ 0.45 ,  0.55 ],
            [ 0.482,  0.518]],

           [[ 0.556,  0.444],
            [ 0.57 ,  0.43 ],
            [ 0.583,  0.417]],

           [[ 0.449,  0.551],
            [ 0.49 ,  0.51 ],
            [ 0.411,  0.589]]])
```
