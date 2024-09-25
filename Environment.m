classdef Environment < handle
    properties
        NX      % Size in X direction
        NY      % Size in Y direction
        NZ      % Height of the environment (Z direction)
        texture % Texture image data
    end
    
    methods
        function self = Environment(NX, NY, NZ)
            % Constructor for the Environment class
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
            
            % Load the texture image
            self.texture = imread('water.png');
            
            % Create a new figure and plot environment when instantiated
            figure;
            hAxes = gca;  % Get current axes
            self.plotEnvironment(hAxes);
        end
        
        function plotEnvironment(self, hAxes)
            % Plot the floor with the texture in the specified axes
            if nargin < 2
                hAxes = gca; % Use current axes
            end
            % Create a grid for the floor
            x = linspace(-self.NX/2, self.NX/2, 2);
            y = linspace(-self.NY/2, self.NY/2, 2);
            [X, Y] = meshgrid(x, y);
            Z = zeros(size(X)); % Floor at Z = 0
            
            % Plot the surface for the floor with texture mapping
            surface('XData', X, 'YData', Y, 'ZData', Z, ...
                'CData', self.texture, 'FaceColor', 'texturemap', ...
                'EdgeColor', 'none', 'Parent', hAxes);
            
            % Plot the selected two walls
            % Wall 2: Along Y-axis at X = NX/2
            [Y, Z] = meshgrid(linspace(-self.NY/2, self.NY/2, 2), linspace(0, self.NZ, 2));
            X = self.NX/2 * ones(size(Y));
            surface('XData', X, 'YData', Y, 'ZData', Z, ...
                'CData', self.texture, 'FaceColor', 'texturemap', ...
                'EdgeColor', 'none', 'Parent', hAxes);
            
            % Wall 4: Along X-axis at Y = NY/2
            [X, Z] = meshgrid(linspace(-self.NX/2, self.NX/2, 2), linspace(0, self.NZ, 2));
            Y = self.NY/2 * ones(size(X));
            surface('XData', X, 'YData', Y, 'ZData', Z, ...
                'CData', self.texture, 'FaceColor', 'texturemap', ...
                'EdgeColor', 'none', 'Parent', hAxes);
            
            % Plot the ceiling
            Z = self.NZ * ones(size(X));
            surface('XData', X, 'YData', Y, 'ZData', Z, ...
                'CData', self.texture, 'FaceColor', 'texturemap', ...
                'EdgeColor', 'none', 'Parent', hAxes);
            
            % Set the axes limits and labels
            xlim(hAxes, [-self.NX/2, self.NX/2]);
            ylim(hAxes, [-self.NY/2, self.NY/2]);
            zlim(hAxes, [0 self.NZ]);  % Set Z-axis limits from 0 to NZ
            xlabel(hAxes, 'X (m)');
            ylabel(hAxes, 'Y (m)');
            zlabel(hAxes, 'Z (m)');
            view(hAxes, 3);
            grid(hAxes, 'on');
        end
    end
end