import random
import numpy as np
from numpy.random import rand
import matplotlib

import matplotlib.pyplot as plt
def Graph(state, T):
    S = state.shape[1]  # Takes the size of the matrix
    print("Plotting!")
    for i in range(S):
        for j in range(S):
            if state[i][j] == 1:  # Graphs a red + if the matrix entry is positive
                plt.scatter(j, S - 1 - i, c='r', marker=',', )#s=(150,))
            elif state[i][j] == -1:  # Graphs a blue minus is the matrix is negative
                plt.scatter(j, S - 1 - i, c='b', marker=',', )#s=(150,))
    plt.title("Sample, T=%d" % (T) )
    print("Done!")
    plt.show()