%% Robot diferencial con lidar
% Robotica Movil - 2023 1c


close all
clear all

verMatlab= ver('MATLAB');   % en MATLAB2020a funciona bien, ajustado para R2016b, los demas a pelearla...

simular_ruido_lidar = true; %simula datos no validos del lidar real, probar si se la banca
use_roomba=false;  % false para desarrollar usando el simulador, true para conectarse al robot real

%% Roomba
if use_roomba   % si se usa el robot real, se inicializa la conexion    
    rosshutdown
    pause(1)
    ipaddress_core = '192.168.0.102';
    ipaddress_local = '192.168.0.101';  %mi ip en a red TurtleNet
    setenv('ROS_IP', '192.168.0.101');
    setenv('ROS_MASTER_URI', ['http://', ipaddress_core, ':11311']);
    rosinit(ipaddress_core,11311, 'NodeHost', ipaddress_local)
    pause(1)
    laserSub = rossubscriber('/scan');
    odomSub = rossubscriber('/odom');
    cmdPub = rospublisher('/auto_cmd_vel', 'geometry_msgs/Twist');
    pause(1) % Esperar a que se registren los canales
    cmdMsg = rosmessage(cmdPub);  
end
    

%% Definicion del robot (disco de diametro = 0.35m)
R = 0.072/2;                % Radio de las ruedas [m]
L = 0.235;                  % Distancia entre ruedas [m]
dd = DifferentialDrive(R,L); % creacion del Simulador de robot diferencial

%% Creacion del entorno
% load mapa_fiuba_1p.mat      %carga el mapa como occupancyMap en la variable 'map'
load mapa_lae.mat         %mapa viejo para probar cosas
% load otro_mapa_mas.mat

if verMatlab.Release=='(R2016b)'
    %Para versiones anteriores de MATLAB, puede ser necesario ajustar mapa
    imagen_mapa = 1-double(imread('imagen_mapa_viejo.tiff'))/255;
    map = robotics.OccupancyGrid(imagen_mapa, 25);
elseif verMatlab.Release=='(R2018a)'    % Completar con la version que tengan
    imagen_mapa = 1-double(imread('mapa_fiuba_1p.tiff'))/255;
%     imagen_mapa = 1-double(imread('imagen_mapa_viejo.tiff'))/255;
    map = robotics.OccupancyGrid(imagen_mapa, 25);
    disp('R2018b funciona');
else
    disp(['Utilizando MATLAB ', verMatlab.Release]);
end

%% Crear sensor lidar en simulador
lidar = LidarSensor;
lidar.sensorOffset = [0,0];     % Posicion del sensor en el robot (asumiendo mundo 2D)
scaleFactor = 3;                %decimar lecturas de lidar acelera el algoritmo
num_scans = round(513/scaleFactor);
hokuyo_step_a = deg2rad(-90);
hokuyo_step_c = deg2rad(90);

lidar.scanAngles = linspace(hokuyo_step_a,hokuyo_step_c,num_scans);
lidar.maxRange = 10; %[m]

%% Crear visualizacion
viz = Visualizer2D;
viz.mapName = 'map';
attachLidarSensor(viz,lidar);

%% Parametros de la Simulacion

simulationDuration = 100*60;     % Duracion total [s]
sampleTime = 0.1;                   % Sample time [s]
% cantidad_particulas = 10000;
cantidad_particulas = 20000;
% cantidad_particulas = 30000;
% cteSumPesos = 1e2;
% resetParticles = 1e-200;
resetParticles = 0;
% resampleParticles = 100;
resampleParticles = 200;
% resampleParticles = 300;
% umbralLocalizacion = 1e+6;
% umbralLocalizacion = 1e5;
threshold = 0.5;
diffMaximaPose = 0.01;
% Definimos un umbral de medicion de distancia para evitar actuar y evitar
% choque calculado para 1000 particulas
umbralDistanciaColision = 0.7;
% umbralDistanciaColision = 1.2;
% Declaramos una variable para detectar posible colisi�n
noColision = true;  
valMapa = false;
localizado =false;

