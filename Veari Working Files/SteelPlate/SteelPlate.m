classdef SteelPlate < handle
    % STEELPLATE A class that creates a steel plate object
    % The steel plate can be plotted at a specific location.
    
    properties
        %> A steel plate model
        steelplateModel;
        
        %> Base pose for the steel plate
        basePose;
    end
    
    methods
        %% Constructor
        function self = SteelPlate(base)
            if nargin < 1			
				base = [0 0 0];				
            end
            % Set the base location for the steel plate
                self.basePose = SE3(SE2(base(1), base(2), 0));
                self.steelplateModel = self.GetPlateModel('SteelPlate');

            % Plot the steel plate model at the specified base location
                self.Plot();
        end
        
        function delete(self)
            handles = findobj('Tag', self.steelplateModel.name);
            h = get(handles, 'UserData');
            try delete(h.robot); end
            try delete(h); end
            try delete(handles); end
        end
        
        %% Plot the steel plate
        function Plot(self)
            plot3d(self.steelplateModel, 0, 'base', self.basePose, 'noarrow');
            hold on;
            axis equal
            if isempty(findobj(get(gca, 'Children'), 'Type', 'Light'))
                camlight;
            end
        end
    end
    
    methods (Static)
        %% GetPlateModel
        function model = GetPlateModel(name)
            if nargin < 1
                name = 'SteelPlate';
            end
            [faceData, vertexData] = plyread('SteelPlateLink0.ply', 'tri');
            model = SerialLink(Link('alpha', pi/2, 'a', 0, 'd', 0.1, 'offset', 0), 'name', name);
            model.faces = {[], faceData};
            model.points = {[], vertexData};
        end
    end
end