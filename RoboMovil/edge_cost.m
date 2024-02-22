function cost = edge_cost(parent, child, map)

  cost = 0;
 
  %%% YOUR CODE FOR CALCULATING THE COST FROM VERTEX parent TO VERTEX child GOES HERE
    child_y = child(1);
    child_x = child(2);
     % Costo del nodo hijo segun la grilla de ocupación
    cost_child =  map(child_y, child_x); 
    
    % Umbral del costo.  Se ha observado que a partir de 0.4 se puede apreciar obstáculos
    if cost_child  > 0.4  % Si la probabilidad de ocupación es mayor a 4, se considera un obstáculo y el costo es infinito
        cost = cost + inf;
    end
    dist_pc = norm(parent - child); % Distancia padre a  hijo
    %Parámetros para ajustar el algoritmo
    k_D_cost = 1; 
    k_D_dist = 1;
      
    
    % EL Costo toal deberia ser combinación lineal del costo dado por la
    % grilla de ocupación y la distancia padre-hijo.
    cost = cost + k_D_dist * dist_pc + k_D_cost *cost_child;
end