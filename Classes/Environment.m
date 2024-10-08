% Environment.m

classdef Environment < handle
    properties
        NX           % Size in X direction
        NY           % Size in Y direction
        NZ           % Height of the environment (Z direction)
        texture      % Texture image data for walls and ceiling
        sand         % Sand texture image data for the floor
        welderModel  % Property to store the welder model
    end
    
    methods
        % Constructor for the Environment class
        function self = Environment(NX, NY, NZ)
            if nargin < 1
                NX = 10; % Default size
            end
            if nargin < 2
                NY = NX; % Make the environment square if NY not provided
            end
            if nargin < 3
                NZ = 5;  % Default height
            end
            self.NX = NX;
            self.NY = NY;
            self.NZ = NZ;
            
            % Load the texture images
            self.texture = imread('Data/water.png');  % For walls and ceiling
            self.sand = imread('Data/sand.png');      % For floor

            % Initialize welderModel as empty
            self.welderModel = [];  % Added this line to initialize welderModel

            % Create a new figure and plot environment when instantiated
            figure;
            hAxes = gca;  % Get current axes
            self.plotEnvironment(hAxes);
            
            % Adjust the camera view to see all walls
            view(3);      % Set 3D view
            axis equal;   % Maintain aspect ratio
        end
        
        function plotEnvironment(self, hAxes)
            if nargin < 2
                hAxes = gca;
            end
            
            % Plot the floor
            x = linspace(-self.NX/2, self.NX/2, 2);
            y = linspace(-self.NY/2, self.NY/2, 2);
            [X, Y] = meshgrid(x, y);
            Z = zeros(size(X)); % Floor at Z = 0
            
            % Plot the floor with the sand texture
            surface('XData', X, 'YData', Y, 'ZData', Z, ...
                'CData', self.sand, 'FaceColor', 'texturemap', ...
                'EdgeColor', 'none', 'Parent', hAxes);

            % Plot the selected two walls
            % Wall 2: Along Y-axis at X = NX/2
            [Y_wall, Z_wall] = meshgrid(linspace(-self.NY/2, self.NY/2, 2), linspace(0, self.NZ, 2));
            X_wall = self.NX/2 * ones(size(Y_wall));
            surface('XData', X_wall, 'YData', Y_wall, 'ZData', Z_wall, ...
                'CData', self.texture, 'FaceColor', 'texturemap', ...
                'EdgeColor', 'none', 'Parent', hAxes);
            
            % Wall 4: Along X-axis at Y = NY/2
            [X_wall, Z_wall] = meshgrid(linspace(-self.NX/2, self.NX/2, 2), linspace(0, self.NZ, 2));
            Y_wall = self.NY/2 * ones(size(X_wall));
            surface('XData', X_wall, 'YData', Y_wall, 'ZData', Z_wall, ...
                'CData', self.texture, 'FaceColor', 'texturemap', ...
                'EdgeColor', 'none', 'Parent', hAxes);
            
            % Plot the ceiling
            Z_ceil = self.NZ * ones(size(X_wall));
            surface('XData', X_wall, 'YData', Y_wall, 'ZData', Z_ceil, ...
                'CData', self.texture, 'FaceColor', 'texturemap', ...
                'EdgeColor', 'none', 'Parent', hAxes);
            
            % Set the axes limits and labels
            xlim(hAxes, [-self.NX/2, self.NX/2]);
            ylim(hAxes, [-self.NY/2, self.NY/2]);
            zlim(hAxes, [0, self.NZ]);  % Set Z-axis limits from 0 to NZ
            xlabel(hAxes, 'X (m)');
            ylabel(hAxes, 'Y (m)');
            zlabel(hAxes, 'Z (m)');
            
            % Enable grid and hold the plot
            grid(hAxes, 'on');
            hold on;
        end
    end
end
