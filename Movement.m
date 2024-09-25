classdef Movement < handle
    properties
        feederRobot   % Instance of the feeder robot (Omron TM5)
        amsFeederRobot  % Instance of the AMS feeder robot
        hAxes         % Handle to the axes for plotting
    end
    methods
        function self = Movement(feederRobot, amsFeederRobot, hAxes)
            % Constructor to initialize the robots and axes
            self.feederRobot = feederRobot;
            self.amsFeederRobot = amsFeederRobot;
            if nargin < 3
                self.hAxes = gca;
            else
                self.hAxes = hAxes;
            end
        end

        function synchronizeRobots(self, weldingPoints)
            % Updated method for smooth synchronized motion between points

            % Initial joint configurations
            q0_feeder = zeros(1, 6);
            q0_ams = zeros(1, 6);

            % Loop through the points
            for i = 1:size(weldingPoints, 1) - 1
                point_curr = weldingPoints(i, :);
                point_next = weldingPoints(i + 1, :);

                % Inverse kinematics for current and next point
                T_feeder_curr = transl(point_curr);
                T_feeder_next = transl(point_next);
                qFeeder_curr = self.feederRobot.robot.ikcon(T_feeder_curr, q0_feeder);
                qFeeder_next = self.feederRobot.robot.ikcon(T_feeder_next, qFeeder_curr);

                T_ams_curr = transl(point_curr);
                T_ams_next = transl(point_next);
                qAms_curr = self.amsFeederRobot.robot.ikcon(T_ams_curr, q0_ams);
                qAms_next = self.amsFeederRobot.robot.ikcon(T_ams_next, qAms_curr);

                % Interpolate between configurations
                numSteps = 100;
                qFeeder_steps = jtraj(qFeeder_curr, qFeeder_next, numSteps);
                qAms_steps = jtraj(qAms_curr, qAms_next, numSteps);

                % Execute smooth motion
                for step = 1:numSteps
                    self.feederRobot.robot.plot(qFeeder_steps(step, :), 'workspace', [-5 5 -5 5 0 5], 'nojoints', 'noname', 'noshadow', 'nowrist');
                    self.amsFeederRobot.robot.plot(qAms_steps(step, :), 'workspace', [-5 5 -5 5 0 5], 'nojoints', 'noname', 'noshadow', 'nowrist');
                    drawnow;
                end

                % Update for the next iteration
                q0_feeder = qFeeder_next;
                q0_ams = qAms_next;
            end
        end

        function safe = checkCollision(self, qFeeder, qAms)
            % Collision checking function (optional)
            isCollision = false; % Placeholder logic
            safe = ~isCollision;
        end
    end
end