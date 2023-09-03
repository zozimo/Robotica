import numpy as np
def matrizAntisimetrica3x3(v):
    As = np.array([[0,-v[2],v[1]],
                   [v[2], 0 , -v[0]],
                   [-v[1], v[0], 0]])
    return As
    