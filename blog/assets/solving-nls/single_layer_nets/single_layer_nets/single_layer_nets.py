import numpy as np
import abc

#  ----------------------------------------------------------------
#  Just some toy classes to see what kinds of weights are learned.
#  ----------------------------------------------------------------

def addbiasunit(X):
    """
    Add a column of ones representing the bias unit
    """
    column = np.ones((X.shape[0], 1))
    return np.concatenate([column, X], axis = 1)

def sigmoid(x):
  return 1.0 / (1.0 + np.exp(-x))

def printattr(obj):
    """
    print slices of a 3d matrix
    """
    if obj.ndim == 2: 
        print(obj)
        return 

    for i in range(obj.shape[2]):
        print('Category ' + str(i))
        print(obj[:,:,i])
        if i < obj.shape[2]-1: print('')


class single_layer_net(object):
    __metaclass__ = abc.ABCMeta
    
    def __init__(self, categories, 
            learningrate = 0.1,
            weightrange = 0.0,
            outputrule = 'linear'
            ):
        
        if outputrule not in ['linear','sigmoid']:
            raise Exception('Invalid output rule! Must be linear or sigmoid.')

        # store parameters
        self.learningrate = float(learningrate)
        self.weightrange  = float(weightrange)
        self.outputrule   = outputrule

        # describe the categories
        self.categories = [np.atleast_2d(i) for i in categories]
        self.ncategories = len(self.categories)

        # represent exemplars as a single nD array.
        self.exemplars = np.concatenate(self.categories, axis = 0)
        self.nexemplars = self.exemplars.shape[0]
        self.nfeatures = self.exemplars.shape[1]

        # set up inputs with bias unit
        self.inputs = addbiasunit(self.exemplars)

        # assignments stores class assignments for each row
        self.assignments = []
        for i in range(self.ncategories):
            self.assignments += [i] * len(self.categories[i])
        self.assignments = np.array(self.assignments)

        # farm out to concrete class functions
        self.init_weights()
        self.set_targets()

    def train(self, nblocks):
        for i in range(nblocks):
            self.propagate()
            self.update_wts()
        return self

    @abc.abstractmethod
    def set_targets(self):
        pass

    @abc.abstractmethod
    def init_weights(self):
        pass

    @abc.abstractmethod
    def propagate(self):
        pass

    @abc.abstractmethod
    def update_wts(self):
        pass

class autoassociator(single_layer_net):
    """ Implementation of the Divergent Autoassociator. """
    
    model = 'Autoassociator'

    def set_targets(self):
        self.targets = self.exemplars[:,:,None]
    
    def init_weights(self):        
        self.wts = np.random.uniform(-1.0, 1.0,
            size = (self.nfeatures + 1, self.nfeatures, self.ncategories)
        ) * self.weightrange
        

    def propagate(self):
        output = np.zeros((self.nexemplars, self.nfeatures, self.ncategories))
        for i in range(self.ncategories):
            output[:,:,i] = np.dot(self.inputs, self.wts[:,:,i])
        if self.outputrule == 'sigmoid': output = sigmoid(output)
        self.output = output
        self.error = self.targets - self.output      
    
    def update_wts(self):
        for i in range(self.ncategories):
            idx = self.assignments == i
            delta = np.dot(self.inputs[idx,:].T, self.error[idx,:, i])
            self.wts[:,:,i] += self.learningrate * delta
        
        
class perceptron(single_layer_net):
    """ Implementation of the perceptron classifier. """
    
    model = 'Perceptron'

    def set_targets(self):
        self.targets = np.zeros((self.nexemplars,self.ncategories))
        for i in range(self.nexemplars):
            self.targets[i, self.assignments[i]] = 1.0
        
    def init_weights(self):
        self.wts = np.random.uniform(-1.0, 1.0,
            size = (self.nfeatures + 1, self.ncategories)
        ) * self.weightrange
    
    def propagate(self):
        output = np.dot(self.inputs, self.wts)
        if self.outputrule == 'sigmoid': output = sigmoid(output)
        self.output = output
        self.error = self.targets - self.output

    def update_wts(self):
        delta = np.dot(self.inputs.T, self.error)
        self.wts += self.learningrate * delta
        
         
