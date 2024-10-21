classdef SteelPlate < RobotBaseClass
    %% SteelPlate
    properties(Access = public)              
        plyFileNameStem = 'SteelPlate';
    end
    
    methods
%% Define robot Function 
        function self = SteelPlate(baseTr)
			self.CreateModel();
            if nargin < 1			
				baseTr = eye(4);				
            end
            self.model.base = self.model.base.T * baseTr;
            self.PlotAndColourRobot();  
        end

%% Create the SteelPlate model
        function CreateModel(self)

            L1 = Link('d', 1, 'a', 0, 'alpha', pi/2);
            
            self.model = SerialLink([L1], 'name', 'Steel Plate');
        end

    %%  Fkine function
        % function SteelPlateFkine(self,q)
        %     if nargin < 2
        %             q = [0 0 0 0 0 0 0];
        %     end
        %     SteelPlatePose = self.model.fkine(q) %#ok<NOPRT,NASGU>
        % end

    %% Move SteelPlate function
    % function SteelPlateMoveToCartesian(self,FinalCartesian)
    %         % 
    %         if nargin < 2
    %             FinalCartesian = [-0.5, 0, 0];    % Default state
    %         end
    %         % Get initial pos
    %             initialq = self.model.getpos;
    %         % Get final transform
    %             finalTr = transl(FinalCartesian) * rpy2tr(0, 0, 0, 'deg');
    %         % Use inverse kinematics to find q - joint angles for target coordinates. 
    %             finalq = self.model.ikcon(finalTr,initialq);
    %         % Calculate using Trapezoidal Velocity Profile
    %             steps = 35;
    %             s = lspb(0,1,steps);
    %             qMatrix = nan(steps, 7);        % 50 by 7 matrix with NaN
    %             for i = 1:steps
    %                 qMatrix(i,:) = ((1-s(i))*initialq) + (s(i)*finalq);
    %             end
    %         % Animate movement to pickup zone
    %         for i = 1:10:steps
    %             self.model.animate(qMatrix(i,:));
    %             drawnow();
    %         end
    % end

    %% Move SteelPlate Base Location
    % function SteelPlateMoveBase(self,FinalCartesian)
    %     % 
    %         if nargin < 2
    %             FinalCartesian = [-0.5, -0.5, 0.1];    % Default state
    %         end
    %         self.model.base = self.model.base.T * transl(FinalCartesian);
    %         self.PlotAndColourRobot();
    % end

    end
end