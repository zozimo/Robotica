% Supongamos que tienes matrices x e y
x = [1, 2, 3, 4, 5];
y = [2, 4, 1, 3, 5];

% Matriz de rotación -90 grados en sentido horario
rot_matrix = [0, 1; -1, 0];

% Crear una matriz de coordenadas originales
coordinates = [x; y];

% Aplicar la rotación a cada par de coordenadas
rotated_coordinates = rot_matrix * coordinates;

% Obtener las coordenadas rotadas
x_rotated = rotated_coordinates(1, :);
y_rotated = rotated_coordinates(2, :);

% Graficar las coordenadas originales y rotadas
scatter(x, y, 'filled', 'DisplayName', 'Coordenadas Originales');
hold on;
scatter(x_rotated, y_rotated, 'filled', 'DisplayName', 'Coordenadas Rotadas');
hold off;

% Ajustar los límites para que ambas gráficas sean visibles
xlim([min(x_rotated), max(x_rotated)]);
ylim([min(y_rotated), max(y_rotated)]);

% Mostrar leyenda y gráfico
legend;
grid on;
xlabel('Eje X');
ylabel('Eje Y');
title('Rotación de Coordenadas 270 grados');