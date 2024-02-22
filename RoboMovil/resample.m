function new_particles = resample(particles, weights)
    % Returns a new set of particles obtained by performing
    % stochastic universal sampling.
    %
    % particles (M x D): set of M particles to sample from. Each row contains
    % a state hypothesis of dimension D.
    % weights (M x 1): weights of the particles. Each row contains a weight.
    % M numero de particulas x 3 donde (x,y,theta) de la particula
    new_particles = [];

    M = size(particles, 1);
    c = zeros(M, 1);
    u = zeros(M, 1);
    %% TODO: complete this stub
    % A c(1) le ponemos el peso de la primer particula
    c(1) = weights(1);
    for  i = 2:M
        c(i) = c(i-1) + weights(i); 
    end
    % Inicializamos el umbral, la flechita con un numero uniformemente
    % ditribuido entre cero y 1/n
    u(1) = unifrnd(0,1/M);
    i = 1;
    for j = 1:M
    % Mientras la flechita este por arriba de la suma de todos los pesos
        while(u(j) > c(i))
            % Pasamos particulas hasta que encontramos una en la que la
            % flecha coincide con la sumatoria de pesos
            i = i + 1;
        end
        % Las particulas con menor peso se reemplazan con las de mayor peso
        new_particles = [new_particles; particles(i,:)];
        
        % generamos la proxima flechita 
        u(j+1) = u(j) + 1/M; 
    end
    return 
    
end
