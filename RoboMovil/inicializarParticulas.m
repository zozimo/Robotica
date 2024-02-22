function particles = inicializarParticulas(freeX,freeY,count)
    particles = zeros(count, 3);
    
    % Obtener todas las coordenadas de celdas no ocupadas
%     [freeX, freeY] = findOccupiedCells(map);
    
    % Seleccionar aleatoriamente count coordenadas de celdas no ocupadas
    idx = randi(size(freeX'), [count,1]);
    particles(:, 1) = freeX(idx);
    particles(:, 2) = freeY(idx);
    
    % Asignar valores aleatorios para la orientación de las partículas
    particles(:, 3) = unifrnd(-pi, pi, count, 1);
    
    
%      particles = zeros(count, 3);
% %      particles(:,3) = unifrnd(-2*pi, 2*pi, count, 1);
%     particles = [
%         unifrnd(5, 15, count, 1), ...
%         unifrnd(1, 22, count, 1), ...
%         unifrnd(-2*pi, 2*pi, count, 1)
%     ];
%     for i = 1:count
%         x = rand() * map.XWorldLimits(2);
%         y = rand() * map.YWorldLimits(2);
% 
%         % Verificar si la celda está ocupada antes de agregar la partícula
%         cellValue = map.getOccupancy([x, y]);
%         
%         if cellValue < 0.4 % Si la celda no está ocupada
%             particles(i, 1:2) = [x, y];
%         end
%     end
end