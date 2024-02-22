function [freeX, freeY] = findOccupiedCells(map)
%     % Obtener el tamaño del mapa
%     [height, width] = size(map.OccupancyGrid);
% 
    % Inicializar vectores para almacenar coordenadas de celdas no ocupadas
    freeX = [];
    freeY = [];

    % Recorrer todo el mapa
    for x = 1:0.04:map.XWorldLimits(2)
        for y = 1:0.04:map.YWorldLimits(2)
            % Obtener el valor de ocupación de la celda
            cellValue = map.getOccupancy([x, y]);

            % Verificar si la celda no está ocupada
            if cellValue < 0.01
                % Almacenar las coordenadas de la celda no ocupada
                freeX = [freeX; x];
                freeY = [freeY; y];
            end
        end
    end
end