filtro = true;
% Datos del camino
buscarCamino=true;
intermedio1 = [8.22,6.18];
intermedio2 = [7.95,4.82];
intermedio3= [6.58,4.02];
objetivo1 = [5.3,4.3];
tolerancia = 0.01;

% Datos del PD
Kp_theta = 0.2; %Hcaerlo un poco mas agresivo a 0.25
Kp_x = 1.25; %le bajo de 2
% Kp_x = 2; %le bajo de 2
Kd_theta = -0.05;
Kd_x = 0.1;
%  probar iniciar el robot en distintos lugares                                  
% initPose = [14; 7; deg2rad(-135)];        
% initPose = [7; 10; deg2rad(90)];         
% initPose = [5; 4.2; deg2rad(90)]; 
% initPose = [9.5; 15; deg2rad(0)];

% Poses posbibles en el 1erpiso
% initPose = [9.5; 10; deg2rad(180)];%funco
% initPose = [9; 9; deg2rad(120)]; %funco
% initPose = [14; 7; deg2rad(120)]; %funco
initPose = [8.5; 10; deg2rad(0)];%funco
% initPose = [9; 15; deg2rad(-120)]; %funco        
% initPose = [8.9; 8.18; deg2rad(135)];%funco  
% % initPose = [9.38; 14.22; deg2rad(-160)];%funco  
% initPose = [11.9; 7.7; deg2rad(85)];%funco  
% Pose inicial para mapa viejo
% initPose = [5; 3; deg2rad(90)];
% initPose = [5; 3; deg2rad(-90)];
% Inicializar vectores de tiempo:
tVec = 0:sampleTime:simulationDuration;         % Vector de Tiempo para duracion total

%% generar comandos a modo de ejemplo
% Utilizaremos estos comandos para avanzar en linea recta cuando no hay obstaculos
% vxRef = 0.15*ones(size(tVec));   % Velocidad lineal a ser comandada
vxRef = 0.3*ones(size(tVec));   % Velocidad lineal a ser comandada
wRef = zeros(size(tVec));       % Velocidad angular a ser comandada
pose = zeros(3,numel(tVec));    % Inicializar matriz de pose
if use_roomba == false
    pose(:,1) = initPose;
end
%% Inicializaci�n del Filtro de Part�culas


load('espacioLibre1piso.mat');
% Initialize particles
particles = inicializarParticulas(freeX,freeY,cantidad_particulas);
%% Simulacion

if verMatlab.Release=='(R2018a)'
    r = robotics.Rate(1/sampleTime);    %matlab viejo no tiene funcion rateControl
else
    r = rateControl(1/sampleTime);  %definicion para R2020a, y posiblemente cualquier version nueva
end
k = 1;

