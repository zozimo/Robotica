# Hacemos todas las importaciones necesarias
# numpy para manejar array y algebra lineal
import numpy as np
import scipy as sc
# la funcionalidad específica de robótica está en el toolbox
import roboticstoolbox as rtb
# spatialmath tiene define los grupos de transformaciones especiales: rotación SO3 y eculideo SE3
import spatialmath as sm
import spatialmath.base.symbolic as sym
import matplotlib.pyplot as plt  



def curve_plot(dp,tg):
	plt.figure()
	plt.subplot(1,2,1)
	plt.plot(tg.t,tg.q*180/np.pi)
	plt.xlabel('t [s]')
	plt.ylabel(r'$q$ [°]')
	plt.legend([r'$q_1$',r'$q_2$'])
	plt.title('Evolución de las variables articulares')

	plt.subplot(1,2,2)
	trayectoria = dp.fkine(tg.q)
	X = trayectoria.t[:,0]
	Y = trayectoria.t[:,1]
	Z = trayectoria.t[:,2]

	plt.plot(X,Y)
	plt.xlabel('X [m]')
	plt.ylabel('Y [m]')
	plt.title('Trayectoria realizada')
	plt.axis([-0.4, 0.4, -0.4, 0.4])	


# Preparo el modelo de un doble péndulo
dp = rtb.DHRobot(
    [
        rtb.RevoluteDH(a=200e-3,m=1.5,
                r=np.array([-100, 0, 0]) * 1e-3,
                I=np.array([0,0,0,0,0,0,0,0,1e-3]),
                B=1, G=1,Jm=0.0001),                
        rtb.RevoluteDH(a=200e-3,m=1,
                r=np.array([-100, 0, 0]) * 1e-3,
                I=np.array([0,0,0,0,0,0,0,0,1e-3]),
                B=1, G=1,Jm=0.0001),                                
    ], 
    gravity = np.array([0, -9.8, 0]), # Ojo con el signo, la gravedad va hacia abajo con signo positivo
    name = "dp_TP5")

# Defino una carga puntual de 0.1Kg en el origen de la terna 2
#dp.payload(0.1, [0.0, 0.0, 0.0])

qr = np.array([-np.pi/2,0])
qz = np.zeros((2,))

print(dp)
print(dp.dynamics())


# Revisar los siguientes métodos de DHRobot 
# -perturb: produce una variación de los parámetros dinámicos y resulta útil para evaluar efecto de incertezas en el modelo
# dp.inertia(q) : obtiene la matriz M en la posición articular q
# dp.coriolis(q, qd) : obtiene la matriz C en la posición articular q con velocidad qd
# dp.gravload(q) : obtiene el vector G para la posición articular q
# tau = rne(q, qd, qdd, grav, fext) : dinámica inversa. Resulta muy útil al momento de calcular la ley Feedforward


# Simulación del sistema dinámico
# De la docu:
# fdyn(T, q0, torque=None, torque_args={}, qd0=None, solver='RK45', solver_args={}, dt=None, progress=False) 
# Integrate forward dynamics
#    Parameters
#            T (float) – integration time
#            q0 (array_like) – initial joint coordinates
#            qd0 (array_like) – initial joint velocities, assumed zero if not given
#            torque – a function that computes torque as a function of time

ejemplo = 'caos'

if ejemplo == 'ci':
	# Simulo movimiento ante condiciones iniciales
	tg = dp.nofriction(coulomb=True, viscous=True).fdyn(5, [0,0],qd0=np.zeros((2,)),dt=1e-3)
	curve_plot(dp,tg)

	#dp.plot(tg.q[1:-1:10],dt=1e-2,limits= [-0.4, 0.4, -0.4, 0.4, -0.1, 0.1],camera=[90,-90,0],movie="movimiento_ci.gif")
	dp.plot(tg.q[1:-1:10],dt=1e-2,limits= [-0.4, 0.4, -0.4, 0.4, -0.1, 0.1], camera=[90,-90,0])


elif ejemplo == 'caos':
	# Prueba de movimiento caótico
	tg = dp.nofriction(coulomb=True, viscous=True).fdyn(5, [-np.pi/2+0.1+1.57,0],qd0=np.zeros((2,)),dt=1e-3)
	curve_plot(dp,tg)
	# Prestar atención a los parámetros del integrador. Se ajustaron para que las curvas no tengan quiebres
	tg = dp.nofriction(coulomb=True, viscous=True).fdyn(5, [-np.pi/2+0.11+1.57,0],qd0=np.zeros((2,)),progress=True,solver_args={'rtol':1e-6, 'atol':1e-9, 'max_step':1e-3},dt=1e-3)
	curve_plot(dp,tg)
	plt.show()
	#dp.plot(tg.q[1:-1:10],dt=1e-2,limits= [-0.4, 0.4, -0.4, 0.4, -0.1, 0.1],camera=[90,-90,0],movie="movimiento_caos.gif")	
	dp.plot(tg.q[1:-1:10],dt=1e-2,limits= [-0.4, 0.4, -0.4, 0.4, -0.1, 0.1],camera=[90,-90,0])
	
elif ejemplo == 'input':
	# Repito la simulación pero aplicando un torque que compense el peso propio
	def torque_sosten(robot, t, q, qd):
		return np.array([4.41,0.98])/10
	def torque_pulso(robot, t, q, qd):
		if t<0.2:
			tau = np.array([1,0])
		else: 
			tau = np.array([0,0])
		return tau

	def torque_sin(robot, t, q, qd):		
		A = 1
		omega = 2*np.pi*3 # pulsación de una frecuencia de 3Hz
		tau = np.array([A*np.sin(t*omega),0])
		return tau

	tg = dp.nofriction(coulomb=True, viscous=False).fdyn(5, [-np.pi/2,0],torque=torque_sin,qd0=np.zeros((2,)),dt=1e-3)
	curve_plot(dp,tg)
	dp.plot(tg.q[1:-1:10],dt=1e-2,limits= [-0.4, 0.4, -0.4, 0.4, -0.1, 0.1],camera=[90,-90,0])


