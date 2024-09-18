% Movement.m

classdef Movement < handle
    properties
        feederRobot   % Instance of the feeder robot (Omron TM5)
        weldingRobot  % Instance of the welding robot (Underwater Welder)
        hAxes         % Handle to the axes for plotting
    end
    methods
        function self = Movement(feederRobot, weldingRobot, hAxes)
            % Constructor to initialize the robots and axes
            self.feederRobot = feederRobot;
            self.weldingRobot = weldingRobot;
            if nargin < 3
                self.hAxes = gca;
            else
                self.hAxes = hAxes;
            end
        end

        function synchronizeRobots(self, weldingPoints)
            % weldingPoints: Nx3 matrix of 3D coordinates for the welding path

            for i = 1:size(weldingPoints, 1)
                point = weldingPoints(i, :);

                % Move the feeder robot to supply material at the point
                q0_feeder = zeros(1,6); % Initial joint configuration
                T_feeder = transl(point);
                qFeeder = self.feederRobot.robot.ikcon(T_feeder, q0_feeder);

                % Move the welding robot to perform welding at the point
                q0_welder = zeros(1,6); % Initial joint configuration
                T_welder = transl(point);
                qWelder = self.weldingRobot.robot.ikcon(T_welder, q0_welder);

                % Check for collisions
                if self.checkCollision(qFeeder, qWelder)
                    % Visualize the robots together in the same axes
                    cla(self.hAxes); % Clear the axes
                    hold(self.hAxes, 'on');

                    % It's important not to re-plot the environment here if it's static
                    % Plot the feeder robot
                    self.feederRobot.robot.plot(qFeeder, 'workspace', [-5 5 -5 5 0 5], 'parent', self.hAxes, 'nojoints', 'noname', 'noshadow', 'nowrist');

                    % Plot the welding robot
                    self.weldingRobot.robot.plot(qWelder, 'workspace', [-5 5 -5 5 0 5], 'parent', self.hAxes, 'nojoints', 'noname', 'noshadow', 'nowrist');

                    title(self.hAxes, ['Synchronized Robots at Point ', num2str(i)]);
                    hold(self.hAxes, 'off');
                    drawnow;
                else
                    warning('Potential collision detected at point %d. Skipping this movement.', i);
                end

                % Pause for visualization
                pause(1); % Adjust the pause duration as needed
            end
        end

        function safe = checkCollision(self, qFeeder, qWelder)
            % Check for collisions between the two robots
            % qFeeder and qWelder are the joint configurations of the robots

            % Currently, collision detection is not implemented
            % Replace this placeholder with actual collision detection code if available

            % Placeholder: Assume no collision
            isCollision = false;

            % Return whether it's safe to proceed
            safe = ~isCollision;
        end
    end
end