for idx = 2:numel(tVec)   
    
    % Generar aqui criteriosamente velocidades lineales v_cmd y angulares w_cmd
    % -0.5 <= v_cmd <= 0.5 and -4.25 <= w_cmd <= 4.25
    % (mantener las velocidades bajas (v_cmd < 0.1) (w_cmd < 0.5) minimiza vibraciones y
    % mejora las mediciones.   
    
    %% COMPLETAR ACA por el alumnoa:
         % generar velocidades para este timestep
        
        % Si el flag de noColision es verdadero entonces avanzamos linealmente
        if (localizado == false && buscarCamino==true)
            if noColision
                v_cmd = vxRef(idx-1);
                w_cmd = wRef(idx-1); 
            else
            % Si se detecta colision se reduce la velocidad al 50% y se realiza
            % un giro relativamente suave multiplicado por el signo de giro que
            % se explica mas abajo
                v_cmd = 0.05;
            % Si se sube mucho w_cmd es menos suave la trayectoria
                w_cmd = 0.25*sign(giro);

            end
        end
        % fin del COMPLETAR ACA
    
    %% a partir de aca el robot real o el simulador ejecutan v_cmd y w_cmd:
    
    if use_roomba       % para usar con el robot real
        
        % Enviar comando de velocidad en el formato que pide el robot:
        cmdMsg.Linear.X = v_cmd;
        cmdMsg.Angular.Z = w_cmd;
        send(cmdPub,cmdMsg);
        
        % Recibir datos de lidar y odometría
        scanMsg = receive(laserSub);
        odompose = odomSub.LatestMessage;
        
        % Obtener vector de distancias del lidar
        ranges_full = laserSub.LatestMessage.Ranges;
        ranges = double(ranges_full(1:scaleFactor:end));
        ranges(ranges==0)=NaN; % lecturas erroneas y maxrange
        
        % Se filtran mediciones debido a los dos parantes de la bandeja
        ranges(ranges < 0.2) = NaN; 

        % Obtener pose del robot [x,y,yaw] de datos de odometría (integrado por encoders).
        odomQuat = [odompose.Pose.Pose.Orientation.W, odompose.Pose.Pose.Orientation.X, ...
        odompose.Pose.Pose.Orientation.Y, odompose.Pose.Pose.Orientation.Z];
        odomRotation = quat2eul(odomQuat);
        pose(:,idx) = [odompose.Pose.Pose.Position.X + initPose(1); odompose.Pose.Pose.Position.Y+ initPose(2); odomRotation(1)];
        vel = (pose(:,idx) - pose(:,idx-1))./sampleTime; 
    else        % para usar el simulador
   
        % Mover el robot segun los comandos generados
        [wL,wR] = inverseKinematics(dd,v_cmd,w_cmd);
        % Velocidad resultante
        [v,w] = forwardKinematics(dd,wL,wR);
        velB = [v;0;w]; % velocidades en la terna del robot [vx;vy;w]
        vel = bodyToWorld(velB,pose(:,idx-1));  % Conversion de la terna del robot a la global
%         vx = vel(1);
%         vy = vel(2);
%         pfVelocities = [vx; vy; w];
        % Realizar un paso de integracion
        pose(:,idx) = pose(:,idx-1) + vel*sampleTime; 
%         vel2 = (pose(:,idx) - pose(:,idx-1))./sampleTime; 
        % Tomar nueva medicion del lidar
        ranges = double(lidar(pose(:,idx)));        
        % Se filtran las mediciones, debido a los dos parantes de la bandeja
        ranges(ranges < 0.2) = NaN; 
        if simular_ruido_lidar
            % Simular ruido de un lidar ruidoso (probar a ver si se la banca)
            chance_de_medicion_no_valida = 0.17;
            not_valid=rand(length(ranges),1);
            ranges(not_valid<=chance_de_medicion_no_valida)=NaN;
        end
        

    end
    
        % %         % Actualizar el filtro de part�culas con las mediciones del LIDAR y la odometr�a
        
    if (localizado == false)
        new_particles = sample_motion_model(vel,sampleTime, particles);
        
        [weights,sumPesos ] = measurement_model(ranges, new_particles, map,lidar,threshold);
        
        particles = resample(new_particles, weights);
            if filtro == true
                particles = particles(1:resampleParticles:end,:);
                threshold = 0.9;
                filtro = false;
            end
            if sumPesos < resetParticles 
               particles = inicializarParticulas(freeX,freeY,cantidad_particulas);
               threshold = 0.5;
               filtro = true;
            end
%             no restringo con el signo del angulo pero cuando asigno el angulo de las particulas los normalizo a pi
%             if(sumPesos >= umbralLocalizacion && all(sign(mean(particles)') == sign(pose(:,idx))))
%             if(sumPesos >= umbralLocalizacion)
            aux = mean(particles)';
            if abs(pose(1,idx)-aux(1))<diffMaximaPose && abs(pose(2,idx)-aux(2))<diffMaximaPose && abs(pose(3,idx)-aux(3))<diffMaximaPose
    
                if sign(aux(3)) ~= sign(pose(3,idx))
                    particles = inicializarParticulas(freeX,freeY,cantidad_particulas);
                    filtro = true;
                end
                valMapa = true;
                localizado = true;
                disp('ya me localice')
                disp(mean(particles))
                disp( pose(:,idx)')
%         Actualizo la pose con el valor de lozalizacion
                pose(:,idx) = mean(particles)';
            end
%         end
    elseif (localizado == true && buscarCamino==true)
        

        
%         voy desde la pose localizada del robot hasta punto intermedio
        path1 = planning_framework(pose(:,idx),intermedio1 );
        path1 = path1(1:10:end,:);
%         Voy desde pose intermedia hasta la puerta del labo
        path2 = planning_framework(intermedio1,intermedio2 );
        path2 = path2(1:4:end,:);
        path3 = planning_framework(intermedio2,intermedio3 );
%         path3 = path3(1:5:end,:);
        path4 = planning_framework(intermedio3,objetivo1 );
        %         path4 = path4(1:5:end,:);
        aux = [path3;path4];
        aux = aux(1:5:end,:);

        path = [path1;path2;aux];
%         path = path(1:5:end,:);
        buscarCamino = false;
        
    end
    %%
    % Aca el robot ya ejecuta las velocidades comandadas y devuelve en la
    % variable ranges la medicion del lidar para ser usada y
    % en la variable pose(:,idx) la odometria actual.
    
    %% COMPLETAR ACA por el alumno:
    

    if (localizado == false && buscarCamino==true)
%         si no estoy localizado y sigo buscando camino optimo
        if any(ranges < umbralDistanciaColision)
            % Si alguno de los rayos es menor que el umbral de colisi�n entonces se
            % pone el flag de noColision en falso y se procede a actuar como sigue:
            disp('�Pared detectada! Girando...')
            noColision = false; 

            promedioRangeDerecha = nanmean(ranges(1:int32(length(ranges)/2)));
            promedioRangeIzquierda = nanmean(ranges(int32(length(ranges)/2):end));
            if promedioRangeDerecha < promedioRangeIzquierda
                giro = 1; %w_cmd > 0 gira hacia la izquierda
            else
                giro = -1;%w_cmd > 0 gira hacia la derecha
            end   

        else

           disp('Camino Despejado Avanza tranquilo!')
    %        avanza en base al mapa, tomando la trayectoria definida

           noColision = true; 
        end    
    elseif(buscarCamino == false)
        disp('ya puedo empezar a recorrer la trayectoria')

%% Pid
        eX = (path(k,1)- pose(1,idx));
        eY = (path(k,2)- pose(2,idx));
        eX_dot = eX/ sampleTime;
        eY_dot = eY/ sampleTime;
        anguloInicial = rad2deg(pose(3,idx));
        anguloObjetivo = rad2deg(atan2(eY,eX));
                % Calcular la distancia en sentido horario y antihorario
        distanciaHorario = mod(anguloObjetivo - anguloInicial, 360);
        distanciaAntihorario = mod(anguloInicial - anguloObjetivo, 360);
      
        eTheta = anguloObjetivo - anguloInicial;
        eTheta = deg2rad(eTheta);
        eTheta_dot = eTheta / sampleTime;
        % Calcular el control PID de orientaci�n
        w_cmd = Kp_theta * eTheta - Kd_theta * eTheta_dot;
        if abs(w_cmd) > 0.4
            disp('error me fui de rosca!!!!!!!!!!!!!1')
        end
        v_cmd = 0;
%         disp(eTheta)
        if abs(eTheta) < 0.05
            v_cmd = Kp_x * sqrt(eX^2 + eY^2);%+ Kd_ * sqrt(eX_dot^2 + eY_dot^2);
            w_cmd = 0;
            if abs(v_cmd) > 0.15
                disp('error me fui de rosca Lineal!!!!!!!!!!!!!1')
            end
%             disp(eX)
%             disp(eY)
            if abs(eX) < 0.02 && abs(eY) < 0.02
               
                k = k+1;
            end
        end
        

    end
        
    %%
    % actualizar visualizacion
    
    viz(pose(:,idx),ranges)
    
    hold on
    if (sumPesos > resetParticles)
        plot(particles(:, 1),particles(:, 2),'g.');
    end
    hold off
%     filename = sprintf('plots/PoseInit(5_3_0)_mapaViejo_%03d.png', idx-1);
%     saveas(gcf,filename)
    waitfor(r);


end

