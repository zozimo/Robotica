import numpy as np
import sympy as symb


def matrizAntisimetrica3x3(v):
    """
    Esta funcion calcula una matriz antisimetrica a partir de un vector de 3x1

    Parameters
    ----------
    v : array_like
        v es un array de 3x1
    
    Returns
    -------
    As : ndarray
        As es una matriz de 3x3
      
    See Also
    --------
    
    Examples
    --------
    
    """
    As = np.array([[0,-v[2],v[1]],
                   [v[2], 0 , -v[0]],
                   [-v[1], v[0], 0]])
    return As

def rotZ(th):
    """
    Matriz que rota th sobre el eje z

    Parameters
    ----------
    th : array_like
        v es un array de 1x1
    
    Returns
    -------
    R : ndarray
        R es una matriz de 3x3 que rota theta en Z
      
    See Also
    --------
    
    Examples
    --------
    
    """
    R = symb.Matrix([[symb.cos(th),-symb.sin(th), 0], [symb.sin(th), symb.cos(th), 0 ], [0, 0, 1]])
    return R

def rotY(th):
    """
    Matriz que rota th sobre el eje y
    
    """
    R = symb.Matrix([[symb.cos(th), 0,symb.sin(th)],
                    [0, 1, 0 ],
                     [-symb.sin(th), 0, symb.cos(th)]])
    return R


def rotX(th):
    """
    Matriz que rota th sobre el eje y
    
    """
    R = symb.Matrix([[symb.cos(th), 0,symb.sin(th)],
                    [0, 1, 0 ],
                     [-symb.sin(th), 0, symb.cos(th)]])
    return R

def dirEuler(angulos):
    """
    Angulos Euler, problema directo
    
    """
    R = rotZ(angulos[0]) * rotY(angulos[1]) * rotZ(angulos[2])
    return R

def invEuler(R, conf):
    """
    A partir de una matriz de rotacion obtengo los angulos de Euler
    También debe ir un indice de configuracion, ese indice de configuracion en el signo de theta
    
    """
  
    if conf == 0:
        print("Conf no puede ser negativo\n")
    else:
        theta = symb.atan2(symb.sign(conf) * (1 - R[2, 2]**2),  R[2, 2] )
        phi = symb.atan2(symb.sign(conf) * R[1, 2],symb.sign(conf) * R[0, 2] ) 
        psi = symb.atan2(symb.sign(conf) * R[2, 1],- symb.sign(conf) * R[2, 0] ) 
        
        # Falta el problema de que pasa si los argumentos de atan2 son nulos
    angulos = symb.Matrix([phi, theta, psi] )
    return angulos

def rotk(th, k):
    
    """
    Rotación en un angulo theta sobre un eje k arbitrario
    
    """
    #Normalizo el vector
    k = k/k.norm() 
    R = symb.cos(th) * symb.eye(3) + (1-symb.cos(th)) * (k*k.T) + symb.sin(th) * symb.Matrix(matrizAntisimetrica3x3(k))
    Rr = R.col_insert(3, symb.Matrix.zeros(3, 1))
    relleno = symb.Matrix([[0, 0, 0, 1]])
    Rr = Rr.row_insert(3, relleno)
    return R, Rr

def trasl(p):
    """
    Devuelve una matriz de traslacion
    
    """
    Tr = symb.Matrix.eye(3,3)
    Tr = Tr.col_insert(3, p)
    relleno = symb.Matrix([[0, 0, 0, 1]])
    Tr = Tr.row_insert(3, relleno) 
    return Tr


def rotoTrasla(th, k, p):
    
    """
    Matriz de RotoTraslación
    
    """
        
    R, Rr = rotk(th, k)
    Tr = trasl(p)
    
    A = Rr * Tr
    return A, Rr, Tr, R

def qToR(Q):
    g = float(Q[0])
    qx = float(Q[1])
    qy = float(Q[2])
    qz = float(Q[3])
 
    # R = np.array([[g],
    #              [qx+qy],
    #              [qz]]
    #              )
    
    R = np.array([[2*qx*qx + 2*(g**2)-1, 2*qx*qy-2*g*qz, 2*qx*qz + 2*g*qy],
                 [2*qx*qy + 2*g*qz, 2*qy*qy+2*(g**2)-1, 2*qy*qz-2*g*qx],
                 [2*qx*qz - 2*g*qy, 2*qz*qy + 2*g*qx, 2*qz*qz+2*(g**2)-1]]
                 )
    
    return symb.Matrix(R)

# def rToQ(R):
#     nx =  float(R[0,0])
#     ny =  float(R[1,0])
#     nz =  float(R[2,0])
    
#     sx =  float(R[0,1])
#     sy =  float(R[1,1])
#     sz =  float(R[2,1])
    
#     ax =  float(R[0,2])
#     ay =  float(R[1,2])
#     az =  float(R[2,2])
    
#     g = 0.5 * np.sqrt(nx+sy+az+1)
#     qx = np.sign(sz-)
#     return Q

    