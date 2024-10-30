classdef Movement_Synchronise < handle
    properties
        feederRobot   % Instance of the feeder robot (Omron TM5)
        welderRobot   % Instance of the welder robot (was AMSFeeder, now welderRS)
        hAxes         % Handle to the axes for plotting
    end
    methods
        function self = Movement_Synchronise()
            % Constructor to initialize the robots and axes
                if nargin < 3
                    self.hAxes = gca;
                else
                    self.hAxes = hAxes;
                end
            % Place ROV
                ROV = PlaceObject('ROV.PLY',[0,-0.2,0]);
                verts = [get(ROV,'Vertices'), ones(size(get(ROV,'Vertices'),1),1)];
                set(ROV,'Vertices',verts(:,1:3))
                hold on;

            % Initialize the OmronTM5700
                oBaseTr = transl(0,0,0.5);
                self.feederRobot = OmronTM5700(oBaseTr,2);    % Instantiate the feeder robot - At origin
                                                         % Plots steel plate (Case 2)
            % Initialize the welderRS Robot
                wBaseTr = transl(0.3,0,0.5);
                self.welderRobot = WelderRobot(wBaseTr);        % Instantiate the welder robot - At (0.35, 0, 0)
            
            self.OmronAndWelder_Move([pi/2 0 0 0 0 (pi/2) 0],[-pi/2 pi/4 pi/4 0 pi/2 0 0]);
            self.OmronAndWelder_Move([pi/2 0 (-pi/2) 0 (-pi/2) (pi/2) 0],[0 0 0 0 0 0 0]);
            self.OmronAndWelder_Move([pi/2 0 0 0 (-pi/2) (pi/2) 0],[0 deg2rad(-45) deg2rad(-45) 0 pi/2 0 0]);
            self.OmronAndWelder_Move([(-pi/2) 0 0 0 0 (-pi/2) 0],[0 0 0 0 0 0 0]);

            input('Press enter to end synchronous motion')
        end

        % % Method for moving the end-effector in a straight line with delay
        function OmronAndWelder_Move(self,Omron_Q,Welder_Q)
            % Animate movement to pickup zone
                for i = 1:4:50
                    Omron_qMatrix = self.feederRobot.Omron_Move(Omron_Q);
                    Welder_qMatrix = self.welderRobot.Welder_Move(Welder_Q);
                    % Step 
                        self.feederRobot.model.animate(Omron_qMatrix(i,:));
                        self.welderRobot.model.animate(Welder_qMatrix(i,:));
                    drawnow();
                    % Slow it down
                        pause(0.1);
                end
        end
    end
end