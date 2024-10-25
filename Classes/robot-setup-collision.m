classdef RobotSetupAndCollision < handle
    properties
        feederRobot      % OmronTM5700 robot
        welderRobot      % WelderRobot
        environment      % Environment
        isEstopped       % Emergency stop status
        collisionThreshold = 0.1  % Minimum distance (meters) between robots
    end
    
    methods
        function self = RobotSetupAndCollision()
            self.isEstopped = false;
            
            % Initialize environment
            self.environment = Environment();
            
            % Initialize robots with offset base transforms
            feederBaseTr = transl(-0.5, 0, 0);  % Position feeder robot 0.5m to the left
            self.feederRobot = OmronTM5700(feederBaseTr);
            
            welderBaseTr = transl(0.5, 0, 0);   % Position welder robot 0.5m to the right
            self.welderRobot = WelderRobot(welderBaseTr);
            
            % Set initial poses
            self.setInitialPoses();
        end
        
        function setInitialPoses(self)
            % Set safe initial joint configurations
            feederInitQ = [0, -pi/4, 0, -pi/4, 0, 0, 0];
            welderInitQ = [0, pi/4, 0, pi/4, 0, 0, 0];
            
            self.feederRobot.model.animate(feederInitQ);
            self.welderRobot.model.animate(welderInitQ);
        end
        
        function checkCollision(self)
            % Get current end-effector positions
            feederPos = self.feederRobot.model.fkine(self.feederRobot.model.getpos()).t;
            welderPos = self.welderRobot.model.fkine(self.welderRobot.model.getpos()).t;
            
            % Check distance between end-effectors
            distance = norm(feederPos - welderPos);
            
            if distance < self.collisionThreshold
                self.emergencyStop();
            end
        end
        
        function emergencyStop(self)
            self.isEstopped = true;
            warning('Emergency Stop Triggered! Collision Risk Detected');
            % Stop all robot movements
            self.feederRobot.model.animate(self.feederRobot.model.getpos());
            self.welderRobot.model.animate(self.welderRobot.model.getpos());
        end
        
        function success = moveRobotsToPoint(self, targetPoint, offset)
            % Move robots to coordinated positions with offset
            if self.isEstopped
                warning('System is E-Stopped. Reset required before movement.');
                success = false;
                return;
            end
            
            % Calculate offset positions for each robot
            feederTarget = targetPoint - [offset/2, 0, 0];
            welderTarget = targetPoint + [offset/2, 0, 0];
            
            % Plan and execute movements
            try
                % Move robots step by step
                steps = 50;
                for i = 1:steps
                    % Get current positions
                    feederCurrentQ = self.feederRobot.model.getpos();
                    welderCurrentQ = self.welderRobot.model.getpos();
                    
                    % Calculate next positions
                    feederTr = transl(feederTarget);
                    welderTr = transl(welderTarget);
                    
                    feederNextQ = self.feederRobot.model.ikcon(feederTr, feederCurrentQ);
                    welderNextQ = self.welderRobot.model.ikcon(welderTr, welderCurrentQ);
                    
                    % Interpolate movement
                    s = (i-1)/(steps-1);
                    feederQ = (1-s)*feederCurrentQ + s*feederNextQ;
                    welderQ = (1-s)*welderCurrentQ + s*welderNextQ;
                    
                    % Move robots
                    self.feederRobot.model.animate(feederQ);
                    self.welderRobot.model.animate(welderQ);
                    
                    % Check for collisions
                    self.checkCollision();
                    
                    if self.isEstopped
                        success = false;
                        return;
                    end
                    
                    drawnow();
                    pause(0.1);  % Add delay for visualization
                end
                success = true;
            catch
                warning('Movement failed - target may be unreachable');
                success = false;
            end
        end
        
        function reset(self)
            % Reset E-Stop and return robots to initial positions
            self.isEstopped = false;
            self.setInitialPoses();
        end
    end
end
