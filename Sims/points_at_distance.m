function [lat_out, lon_out] = points_at_distance( ...
    lat0, lon0, dist_km, angle_min, angle_max, angle_step)
% POINTS_AT_DISTANCE
% Finds lat/lon points at a fixed distance from a starting coordinate
% within specified bearing bounds.
%
% Inputs:
%   lat0, lon0   - starting latitude & longitude (degrees)
%   dist_km      - distance from start (km)
%   angle_min    - minimum bearing (degrees)
%   angle_max    - maximum bearing (degrees)
%   angle_step   - step size for bearings (degrees)
%
% Outputs:
%   lat_out      - latitudes of resulting points (degrees)
%   lon_out      - longitudes of resulting points (degrees)
%   bearings     - bearings used (degrees)
    
    lon0 = lon0 * -1;
    dist_deg = km2deg(dist_km);
    circ = [dist_deg*cosd((angle_min:angle_step:angle_max))./2; dist_deg*sind((angle_min:angle_step:angle_max))];
    lat_out = lat0 + circ(1,:);
    lon_out = lon0 + circ(2,:);

    [lat_out,lon_out] = bound_lat(lat_out,lon_out);
    
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