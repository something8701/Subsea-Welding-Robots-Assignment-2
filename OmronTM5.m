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

        function plotRobot(self, q, hAxes)
            % Plot the robot at configuration q
            if nargin < 2 || isempty(q)
                q = zeros(1,6); % Default to zero position
            end
            % Plot the robot in the current figure and axes
            self.robot.plot(q, 'workspace', [-5 5 -5 5 0 5], 'nojoints', 'noname', 'noshadow', 'nowrist');
            title(hAxes, 'Omron TM5 Robot');
        end

        function moveToPoint(self, point, hAxes)
            % Move the robot's end-effector to a specified 3D point
            q0 = zeros(1,6); % Initial joint configuration
            T = transl(point); % Desired end-effector position
            q_sol = self.robot.ikcon(T, q0); % Compute inverse kinematics
            self.robot.plot(q_sol, 'workspace', [-5 5 -5 5 0 5], 'nojoints', 'noname', 'noshadow', 'nowrist');
            title(hAxes, 'Omron TM5 Moving to Point');
        end
    end
end
