function heur = heuristic(cell, goal)
    
    HeuristicaON = 1;
    if HeuristicaON == 1    
%         algoritmo A*
%         k_A = 1;
%         Descomentar esto para ver como que pasa a medida que se aumenta la heuristica
        k_A = 2;
%         k_A = 5;
%         k_A = 10;
        % La heurística sera a la distancia entre el nodo destino y el nodo hijo que se está analizando
        heur = k_A * norm(goal-cell); 
        
        
    else    
%         Sin heuristica algoritmo de DIJKSTRA
        heur = 0;
    end
  %%% YOUR CODE FOR CALCULATING THE REMAINING COST FROM A CELL TO THE GOAL GOES HERE
  
end
