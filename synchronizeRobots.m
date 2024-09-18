function synchronizeRobots(self, weldingPoints)
    % weldingPoints: Nx3 matrix of 3D coordinates for the welding path

    % Initial joint configurations (starting positions)
    q0_feeder = zeros(1, 6); % Feeder robot initial configuration
    q0_ams = zeros(1, 6); % AMS robot initial configuration

    % Loop through each point on the welding path
    for i = 1:size(weldingPoints, 1) - 1
        % Current and next point on the welding path
        point_curr = weldingPoints(i, :);
        point_next = weldingPoints(i + 1, :);

        % Inverse kinematics for feeder robot
        T_feeder_curr = transl(point_curr);
        T_feeder_next = transl(point_next);
        qFeeder_curr = self.feederRobot.robot.ikcon(T_feeder_curr, q0_feeder);
        qFeeder_next = self.feederRobot.robot.ikcon(T_feeder_next, qFeeder_curr);

        % Inverse kinematics for AMS robot
        T_ams_curr = transl(point_curr);
        T_ams_next = transl(point_next);
        qAms_curr = self.amsFeederRobot.robot.ikcon(T_ams_curr, q0_ams);
        qAms_next = self.amsFeederRobot.robot.ikcon(T_ams_next, qAms_curr);

        % Define the number of steps for smooth transition between points
        numSteps = 100;
        qFeeder_steps = jtraj(qFeeder_curr, qFeeder_next, numSteps);
        qAms_steps = jtraj(qAms_curr, qAms_next, numSteps);

        % Move both robots simultaneously in small increments
        for step = 1:numSteps
            % Plot the feeder robot
            self.feederRobot.robot.plot(qFeeder_steps(step, :), 'workspace', [-5 5 -5 5 0 5], 'nojoints', 'noname', 'noshadow', 'nowrist');
            
            % Plot the AMS robot
            self.amsFeederRobot.robot.plot(qAms_steps(step, :), 'workspace', [-5 5 -5 5 0 5], 'nojoints', 'noname', 'noshadow', 'nowrist');

            % Add a very short pause to allow visualization
            drawnow;
        end

        % Update the initial configuration for the next iteration
        q0_feeder = qFeeder_next;
        q0_ams = qAms_next;
    end
end
