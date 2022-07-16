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
        print(f"{f.__name__} took: {te-ts:2.4f}s")
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

    print(f"Running: {size}")
    result_nolan = softmax_nolan(arr)
    result_scipy = softmax_scipy(arr)
    print()

    # check for differences
    max_diff = np.max(np.abs(result_scipy - result_nolan))
    assert max_diff < 1e-10, max_diff
