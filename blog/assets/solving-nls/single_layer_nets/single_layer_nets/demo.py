import numpy as np
np.set_printoptions(precision = 2)

# import network objects
from single_layer_nets import perceptron
from single_layer_nets import autoassociator

# function to make 3d array printing prettier
from single_layer_nets import printattr 

# define classes
NLS = dict(	A = np.array([[0,0],[1,1]]),
			B = np.array([[0,1],[1,0]]),
			description = 'NLS')

LS = dict( 	A = np.array([[0,0],[0,1]]),
			B = np.array([[1,0],[1,1]]),
			description = 'LS')

for categories in [LS, NLS]:
	print(' ----------- ' + categories['description'])
	print('Inputs:')
	print np.concatenate([categories['A'], categories['B']])

	for model in [perceptron, autoassociator]:
		
		# initialize network model
		net = model([categories['A'], categories['B']])
		net.train(1000)

		print('')
		print(net.model + ' output:')
		printattr(np.round(net.output, 2))

		print('')
		print(net.model + ' weights:')
		printattr(np.round(net.wts, 2))

