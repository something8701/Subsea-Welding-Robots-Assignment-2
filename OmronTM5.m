% OmronTM5.m

classdef OmronTM5 < handle
    properties
        robot % SerialLink object representing the robot
    end
    methods
        function self = OmronTM5()
            % Define the DH parameters for Omron TM5
            % Note: Replace these parameters with the actual ones if available
            L1 = Link('d', 0.225, 'a', 0,     'alpha', -pi/2);
            L2 = Link('d', 0,     'a', 0.350, 'alpha', 0);
            L3 = Link('d', 0,     'a', 0.100, 'alpha', -pi/2);
            L4 = Link('d', 0.350, 'a', 0,     'alpha', pi/2);
            L5 = Link('d', 0,     'a', 0,     'alpha', -pi/2);
            L6 = Link('d', 0.100, 'a', 0,     'alpha', 0);

            % Create the SerialLink robot model
            self.robot = SerialLink([L1 L2 L3 L4 L5 L6], 'name', 'Omron TM5');
        end

        function plotRobot(self, q)
            % Plot the robot at configuration q
            if nargin < 2
                q = zeros(1,6); % Default to zero position
            end
            self.robot.plot(q, 'workspace', [-1 1 -1 1 0 1.5]);
            title('Omron TM5 Robot');
        end
    end
end
