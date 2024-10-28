classdef SteelPlate < RobotBaseClass
    %% OmronTM5700
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

%% Create the robot model
        function CreateModel(self)
            L1 = Link('d', 0.1, 'a', 0, 'alpha', 0);
            
            % Incorporate joint limits
            L1.qlim = 0;  
        
            L1.offset = pi/2;
            
            self.model = SerialLink([L1], 'name', 'Omron TM5');
        end
    end
end