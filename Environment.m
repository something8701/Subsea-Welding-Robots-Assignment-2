% Environment.m

classdef Environment < handle
    properties
        NX      % Size in X direction
        NY      % Size in Y direction
        texture % Texture image data
    end
    
    methods
        function self = Environment(NX, NY)
            % Constructor for the Environment class
            if nargin < 1
                NX = 10; % Default size
            end
            if nargin < 2
                NY = NX; % Make the environment square if NY not provided
            end
            self.NX = NX;
            self.NY = NY;
            
            % Load the texture image
            self.texture = imread('water.png');
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
            
            % Plot the surface with texture mapping
            surface('XData', X, 'YData', Y, 'ZData', Z, ...
                'CData', self.texture, 'FaceColor', 'texturemap', ...
                'EdgeColor', 'none', 'Parent', hAxes);
            
            % Set the axes limits and labels
            xlim(hAxes, [-self.NX/2, self.NX/2]);
            ylim(hAxes, [-self.NY/2, self.NY/2]);
            zlim(hAxes, [0 5]);  % Set Z-axis limits from 0 to 5
            xlabel(hAxes, 'X (m)');
            ylabel(hAxes, 'Y (m)');
            zlabel(hAxes, 'Z (m)');
            view(hAxes, 3);
            grid(hAxes, 'on');
        end
    end
end
