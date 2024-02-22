classdef DifferentialDrive < handle
    % DIFFERENTIALDRIVE Differential Drive robot utilities
    %
    % For more information, see <a href="matlab:edit mrsDocDifferentialDrive">the documentation page</a>
    %
    % Copyright 2018 The MathWorks, Inc.
    
    properties
        wheelRadius = 0.036;  % Wheel radius [m] radio de las ruedas
        wheelBase = 0.235;    % Wheelbase [m] distancia entre ruedas
        alpha = 0.0015;
    end
    
    methods
        function obj = DifferentialDrive(wheelRadius,wheelBase)
            % DIFFERENTIALDRIVE Construct an instance of this class
            obj.wheelRadius = wheelRadius;
            obj.wheelBase = wheelBase;
        end
        
        function [v,w] = forwardKinematics(obj,wL,wR)
            % Calculates linear and angular velocity from wheel speeds
%             Calcula la velocidad lineal y angular a partir de las velocidades de las ruedas.
            v = 0.5*obj.wheelRadius*(wL+wR)+normrnd(0,obj.alpha*(wL^2+wR^2));
            w = (wR-wL)*obj.wheelRadius/obj.wheelBase+normrnd(0,obj.alpha*(wL^2+wR^2));
        end
              
        function [wL,wR] = inverseKinematics(obj,v,w)
           % Calculates wheel speeds from linear and angular velocity
%            Calcula las velocidades de las ruedas desde la velocidad angular y lineal
           wL = (v - w*obj.wheelBase/2)/obj.wheelRadius;
           wR = (v + w*obj.wheelBase/2)/obj.wheelRadius;
        end
        
    end
end

