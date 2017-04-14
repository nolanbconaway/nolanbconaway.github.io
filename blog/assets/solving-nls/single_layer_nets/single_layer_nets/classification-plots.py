import numpy as np
import matplotlib.pyplot as plt

    
def plotclasses(h, A, B, fontsize = 12):
    font_opts = dict(ha = 'center', va = 'center', 
        fontsize = 25, family="courier new")

    for j in range(A.shape[0]):
        h.text(A[j,0], A[j,1], 'A', color = [0.5, 0.0, 0.0],  **font_opts)
    for j in range(B.shape[0]):
        h.text(B[j,0], B[j,1], 'B', color = [0.0, 0.0, 0.5], **font_opts)
    h.set_xticks([0,1])
    h.set_yticks([0,1])
    h.axis([-0.2, 1.2, -0.2, 1.2])
    h.set_xlabel('$D_1$', fontsize = fontsize)
    h.set_ylabel('$D_2$', fontsize = fontsize)


fh, ax = plt.subplots(1,2, figsize = (6,3))


h = ax[0]
A = np.array([[0,0],[1,1]])
B = np.array([[0,1],[1,0]])
plotclasses(h, A, B)
h.set_title('Nonlinearly Separable (NLS)', fontsize = 12)

h = ax[1]
A = np.array([[0,0],[0,1]])
B = np.array([[1,0],[1,1]])
plotclasses(h, A, B)
h.set_title('Linearly Separable (LS)', fontsize = 12)


# path = 
fh.subplots_adjust(wspace=0.3)
fh.savefig('../images/ls-nls.png', bbox_inches = 'tight', pad_inches=0.1)


