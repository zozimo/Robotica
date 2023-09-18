import numpy as np
import sympy as sp
def pcd_SCARA(q,a_aux):
    """
    Esta funcion calcula el problema cinematico directo del Robot SCARA

    Parameters
    ---------- 
    q: array_like
        Valores de las variables articulares
    a: array_like
        Parametros constructivos del robot
    Returns
    -------
    POSE : matrix
        Devuelve la matriz de rototraslacion A4_0
      
    See Also
    --------
    
    Examples
    --------
    
    """
    # Los vectores en python arrancan en cero, en matlab arrancan en 1
    # q12 =  q[0] + q[1]
    # q124 =  q12 + q[3] 
    
    d = sp.Matrix([0,0,q[2],0])
    a = sp.Matrix([a_aux[0],a_aux[1],0,0])
    POSE = sp.eye(4,4)
    POSE_aux = []
    for i in range(len(q)):
        POSE_aux.append( sp.Matrix([[sp.cos(q[i]), -sp.sin(q[i])*sp.cos(0), sp.sin(q[i])*sp.sin(0), a[i]*sp.cos(q[i])],
                            [sp.sin(q[i]), sp.cos(q[i])*sp.cos(0), -sp.cos(q[i])*sp.sin(0),a[i]*sp.sin(q[i])],
                            [0, sp.sin(0), sp.cos(0),d[i]],
                            [0, 0, 0, 1]])
                        )
        POSE = POSE * POSE_aux[i] 
    
    
    
    # POSE = sp.Matrix([  [sp.cos(q124), -sp.sin(q124),0, a[0]*sp.cos(q[0])+a[1]*sp.cos(q12) ], 
    #                     [sp.sin(q124), sp.cos(q124), 0, a[0]*sp.sin(q[0])+a[1]*sp.sin(q12) ],
    #                     [0,0,1,q[2]],
    #                     [0,0,0,1]])
    # Calculamos el vector de configuracion
    conf = sp.sign(q[1])
    # La configuracion no puede ser nula
    if conf == 0:
        conf = 1
    return POSE, conf, POSE_aux
    
    

    
def pinv_SCARA(POSE,conf,a):
    """
    Esta funcion calcula el problema cinematico directo del Robot SCARA

    Parameters
    ---------- 
    POSE: array_like
        Matriz de roto traslacion A_0_4
    conf: array_like
        Dato para definir codo positivo o negativo
    Returns
    -------
    q : vector
        Devuelve el vector de variables articulares o variables joint
      
    See Also
    --------
    
    Examples
    --------
    
    """
    # Primero calculo q2
    q = sp.zeros(1,4)
    px = POSE[0,3] 
    py = POSE[1,3] 
    # Validamos que el punto sea alcanzable
    if (px**2 + py**2) > (a[0] + a[1])**2 and (px**2 + py**2) < (a[0] - a[1])**2 and (px**2 + py**2)>0:
        print("El punto no es alcanzable")
        return q
    
    c2 = (px**2 + py**2 - (a[0]**2 + a[1]**2))/(2*a[0]*a[1])
    s2 = conf* sp.sqrt(1-c2**2)
    # q2
    q[1] = sp.atan2(s2,c2)
    
    # Primero calculo q1
    
    s1 = (a[1]*(py*c2-px*s2)+a[0]*py)/(px**2 + py**2)
    c1 = (a[1]*(py*s2+px*c2)+a[0]*px)/(px**2 + py**2)
    # q1
    q[0] = sp.atan2(s1,c1)
        
    # q3
    q[2] = POSE[2,3]
    # q4
    c124 = POSE[0,0]
    s124 = POSE[1,0]
    q[3] = sp.atan2(s124,c124) - q[0] - q[1]
        
    return q


def pcd_IRB140(d,q,alpha,a):
    """
    Esta funcion calcula el problema cinematico directo del Robot IRB140

    Parameters
    ---------- 
    d: sp.Matrix()
        Longitud de articulacion
    q: sp.Matrix()
        Valores de las variables articulares
    alpha: sp.Matrix()
        Angulo de torsión del eslabón
    a: sp.Matrix()
        Longitud de los eslabones
    Returns
    -------
    POSE : sp.Matrix()
        Devuelve la matriz de rototraslacion A_0_6
    conf: sp.Matrix()
        Devuelve un vector de configuracion, brazo +-, codo+-, muñeca +-
    See Also 
    --------
    
    Examples
    --------
    
    """
    POSE = sp.eye(4,4)
    POSE_aux = []
    # Calculo de la matriz A_0_6
    for i in range(len(q)):
        POSE_aux.append( sp.Matrix([[sp.cos(q[i]), -sp.sin(q[i])*sp.cos(alpha[i]), sp.sin(q[i])*sp.sin(alpha[i]), a[i]*sp.cos(q[i])],
                          [sp.sin(q[i]), sp.cos(q[i])*sp.cos(alpha[i]), -sp.cos(q[i])*sp.sin(alpha[i]),a[i]*sp.sin(q[i])],
                          [0, sp.sin(alpha[i]), sp.cos(alpha[i]),d[i]],
                          [0, 0, 0, 1]])
                        )
        POSE = POSE * POSE_aux[i] 
        # print("matriz RotoTras",i+1 )
        # sp.pprint(POSE.evalf())
    # print("mi matriz",POSE)
    # Calculo el vector de configuracion
    conf = sp.zeros(1,3)
    # conf 1
    conf[0] = sp.sign(d[3]*sp.sin(q[1]+q[2]) + a[1]*sp.cos(q[1])+a[0])
    # conf 2
    conf[1] = sp.sign(sp.cos(q[2]))
    # conf 3
    conf[2] = sp.sign(q[4])
    # En caso de que algun elemento de conf sea nulo reemplazmos con un 1
    
    # Definir una función lambda para reemplazar ceros con unos
    reemplazar_ceros = lambda x: 1 if x == 0 else x

    # Aplicar la función a cada elemento de la matriz
    conf = conf.applyfunc(reemplazar_ceros)
     
    
    return POSE, conf , POSE_aux

