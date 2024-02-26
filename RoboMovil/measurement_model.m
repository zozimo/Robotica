function [weight, sumPesos ] = measurement_model(ranges, x, map,lidar,threshold)
    % Computes the observation likelihood of all particles.
    %
    % El modelo de sensor empleado es de lidar en un rango de -90° a 90°.

    % ranges: vector de mediciones de rango del lidar.
    % x: conjunto de partículas actuales.
    
    sigma = 0.2; % Desviación estándar para el modelo de medición

    % Inicializa los pesos a 1
    weight = ones(size(x, 1), 1);
%     intersectionPts = rayIntersection(map,x(1000,:),lidar.scanAngles,lidar.maxRange)
%   Para cada elemento que se asocia a un angulo del mapa hago la diferencias 
%   euclideana entre esa interseccion y la posicion de la particula, asi tengo
%   el range para ese angulo y lo comparo con el range real medido por el sensor,
%   y en base a eso le asocio un peso a esa particula
%   vamos a eliminar los angulos que tiene nan
    indices_nan = find(isnan(ranges));

    % Eliminar los valores NaN del vector
    range_reducido = ranges;
    range_reducido(indices_nan) = [];
    angleReducido = lidar.scanAngles;
    angleReducido(indices_nan) = [];
    if isempty(ranges)
        return
    end
%     Hacemos un submuestreo de los rayos
    range_reducido = range_reducido(1:10:end);
    angleReducido = angleReducido(1:10:end);
    % Submuestrear el vector
%     vectorSubmuestreado = datasample(vectorCompleto, numMuestrasSubmuestreadas, 'Replace', false);
    % Calcula la probabilidad de la medición para cada partícula
    for i = 1:size(x, 1)
%         initPose = [8; 9; deg2rad(180)];
%         intersectionPts = rayIntersection(map,[8; 9; deg2rad(180)],angleReducido,lidar.maxRange);
% Pongo umbral en 0.5 para que considere las zonas grises como pared y no pueda avanzar
        intersectionPts = rayIntersection(map,x(i,:),angleReducido,lidar.maxRange,threshold);
%         figure(2)
%         show(map)     
%         hold on
%         plot(intersectionPts(:,1),intersectionPts(:,2),'*r')
%         plot(x(i,1),x(i,2),'ob') % Vehicle pose
%         num_puntos = length(intersectionPts);
%         for j = 1:num_puntos
%              % Obtener los puntos de la i-ésima fila
%             
%             % Trazar la recta que une los puntos
%             plot([x(i,1),intersectionPts(j,1) ], [x(i,2), intersectionPts(j,2)], '-b');
%             hold on;
%         end
        
        
        % Utiliza las coordenadas de la partícula directamente como si fueran
        % las coordenadas de la medición del lidar
%         estimated_ranges = sqrt((intersectionPts(:,1)-8).^2 + (intersectionPts(:,2)-9).^2);
         estimated_ranges = sqrt(((intersectionPts(:,1)-x(i,1)).^2) + ((intersectionPts(:,2)-x(i,2)).^2));
%         cocienteProb = range_reducido./estimated_ranges;
%         cocienteProb(cocienteProb > 1) = 1 ./ cocienteProb(cocienteProb > 1);
        % Calcula la probabilidad de la medición para esta partícula
         measurement_prob = normpdf(range_reducido - estimated_ranges, 0, sigma);
        
        % Multiplica el peso de la partícula por la probabilidad de la medición
%         porque consideramos a los haces independientes
         measurement_prob(isnan(measurement_prob)) = [];
%         cocienteProb(isnan(cocienteProb)) = [];
        probability_total = prod(measurement_prob);
%         if isempty(cocienteProb)
%             weight(i)= 0;
%         else
%             log_probability_total = sum(log(measurement_prob));
%             probability_total = exp(log_probability_total);
%             probability_total = prod(measurement_prob);
        weight(i) = weight(i) * probability_total;
%         end
            
    end
    disp(sum(weight))
    sumPesos = sum(weight);
%     si es alto porque estan convergiendo, si es bajo no
    % Normaliza los pesos
     weight = weight ./ sum(weight);
 
end