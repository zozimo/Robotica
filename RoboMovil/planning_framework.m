function path = planning_framework(pose, goal)
    % NOTE that in octave/MATLAB, matrices are accessed with A(y,x),
    % where y is the row and x is the column

%     clear
%     close all;clear all   ;
    % TrayectoriaImg = "plots/SinHeuristicaDijkstra.png"; % Poner en cero la "HeuristicaON=0" en heuristic.m
%     TrayectoriaImg = "plots/HeuristicaA_asterisco_Ka_1.png"; % Poner en cero la "k_A=1" en heuristic.m
    % TrayectoriaImg = "plots/HeuristicaA_asterisco_Ka_2.png"; % Poner en cero la "k_A=2" en heuristic.m
    % TrayectoriaImg = "plots/HeuristicaA_asterisco_Ka_5.png"; % Poner en cero la "k_A=5" en heuristic.m
    % TrayectoriaImg = "plots/HeuristicaA_asterisco_Ka_10.png"; % Poner en cero la "k_A=6" en heuristic.m

    %  ¿Qué pasa si se aumenta la heurística?
    % RTA: El algoritmo muestra una mayor agresividad al seleccionar los nodos 
    % de costo mínimo para explorar. Además, se observa que para valores más 
    % altos de 'ka' la trayectoria obtenida conduce al robot cerca de la pared.
    % se ven los resultado en la carpeta plots




    % load the map
    % map = load('map.mat', '-ascii');
    map = 1-double(imread('mapa_fiuba_1p.tiff'))/255;
    %map = a.G;

    % visualizes the map. Note: 
    % the y-axis is inverted, so 0,0 is top-left, 
    figure()
    imshow(map);
    title ('Map');
    hold on;

    % retrieve height and width of the map
    [h,w] = size(map);

    % cost values for each cell, filled incrementally. Initialize with infinity
    costs = ones(h,w)*inf;

    % estimated costs to the goal.
    heuristics = zeros(h,w);

    % cells that have been visited
    closed_list = zeros(h,w);

    % these matrices implicitly store the path
    % by containing the x and y position of the previous
    % node, respectively. Following these starting at the goal 
    % until -1 is reached returns the computed path, see at the bottom
    previous_x = zeros(h,w)-1;
    previous_y = zeros(h,w)-1;

    % start and goal position (y,x)
    x_i = pose(1)*25;
    y_i = 575 - (pose(2)*25);
    start = [y_i,x_i];
    goal = round([575 - (goal(2)*25),goal(1)*25]);
    
    %plot start and goal cell
    hold on
    plot(start(2), start(1), 'r.');
    plot(goal(2), goal(1), 'g.');
    pause(1); %pause for visualization

    %start search at the start 
    parent=start;
    costs(round(start(1)),round(start(2))) = 0;

    %loop until the goal is found
    while (parent(1)~=goal(1) || parent(2)~=goal(2))

      %generate mask to assign infinite costs for cells already visited
      closed_mask = closed_list;
      closed_mask( closed_mask==1 )=Inf; 

      %find the candidates for expansion (open list/frontier)
      open_list = costs + closed_mask + heuristics;

      %check if a non-infinite entry exists in open list (list is not empty)
      if min(open_list(:))==Inf
        disp('no valid path found');
        break
      end

      %find the cell with the minimum cost in the open list
      [y,x] = find(open_list == min(open_list(:)));
      parent_y = y(1);
      parent_x = x(1);
      parent = [parent_y, parent_x];

      %put parent in closed list
      closed_list(parent_y,parent_x) = 1;
      plot(parent_x, parent_y, ' y.' );

      %for visualization: Plot start again
      if(parent(1) == start(1) && parent(2) == start(2))
        plot(start(2), start(1), 'r.');
      end
    %   primero
      %get neighbors of parent
      n = neighbors(parent, [h,w]);
      for i=1:size(n,1)
        child_y = n(i,1);
        child_x = n(i,2);
        child = [child_y, child_x];

        %calculate the cost of reaching the cell
    %     segundo
        cost_val = costs(parent_y,parent_x) + edge_cost(parent, child, map);

        %Exercise 2: estimate the remaining costs from the cell to the goal
        heuristic_val = heuristic(child, goal);

        %update cost of cell
        if cost_val < costs(child_y,child_x)
          costs(child_y,child_x) = cost_val;
          heuristics(child_y,child_x) = heuristic_val;

          %safe child's parent
          previous_x(child_y,child_x) = parent_x;
          previous_y(child_y,child_x) = parent_y;
        end
      end
      pause(0.05); %pause for visualization
    end

    % visualization: from the goal to the start,
    % draw the path as blue dots
    parent = [goal(1), goal(2)];
    distance2 = 0;
    path_x = [];
    path_y = [];
    i = 1;
    while previous_x(parent(1), parent(2))>=0
      plot(parent(2), parent(1), 'b.');

      %for visualization: Plot goal again
      if(parent(1) == goal(1) && parent(2) == goal(2))
        plot(goal(2), goal(1), 'g.');
      end
    %   a la imagen le paso (y ,x)
      child_y = previous_y(parent(1), parent(2));
      child_x = previous_x(parent(1), parent(2));
      child = [child_y, child_x];
      distance2 = distance2+norm(parent - child);
    %   podria guardar estas coordenadas en un vector llamado path, asi tengo
    %   mi camino optimo, guardo cada cordenada de child y luego hago un flip
    % asi obtengo el camino del start al goal
      path_x(i)= child_x;
      path_y(i)= child_y;
      i=i+1;
      parent = child;
      pause(0.05); %pause for visualization
    end
    hold off
    path = [path_x;path_y];
    path = flip(path');
    path(:,1) = path(:,1)./25;
    path(:,2) = (575-path(:,2))./25;
    
%     saveas(gcf,TrayectoriaImg)
    disp 'done'
    disp 'path cost: ', disp(costs(goal(1),goal(2)));
    disp 'path length: ', disp(distance2);
    disp 'number of nodes visited: ', disp(sum(closed_list(:)));
end