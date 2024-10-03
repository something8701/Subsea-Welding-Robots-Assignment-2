classdef Environment < handle
    properties
        NX      % Size in X direction
        NY      % Size in Y direction
        NZ      % Height of the environment (Z direction)
        texture % Texture image data
        welderModel  % Property for the welder model
    end
    
    methods
        function self = Environment(NX, NY, NZ)
            if nargin < 1
                NX = 10;
            end
            if nargin < 2
                NY = NX;
            end
            if nargin < 3
                NZ = 5;
            end
            self.NX = NX;
            self.NY = NY;
            self.NZ = NZ;
            
            % Load the texture image
            self.texture = imread('water.png');
            
            % Create a new figure and plot environment when instantiated
            figure;
            hAxes = gca;
            self.plotEnvironment(hAxes);
        end
        
        function plotEnvironment(self, hAxes)
            if nargin < 2
                hAxes = gca;
            end
            
            % Plot floor and walls
            x = linspace(-self.NX/2, self.NX/2, 2);
            y = linspace(-self.NY/2, self.NY/2, 2);
            [X, Y] = meshgrid(x, y);
            Z = zeros(size(X));
            
            % Plot floor
            surface('XData', X, 'YData', Y, 'ZData', Z, ...
                'CData', self.texture, 'FaceColor', 'texturemap', ...
                'EdgeColor', 'none', 'Parent', hAxes);
            
            % Walls and ceiling are plotted as needed (refer to original code)
            
            % Visualize the welder in the environment
            if ~isempty(self.welderModel)
                hold(hAxes, 'on');
                % Plot the imported Simscape Multibody welder model
                % This function will visualize the model (modify the parameters as needed)
                smimport('welder_m.xml'); % Ensure it's imported to appear in the same figure
            end
        end
    end
end
