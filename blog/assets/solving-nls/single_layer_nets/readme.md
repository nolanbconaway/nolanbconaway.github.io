[Go Back](/blog/2017/solving-nls)

# Single Layer Network Python Modules ([`Download.zip`]({{page.url}}/single_layer_nets.zip))

These modules were built to explore the types of weight solutions learned for LS and NLS problems in different kinds of neural networks.

An example, to make this easy:

```python

import numpy as np
from single_layer_nets import perceptron
from single_layer_nets import autoassociator


LS = dict(  A = np.array([[0,0],[0,1]]),
            B = np.array([[1,0],[1,1]]))

#train the perceptron for 1000 blocks on the LS problem
net = perceptron([LS['A'], LS['B']]).train(1000)
print(net.wts)
print(net.output)

# now, train the autoassociator
net = autoassociator([LS['A'], LS['B']]).train(1000)
print(net.wts)
print(net.output)

```

I didn't exactly out-do myself here. These classes don't have methods for classification, and they don't tell you how accurate the model was at each training block. I basically just use them to study weight solutions!
