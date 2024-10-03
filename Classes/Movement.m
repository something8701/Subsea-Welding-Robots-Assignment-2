classdef Movement < handle
    properties
        feederRobot   % Instance of the feeder robot (Omron TM5)
        welderRobot   % Instance of the welder robot (was AMSFeeder, now welderRS)
        hAxes         % Handle to the axes for plotting
    end
    methods
        function self = Movement(feederRobot, welderRobot, hAxes)
            % Constructor to initialize the robots and axes
            self.feederRobot = feederRobot;
            self.welderRobot = welderRobot;
            if nargin < 3
                self.hAxes = gca;
            else
                self.hAxes = hAxes;
            end
        end

        % Method for moving the end-effector in a straight line with delay
        function moveStraightLine(self, startPoint, endPoint, delayPerStep)
            % Initialize start and end transformation matrices
            T_start = transl(startPoint);  % Transformation for the start position
            T_end = transl(endPoint);      % Transformation for the end position

            % Get the current position (joint states)
            q0_feeder = self.feederRobot.robot.getpos();
            q0_welder = self.welderRobot.robot.getpos();

            % Inverse kinematics for the start and end points
            qFeeder_start = self.feederRobot.robot.ikcon(T_start, q0_feeder);
            qFeeder_end = self.feederRobot.robot.ikcon(T_end, qFeeder_start);

            qWelder_start = self.welderRobot.robot.ikcon(T_start, q0_welder);
            qWelder_end = self.welderRobot.robot.ikcon(T_end, qWelder_start);

            % Define steps for smooth movement
            numSteps = 50;
            qFeeder_steps = jtraj(qFeeder_start, qFeeder_end, numSteps);
            qWelder_steps = jtraj(qWelder_start, qWelder_end, numSteps);

            % Execute straight-line motion for both robots
            for step = 1:numSteps
                % Plot the feeder robot
                self.feederRobot.robot.plot(qFeeder_steps(step, :), 'workspace', [-5 5 -5 5 0 5], 'nojoints', 'noname', 'noshadow', 'nowrist');
                
                % Plot the welder robot
                self.welderRobot.robot.plot(qWelder_steps(step, :), 'workspace', [-5 5 -5 5 0 5], 'nojoints', 'noname', 'noshadow', 'nowrist');

                % Add delay for slowing down the movement
                pause(delayPerStep);
            end
        end
    end
end
