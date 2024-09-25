% OmronTM5.m

classdef OmronTM5 < handle
    properties
        robot % SerialLink object representing the robot
    end

    methods
        function self = OmronTM5()
            % Define the DH parameters for Omron TM5
            % Note: Replace these parameters with the actual ones if available

            % Use one set of DH parameters, not both
            % First set:
            L1 = Link('d', 0.225, 'a', 0,     'alpha', -pi/2);
            L2 = Link('d', 0,     'a', 0.350, 'alpha', 0);
            L3 = Link('d', 0,     'a', 0.100, 'alpha', -pi/2);
            L4 = Link('d', 0.350, 'a', 0,     'alpha', pi/2);
            L5 = Link('d', 0,     'a', 0,     'alpha', -pi/2);
            L6 = Link('d', 0.100, 'a', 0,     'alpha', 0);

            % Alternatively, if you prefer the second set, comment out the first set
            % L1 = Link('d', 0.2, 'a', 0, 'alpha', -pi/2);
            % L2 = Link('d', 0, 'a', 0.3, 'alpha', 0);
            % L3 = Link('d', 0, 'a', 0.2, 'alpha', -pi/2);
            % L4 = Link('d', 0.4, 'a', 0, 'alpha', pi/2);
            % L5 = Link('d', 0, 'a', 0, 'alpha', -pi/2);
            % L6 = Link('d', 0.1, 'a', 0, 'alpha', 0);

            % Create the SerialLink robot model
            self.robot = SerialLink([L1 L2 L3 L4 L5 L6], 'name', 'Omron TM5');

            % Set the base transform if needed
            self.robot.base = transl(0, -1, 0); % Adjust as needed
        end

        function plotRobot(self, q)
            % Plot the robot at configuration q
            if nargin < 2 || isempty(q)
                q = zeros(1,6); % Default to zero position
            end
            % Plot the robot
            self.robot.plot(q, 'workspace', [-5 5 -5 5 0 5], ...
                'nojoints', 'noname', 'noshadow', 'nowrist', 'delay', 0);
        end

        function moveToPoint(self, point)
            % Move the robot's end-effector to a specified 3D point
            q0 = zeros(1,6); % Initial joint configuration
            T = transl(point); % Desired end-effector position
            q_sol = self.robot.ikcon(T, q0); % Compute inverse kinematics
            self.robot.plot(q_sol, 'workspace', [-5 5 -5 5 0 5], ...
                'nojoints', 'noname', 'noshadow', 'nowrist', 'delay', 0);
        end
    end
end
