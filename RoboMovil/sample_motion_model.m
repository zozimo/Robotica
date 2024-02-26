function x_new = sample_motion_model(u,sampleTime, x)
    % Samples new particle positions, based on old positions and odometry.
    %
    % u: odometry reading (with linear velocity v and angular velocity w)
    % x: set of old particles

    % Noise parameters
    noise = [0.1 0.1 0.05 0.05,0.05,0.05];
%      noise = [0.05 0.05 0.5 0.5,0.5,0.5];
    % Particle count
    pc = size(x, 1);
    v = sqrt(u(1)^2+u(2)^2);
    w = u(3);
    % Compute normal distributed noise
    O = repmat([v, w,0], pc, 1);
    M = zeros(pc, 3);
    S = repmat([
        max(0.00001, noise(1) * abs(v) + noise(2) * abs(w)) ...
        max(0.00001, noise(3) * abs(v) + noise(4) * abs(w))...
        max(0.00001, noise(5) * abs(v) + noise(6) * abs(w))...
        
    ], pc, 1);
    N = normrnd(M, S, pc, 3);

    % Add noise to the motion for every particle
    odom = O + N;

    % Compute new particle positions
    x_new = x + [
        (-odom(:, 1)./odom(:, 2)).*sin(x(:, 3))+(odom(:, 1)./odom(:, 2)).*sin(x(:, 3)+odom(:, 2)*sampleTime), ...
        (odom(:, 1)./odom(:, 2)).*cos(x(:, 3))-(odom(:, 1)./odom(:, 2)).*cos(x(:, 3)+odom(:, 2)*sampleTime), ...
        odom(:, 2)*sampleTime + odom(:, 3)*sampleTime
    ];
end