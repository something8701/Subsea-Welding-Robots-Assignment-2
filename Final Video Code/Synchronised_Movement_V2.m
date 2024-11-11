classdef Synchronised_Movement_V2 < handle
    properties(Access = public) 
        ROV   % Instance of the ROV
        steelPlate   % Instance of the steelPlate
        feederRobot   % Instance of the feeder robot (Omron TM5)
        welderRobot   % Instance of the welder robot (was AMSFeeder, now welderRS)
        hAxes         % Handle to the axes for plotting
    end

    methods
        function self = Synchronised_Movement_V2()
            % Constructor to initialize the robots and axes
                if nargin < 3
                    self.hAxes = gca;
                else
                    self.hAxes = hAxes;
                end
        
            % Initialize the SteelPlate
                self.steelPlate = SteelPlate(1, -0.35, 0, 0.5);
        
            % Initialize the OmronTM5700
                O_BaseTr = transl(0,0,0.5);
                self.feederRobot = OmronTM5700_V2(O_BaseTr);
        
            % Initialize the welderRS Robot
                wBaseTr = transl(0.3,0,0.5);
                self.welderRobot = WelderRobot_V2(wBaseTr);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MOVE TO GIVEN Q STATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Method for moving the Welder robot on its own
        function Welder_MoveToq(self,Steps,Welder_Q)
            % Calculate joint states for path - TVP
                Welder_qMatrix = self.welderRobot.TVP_q(Steps,Welder_Q);
            % Animate movement to pickup zone
                for i = 2:2:Steps
                    % For each step - Animate at that joint state
                        self.welderRobot.model.animate(Welder_qMatrix(i,:));
                    drawnow();
                    % Slow it down
                        % pause(0.1);
                end
        end 
        function Omron_MoveToq(self,Steps,Omron_Q)
            % Calculate joint states for path
                Omron_qMatrix = self.feederRobot.TVP_q(Steps,Omron_Q);
            % Animate movement to pickup zone
                for i = 2:2:Steps
                    % For each step - Animate at that joint state
                        self.feederRobot.model.animate(Omron_qMatrix(i,:));
                    drawnow();
                    % Slow it down
                        % pause(0.1);
                end
        end
        %% Method for moving the robots simultaneously based on given final q states
        function OmronAndWelder_MoveToq(self,Steps,Omron_Q,Welder_Q)
            % Calculate joint states for path
                Omron_qMatrix = self.feederRobot.TVP_q(Steps,Omron_Q);
                Welder_qMatrix = self.welderRobot.TVP_q(Steps,Welder_Q);
                % ONLY FOR DISPLAY
                    % O_EndEffectorTr = nan(4,4,Steps);
                    % W_EndEffectorTr = nan(4,4,Steps);
                    % for i = 1:Steps
                    %     O_EndEffectorTr(:,:,i) = self.feederRobot.OmronFkine(Omron_qMatrix(i,:));
                    %     W_EndEffectorTr(:,:,i) = self.welderRobot.WelderFkine(Welder_qMatrix(i,:));
                    % end
                    % O_CartMatrix = nan(Steps,3);
                    % W_CartMatrix = nan(Steps,3);
                    % for i = 1:Steps
                    %     O_CartMatrix(i,:) = [O_EndEffectorTr(1,4,i) O_EndEffectorTr(2,4,i) O_EndEffectorTr(3,4,i)];
                    %     W_CartMatrix(i,:) = [W_EndEffectorTr(1,4,i) W_EndEffectorTr(2,4,i) W_EndEffectorTr(3,4,i)];
                    % end
                    % % Plot values for visualisation
                    %     plot_1 = plot3(O_CartMatrix(:,1),O_CartMatrix(:,2),O_CartMatrix(:,3),'r*');
                    %     plot_2 = plot3(W_CartMatrix(:,1),W_CartMatrix(:,2),W_CartMatrix(:,3),'g*');
            % Animate movement to pickup zone
                pause(1);
                for i = 2:2:Steps
                    % For each step - Animate at that joint state
                        self.feederRobot.model.animate(Omron_qMatrix(i,:));
                        self.welderRobot.model.animate(Welder_qMatrix(i,:));
                    drawnow();
                    % Slow it down
                        % pause(0.1);
                end
             % Delete
                % delete(plot_1);
                % delete(plot_2);
        end
        %% Method for moving the Omron and steel plate based on given final q states
        function OmronSteelPlate_MoveToq(self,Steps,Omron_Q)
            % Calculate joint states for path
                Omron_qMatrix = self.feederRobot.TVP_q(Steps,Omron_Q);
                EndEffectorTr = nan(4,4,Steps);
                for i = 1:Steps
                    % Run fkine once and store
                    EndEffectorTr(:,:,i) = self.feederRobot.OmronFkine([Omron_qMatrix(i,:)]);
                    % Plots the path
                        % plot = plot3(EndEffectorTr(1,4,i),EndEffectorTr(2,4,i),Welder_CartMatrix(3,4,i),'g*');
                end
            % Animate movement to pickup zone
                for i = 2:2:Steps
                    % For each step - Animate at that joint state
                        self.feederRobot.model.animate(Omron_qMatrix(i,:));
                        % Move steel to end effector pose - updating the base transformation
                            self.steelPlate.moveSteelPlate(EndEffectorTr(:,:,i));
                    drawnow();
                    % Slow it down
                        % pause(0.1);
                end
        end
        %% Method for moving the robots and steel plate simultaneously based on given final q states
        function OmronWelderSteelPlate_MoveToq(self,Steps,Omron_Q,Welder_Q)
            % Calculate joint states for path
                Omron_qMatrix = self.feederRobot.TVP_q(Steps,Omron_Q);
                Welder_qMatrix = self.welderRobot.TVP_q(Steps,Welder_Q);
                EndEffectorTr = nan(4,4,Steps);
                for i = 1:Steps
                    % Run fkine once and store
                    EndEffectorTr(:,:,i) = self.feederRobot.OmronFkine([Omron_qMatrix(i,:)]);
                    % Plots the path
                        % plot = plot3(EndEffectorTr(1,4,i),EndEffectorTr(2,4,i),Welder_CartMatrix(3,4,i),'g*');
                end
            % Animate movement to pickup zone
                for i = 2:2:Steps
                    % For each step - Animate at that joint state
                        self.welderRobot.model.animate(Welder_qMatrix(i,:));
                        self.feederRobot.model.animate(Omron_qMatrix(i,:));
                        % Move steel to end effector pose - updating the base transformation
                            self.steelPlate.moveSteelPlate(EndEffectorTr(:,:,i));
                    drawnow();
                    % Slow it down
                        % pause(0.1);
                end
            % Delete plot
                % delete(plot);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MOVE TO GIVEN CARTESIAN STATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Method for moving the Welder robot on its own to a cartesian coordinate
        function Welder_MoveToCart(self,Steps,Final_Cart,Roll,Pitch,Yaw)
            % Generate cartesian point matrix for path planning
                Welder_CartMatrix = self.welderRobot.TVP_Cartesian_Robot(Steps,3,Final_Cart);
                % Plots the path
                    % plot = plot3(Welder_CartMatrix(:,1),Welder_CartMatrix(:,2),Welder_CartMatrix(:,3),'g*');
            % Generate joint angles required for straight line path
                % Get initial pose
                Welder_qMatrix = nan(Steps,7);
                Welder_qMatrix(1,:) = self.welderRobot.model.getpos;
                for i = 2:Steps
                    initialq = Welder_qMatrix(i-1,:);
                    % Get and store the joint angles corresponding to the Cartesian coordinates for the straight line
                    desiredTr = transl(Welder_CartMatrix(i, :)) * rpy2tr(Roll, Pitch, Yaw, 'deg');
                    Welder_qMatrix(i,:) = self.welderRobot.model.ikcon(desiredTr, initialq);
                end
            % Animate movement to pickup zone
                for i = 2:2:Steps
                    % For each step - Animate at that joint state
                        self.welderRobot.model.animate(Welder_qMatrix(i,:));
                    drawnow();
                    % Slow it down
                        % pause(0.1);
                end
            % Delete plot
                % delete(plot);
        end
        %% Method for moving the Omron/Feeder robot on its own to a cartesian coordinate
        function Omron_MoveToCart(self,Steps,Final_Cart,Roll,Pitch,Yaw)
            % Generate cartesian point matrix for path planning
                Feeder_CartMatrix = self.feederRobot.TVP_Cartesian_Robot(Steps,3,Final_Cart);
                % Plots the path
                    %plot = plot3(Feeder_CartMatrix(:,1),Feeder_CartMatrix(:,2),Feeder_CartMatrix(:,3),'g*');
            % Generate joint angles required for straight line path
                % Get initial pose
                Feeder_qMatrix = nan(Steps,7);
                Feeder_qMatrix(1,:) = self.feederRobot.model.getpos;
                for i = 2:Steps
                    initialq = Feeder_qMatrix(i-1,:);
                    % Get and store the joint angles corresponding to the Cartesian coordinates for the straight line
                    desiredTr = transl(Feeder_CartMatrix(i, :)) * rpy2tr(Roll, Pitch, Yaw, 'deg');
                    Feeder_qMatrix(i,:) = self.feederRobot.model.ikcon(desiredTr, initialq);
                end
            % Animate movement to pickup zone
                for i = 2:2:Steps
                    % For each step - Animate at that joint state
                        self.feederRobot.model.animate(Feeder_qMatrix(i,:));
                    drawnow();
                    % Slow it down
                        % pause(0.1);
                end
            % Delete plot
                %delete(plot);
        end
        % %% Method for moving the robots simultaneously based on given final q states
        function OmronAndWelder_MoveToCart(self,Steps,O_Final_Cart,W_Final_Cart,ORoll,OPitch,OYaw,WRoll,WPitch,WYaw)
            % Generate cartesian point matrix for path planning
                Feeder_CartMatrix = self.feederRobot.TVP_Cartesian_Robot(Steps,3,O_Final_Cart);
                Welder_CartMatrix = self.welderRobot.TVP_Cartesian_Robot(Steps,3,W_Final_Cart);
                % Plots the path
                    plot_1 = plot3(Feeder_CartMatrix(:,1),Feeder_CartMatrix(:,2),Feeder_CartMatrix(:,3),'r*');
                    plot_2 = plot3(Welder_CartMatrix(:,1),Welder_CartMatrix(:,2),Welder_CartMatrix(:,3),'g*');
            % Generate joint angles required for straight line path
                % Get initial pose
                Feeder_qMatrix = nan(Steps,7);
                Feeder_qMatrix(1,:) = self.feederRobot.model.getpos;
                Welder_qMatrix = nan(Steps,7);
                Welder_qMatrix(1,:) = self.welderRobot.model.getpos;
                for i = 2:Steps
                    initialq_O = Feeder_qMatrix(i-1,:);
                    initialq_W = Welder_qMatrix(i-1,:);
                    % Get and store the joint angles corresponding to the Cartesian coordinates for the straight line
                    desiredTr_O = transl(Feeder_CartMatrix(i, :)) * rpy2tr(ORoll, OPitch, OYaw, 'deg');
                    Feeder_qMatrix(i,:) = self.feederRobot.model.ikcon(desiredTr_O, initialq_O);
                    % Get and store the joint angles corresponding to the Cartesian coordinates for the straight line
                    desiredTr_W = transl(Welder_CartMatrix(i, :)) * rpy2tr(WRoll, WPitch, WYaw, 'deg');
                    Welder_qMatrix(i,:) = self.welderRobot.model.ikcon(desiredTr_W, initialq_W);
                end
            % Animate movement to pickup zone
                pause(1);
                for i = 2:2:Steps
                    % For each step - Animate at that joint state
                        self.feederRobot.model.animate(Feeder_qMatrix(i,:));
                        self.welderRobot.model.animate(Welder_qMatrix(i,:));
                    drawnow();
                    % Slow it down
                        % pause(0.1);
                end
            delete(plot_1);
            delete(plot_2);
        end
        %% Method for moving the Omron and steel plate based on given final q states
        function OmronSteelPlate_MoveToCart(self,Steps,Final_Cart,Roll,Pitch,Yaw)
            % Generate cartesian point matrix for path planning
                Feeder_CartMatrix = self.feederRobot.TVP_Cartesian_Robot(Steps,3,Final_Cart);
                % Plots the path
                    % plot = plot3(Feeder_CartMatrix(:,1),Feeder_CartMatrix(:,2),Feeder_CartMatrix(:,3),'g*');
            % Generate joint angles required for straight line path
                % Get initial pose
                Feeder_qMatrix = nan(Steps,7);
                Feeder_qMatrix(1,:) = self.feederRobot.model.getpos;
                for i = 2:Steps
                    initialq = Feeder_qMatrix(i-1,:);
                    % Get and store the joint angles corresponding to the Cartesian coordinates for the straight line
                    desiredTr = transl(Feeder_CartMatrix(i, :)) * rpy2tr(Roll, Pitch, Yaw, 'deg');
                    Feeder_qMatrix(i,:) = self.feederRobot.model.ikcon(desiredTr, initialq);
                end
            % Generate Omron end effector transform for each feeder joint state
                EndEffectorTr = nan(4,4,Steps);
                for i = 1:Steps
                    % Run fkine once and store
                    EndEffectorTr(:,:,i) = self.feederRobot.OmronFkine([Feeder_qMatrix(i,:)]);
                end
            % Animate movement to pickup zone
                for i = 2:2:Steps
                    % For each step - Animate at that joint state
                        self.feederRobot.model.animate(Feeder_qMatrix(i,:));
                        % Move steel to end effector pose - updating the base transformation
                            self.steelPlate.moveSteelPlate(EndEffectorTr(:,:,i));
                    drawnow();
                    % Slow it down
                        % pause(0.1);
                end
            % Delete plot
                % delete(plot);
        end
        % %% Method for moving the robots and steel plate simultaneously based on given final q states
        % function OmronWelderSteelPlate_MoveToCart(self,Steps,Omron_Q,Welder_Q)
        %     % Calculate joint states for path
        %         Omron_qMatrix = self.feederRobot.TVP_q(Steps,Omron_Q);
        %         Welder_qMatrix = self.welderRobot.TVP_q(Steps,Welder_Q);
        %         EndEffectorTr = nan(4,4,Steps);
        %         for i = 1:Steps
        %             % Run fkine once and store
        %             EndEffectorTr(:,:,i) = self.feederRobot.OmronFkine([Omron_qMatrix(i,:)]);
        %             % size(EndEffectorTr(:,:,i))
        %         end
        %     % Animate movement to pickup zone
        %         for i = 2:2:Steps
        %             % For each step - Animate at that joint state
        %                 self.welderRobot.model.animate(Welder_qMatrix(i,:));
        %                 self.feederRobot.model.animate(Omron_qMatrix(i,:));
        %                 % Move steel to end effector pose - updating the base transformation
        %                     self.steelPlate.moveSteelPlate(EndEffectorTr(:,:,i));
        %             drawnow();
        %             % Slow it down
        %                 % pause(0.1);
        %         end
        % end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MOVE TO ROBOT BASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Move Omron function - Move Omron Base
        function Omron_MoveBase(self,Steps, Final_Cart)
                % 
                if nargin < 2
                    Final_Cart = [0, 0, 0];    % Default base
                end
                % Get initial pose
                    initialq = self.feederRobot.model.getpos;
                % Calculate the straight-line path in Cartesian space
                    CartesianMatrix = self.feederRobot.TVP_Cartesian_Base(Steps, 3, Final_Cart); 
                % Animate movement to move base
                for i = 2:2:Steps
                    % set new base
                        self.feederRobot.model.base = transl(CartesianMatrix(i, :));
                    % plot
                        self.feederRobot.model.animate(initialq);
                    drawnow();
                    % Slow it down for testing
                        % pause(0.1);
                end
        end
        %% Move Omron function - Move Omron Base
        function Welder_MoveBase(self,Steps, Final_Cart)
                % 
                if nargin < 2
                    Final_Cart = [0, 0, 0];    % Default base
                end
                % Get initial pose
                    initialq = self.welderRobot.model.getpos;
                % Calculate the straight-line path in Cartesian space
                    CartesianMatrix = self.welderRobot.TVP_Cartesian_Base(Steps, 3, Final_Cart); 
                % Animate movement to move base
                for i = 2:2:Steps
                    % set new base
                        self.welderRobot.model.base = transl(CartesianMatrix(i, :));
                    % plot
                        self.welderRobot.model.animate(initialq);
                    drawnow();
                    % Slow it down for testing
                        % pause(0.1);
                end
        end
    end
end