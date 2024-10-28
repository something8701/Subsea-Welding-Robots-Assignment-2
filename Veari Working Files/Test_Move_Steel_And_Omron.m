% Initialize the OmronTM5700
        feederRobot = OmronTM5700([eye(4)],2);    % Instantiate the feeder robot - At origin
                                                  % Plots steel plate
    % Initialize the welderRS Robot
        BaseTr = eye(4) * transl(0.3,0,0);
        welderRobot = WelderRobot(BaseTr);  % Instantiate the welder robot - At (0.35, 0, 0)

        % Position to pickup
            feederRobot.OmronMove_FinalQInput([pi/2 0 0 0 0 0 0]);
                pause(1);
            feederRobot.OmronMove_FinalQInput([pi/2 0 0 0 (-pi/2) 0 0]);
                pause(1);
            feederRobot.Omron_MoveToCartesian_Down([-0.35 0 0.3]);
                pause(1);
            feederRobot.Omron_MoveToCartesian_Down([-0.35 0 0]);
                pause(1);

         % Picksup steel plate then moves to default position
            feederRobot.OmronAndSteel_MoveToCartesian_Down([-0.35 0 0.3]);
                pause(1);
            feederRobot.OmronAndSteelMove_FinalQInput([pi/2 0 0 0 (-pi/2) 0 0]);
                pause(1);
            feederRobot.OmronAndSteelMove_FinalQInput([0 0 0 0 (-pi/2) 0 0]);
                pause(1);

         % Moves steel plate to wall
            feederRobot.OmronAndSteel_MoveToCartesian_Wall([0.2 0.4 0.8]);
                pause(1);
            feederRobot.OmronAndSteel_MoveToCartesian_Wall([0.2 0.5 0.8]);
                pause(2);