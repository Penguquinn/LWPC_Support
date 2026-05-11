%% RAILWAY ROUTE EXTRACTION + GRAPH ROUTING (ONE SCRIPT)
% Requires: Mapping Toolbox (recommended but not strictly required)

clear; clc; close all;

%% =========================
% 1. DEFINE START/END POINTS
%% =========================

startLatLon = [39.0997,-94.5786];   % example: Montgomery, AL
endLatLon   = [47.6062, -122.3321];   % adjust as needed

bbox = [36.80, -130.90, 48, -94.25];   % [S W N E]

%% =========================
% 2. DOWNLOAD RAILWAY DATA (FIXED)
%% =========================

query = sprintf([
    '[out:json];' ...
    '(' ...
    'way["railway"="rail"](%f,%f,%f,%f);' ...
    ');' ...
    'out geom;'
], bbox(1), bbox(2), bbox(3), bbox(4));

url = "https://overpass-api.de/api/interpreter";

options = weboptions( ...
    'MediaType','application/x-www-form-urlencoded', ...
    'Timeout', 60);

disp("Downloading OpenStreetMap railway data...");

response = webwrite(url, "data=" + query, options);

% response is already a struct → NO jsondecode needed
data = response;
ways = data.elements;

%% =========================
% 3. PARSE COORDINATES
%% =========================

nodeMap = containers.Map('KeyType','char','ValueType','double');

nodes = [];
edgesS = [];
edgesT = [];

nodeID = 1;

disp("Building graph...");

for k = 1:length(ways)

    if isfield(ways(k),'geometry')

        geom = ways(k).geometry;

        for i = 1:length(geom)-1

            p1 = [geom(i).lat geom(i).lon];
            p2 = [geom(i+1).lat geom(i+1).lon];

            key1 = sprintf('%.7f,%.7f', p1);
            key2 = sprintf('%.7f,%.7f', p2);

            if ~isKey(nodeMap, key1)
                nodeMap(key1) = nodeID;
                nodes(nodeID,:) = p1;
                nodeID = nodeID + 1;
            end

            if ~isKey(nodeMap, key2)
                nodeMap(key2) = nodeID;
                nodes(nodeID,:) = p2;
                nodeID = nodeID + 1;
            end

            edgesS(end+1) = nodeMap(key1);
            edgesT(end+1) = nodeMap(key2);

        end
    end
end

G = graph(edgesS, edgesT);

%% =========================
% 4. SNAP START / END TO GRAPH
%% =========================

disp("Snapping to nearest railway nodes...");

distStart = vecnorm(nodes - startLatLon, 2, 2);
[~, startNode] = min(distStart);

distEnd = vecnorm(nodes - endLatLon, 2, 2);
[~, endNode] = min(distEnd);

%% =========================
% 5. COMPUTE SHORTEST ROUTE
%% =========================

disp("Computing route...");

pathNodes = shortestpath(G, startNode, endNode);

routeCoords = nodes(pathNodes,:);

%% =========================
% 6. OUTPUT RESULTS
%% =========================

disp("Route coordinates (lat, lon):");
disp(routeCoords);

%% =========================
% 7. PLOT RESULT (FIXED GEO MAP)
%% =========================

figure;

gx = geoaxes;
hold(gx, 'on');

% --- full rail network (gray dots)
geoplot(gx, nodes(:,1), nodes(:,2), '.', ...
    'Color', [0.7 0.7 0.7]);

% --- route (red line)
geoplot(gx, routeCoords(:,1), routeCoords(:,2), ...
    'r-', 'LineWidth', 2);

% --- start point (green)
geoplot(gx, startLatLon(1), startLatLon(2), ...
    'go', 'MarkerSize', 10, 'LineWidth', 2);

% --- end point (blue)
geoplot(gx, endLatLon(1), endLatLon(2), ...
    'bo', 'MarkerSize', 10, 'LineWidth', 2);

% --- basemap for context
geobasemap(gx, 'streets');

title(gx, 'Railway Route from OpenStreetMap');

legend(gx, ...
    'Rail network', ...
    'Route', ...
    'Start', ...
    'End', ...
    'Location', 'bestoutside');

hold(gx, 'off');

%% DONE
disp("Done.");

%% =========================
% DONE
%% =========================
disp("Done.");