def pinv_IRB140(POSE,conf,q1_actual,q4_actual,d,alpha,a):
    """
    Esta funcion calcula el problema cinematico inverso del Robot IRB140

    Parameters
    ---------- 
    POSE: sp.Matrix()
        Matriz de roto traslacion A_0_6
    conf: sp.Matrix()
        Dato para definir  brazo +-, codo+-, muñeca +-
    q1_actual: float
        Angulo de la base actual que se obtiene de la lectura del sensor que mide le angulo theta 1
    d: sp.Matrix()
        Longitud de articulacion
    alpha: sp.Matrix()
        Angulo de torsión del eslabón
    a: sp.Matrix()
        Longitud de los eslabones
    Returns
    -------
    q : vector
        Devuelve el vector de variables articulares o variables joint
      
    See Also
    --------
    
    Examples
    --------
    
    """
    # vector de variables articulares
    q = sp.zeros(1,6)
    
    px = POSE[0,3] 
    py = POSE[1,3] 
    pz = POSE[2,3] 
    # Primero resolvemos el problema de posicion de la muñeca q1,q2,q3
    # q1
    s1 = conf[0]*py
    c1 = conf[0]*px
    if px == 0 and py == 0:
        # De las infinitas soluciones para la indeterminacion me quedo con 1
        # Indeterminacion con el brazo girando para un sentido y la brida para el otro entonces el punto
        # no se mueve la POSE y tengo infinitas soluciones para q1 y q6
        q[0] = q1_actual
    else:
        q[0] = sp.atan2(s1,c1)
    
    # q3 codo
    
    s3 = ((px*sp.cos(q[0])+py*sp.sin(q[0])-a[0])**2 + pz**2 - (d[3]**2+a[1]**2))/(2*a[1]*d[3])
    # sp.pprint(s3.evalf())
    # Verficamos la condicion de punto alcanzable
    if sp.Abs(s3) > 1:
        print("ERROR Punto no alcanzable")
        return q
    
    c3 = conf[1]*sp.sqrt(1-s3**2)
    q[2] = sp.atan2(s3,c3)
    
    # q2
    s2 = ((px*sp.cos(q[0])+py*sp.sin(q[0])-a[0])*(d[3]*sp.cos(q[2])) - pz * (d[3]*sp.sin(q[2])+a[1]))/((d[3]*sp.cos(q[2]))**2+((d[3]*sp.sin(q[2])+a[1])**2))
    c2 = ((px*sp.cos(q[0])+py*sp.sin(q[0])-a[0])*(d[3]*sp.sin(q[2]) + a[1]) + pz * d[3]*sp.cos(q[2]))/((d[3]*sp.cos(q[2]))**2+((d[3]*sp.sin(q[2])+a[1])**2))
    q[1] = sp.atan2(s2,c2)
    
    # Ahora resolvemos el problema de la orientacion de la muñeca
    R_3_0 = sp.eye(3,3)
    for i in range(len(q[0:3])):
        A_i = sp.Matrix([   [sp.cos(q[i]), -sp.sin(q[i])*sp.cos(alpha[i]), sp.sin(q[i])*sp.sin(alpha[i])],
                            [sp.sin(q[i]), sp.cos(q[i])*sp.cos(alpha[i]), -sp.cos(q[i])*sp.sin(alpha[i])],
                            [0, sp.sin(alpha[i]), sp.cos(alpha[i])],
                            ])
                        
        R_3_0 = R_3_0 * A_i
        # print(POSE_aux[i] )
    
    R_6_0 = POSE[:3,:3]
    R_6_3 = R_3_0.T * R_6_0
    # q5 muñeca + o -
    c5 = R_6_3[2,2]
    s5 = conf[2]* sp.sqrt(1-c5**2)
    q[4] = sp.atan2(s5,c5)
    
    # q4
    if R_6_3[0,2] == 0 and R_6_3[1,2] == 0:
        # alineados los ejes 4 y 6
        # la muñeca y la brida giran en sentido opuestos, entonces no se mueve el punto 
        # no se mueve la POSE y tengo infinitas soluciones para q4 y q6
        q[3] = q4_actual
        q[5] = sp.atan2(R_6_3[1,0],R_6_3[0,0]) - q4_actual
    else:  
    # q4    
        c4 = conf[2] * R_6_3[0,2]
        s4 = conf[2] * R_6_3[1,2]
        q[3] = sp.atan2(s4,c4)
    # q6
        c6 = -conf[2] * R_6_3[2,0]
        s6 = conf[2] * R_6_3[2,1]
        q[5] = sp.atan2(s6,c6)
    return q