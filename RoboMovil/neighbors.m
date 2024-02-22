function n = neighbors(cell, map_dimensions)

  n = [];

  pos_x = cell(2);
  pos_y = cell(1);
  size_x = map_dimensions(2);
  size_y = map_dimensions(1);
  
  %%% YOUR CODE FOR CALCULATING THE NEIGHBORS OF A CELL GOES HERE
  
  % Return nx2 vector with the cell coordinates of the neighbors. 
  % Because planning_framework.m defines the cell positions as pos = [cell_y, cell_x],
  % make sure to return the neighbors as [n1_y, n1_x; n2_y, n2_x; ... ]
%   Mietras este dentro del mapa devuelve 8 vecinos
  if pos_y ~= size_y
      n = [n; [pos_y+1,pos_x] ];
      if pos_x ~= 1
          n = [n; [pos_y+1,pos_x-1] ];
          n = [n; [pos_y,pos_x-1] ];
      end
      if pos_x ~= size_x
          n = [n; [pos_y+1,pos_x+1] ];
          n = [n; [pos_y,pos_x+1] ];
      end
  end
  
  if pos_y ~= 1
      n = [n; [pos_y-1,pos_x] ];
      if pos_x ~= 1
          n = [n; [pos_y-1,pos_x-1] ];
      end
      if pos_x ~= size_x
          n = [n; [pos_y-1,pos_x+1] ];
      end
  end
end