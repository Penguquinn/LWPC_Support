% ---------------------------------------------------------
% Generate points a fixed distance from a start lat/lon
% ---------------------------------------------------------
function [lat_out, lon_out] = pad( ...
    lat0, lon0, dist_km, angle_min, angle_max, angle_step)
% Inputs
lat1_deg = lat0;%44.633;     % starting latitude (degrees)
lon1_deg = lon0;%-67.283;   % starting longitude (degrees)
d = dist_km;%4000;              % distance from start (km)
R = 6371;            % Earth radius (km)

% Convert to radians
lat1 = deg2rad(lat1_deg);
lon1 = deg2rad(lon1_deg);

% Bearings from 0 to 360 degrees
bearings_deg = angle_min:angle_step:angle_max;
theta = deg2rad(bearings_deg);

% Preallocate output arrays
lat2 = zeros(size(theta));
lon2 = zeros(size(theta));

% Loop over bearings
for i = 1:length(theta)
    % Destination latitude
    lat2(i) = asin( ...
        sin(lat1) * cos(d / R) + ...
        cos(lat1) * sin(d / R) * cos(theta(i)) ...
    );

    % Destination longitude
    lon2(i) = lon1 + atan2( ...
        sin(theta(i)) * sin(d / R) * cos(lat1), ...
        cos(d / R) - sin(lat1) * sin(lat2(i)) ...
    );
end

% Convert results back to degrees
lat2_deg = rad2deg(lat2);
lon2_deg = rad2deg(lon2);


[lat_out,lon_out] = bound_lat(lat2_deg,lon2_deg);

% Plot the circle
% figure;
% geoplot(lat2_deg, lon2_deg, 'b-');
% hold on;
% geoplot(lat1_deg, lon1_deg, 'ro', 'MarkerFaceColor', 'r');
% xlabel('Longitude (deg)');
% ylabel('Latitude (deg)');
% title(sprintf('Points %d km from Start Location', d));
% grid on;
% axis equal;

end
function [lat_out,lon_out] = bound_lat(lat_in,lon_in)
    for ii = 1:length(lat_in)
        if(abs(lat_in(ii)) > 90)
        lat_out(ii) = sign(lat_in(ii))*(90-abs(mod(lat_in(ii),90)));
        lon_out(ii) = wrapTo360(lon_in(ii)+180);
        
        else
        lat_out(ii) = lat_in(ii);
        lon_out(ii) = lon_in(ii);
        end
    end
end