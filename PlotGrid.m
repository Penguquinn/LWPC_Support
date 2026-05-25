% Example azimuth matrix (same size as Lat/Lon)
% azm must be degrees clockwise from north
% Example:
% azm = rand(size(Lat))*360;

% Vector length (degrees for display)
L = 0.2;

% Compute vector endpoints
Lat2 = mod(lat_grid + L .* cosd(azm_grid_naa),90);
Lon2 = lon_grid + L .* sind(azm_grid_naa);

% Create geoaxes
gx = geoaxes;
hold(gx,'on')

% Plot vectors
for k = 1:numel(lat_grid)

    geoplot(gx, ...
        [lat_grid(k) lon_grid(k)], ...
        [Lat2(k) Lon2(k)], ...
        'r-');

end

% Plot grid points
geoscatter(gx, lat_grid_naa(:), lon_grid_naa(:), 5, 'b', 'filled')

geobasemap(gx,'streets')
title(gx,'Azimuth Vector Field')