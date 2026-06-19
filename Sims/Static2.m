%% Load Data


naa = load('C:\VLF_data\NB\AU_Pol\AU230622180000NAA_001.mat');
nlk = load('C:\VLF_data\NB\AU_Pol\AU230622180000NLK_001.mat');
nlm = load('C:\VLF_data\NB\AU_Pol\AU230622180000NLM_001.mat');
npm = load('C:\VLF_data\NB\AU_Pol\AU230622180000NPM_001.mat');


% naa = load('C:\VLF_data\NB\2023_01_01\AU230101000504NAA_004A.mat');
% nlk = load('C:\VLF_data\NB\2023_01_01\AU230101000504NLK_004A.mat');
% nlm = load('C:\VLF_data\NB\2023_01_01\AU230101000504NLM_004A.mat');
% npm = load('C:\VLF_data\NB\2023_01_01\AU230101000504NPM_004A.mat');


%% Make Grid for each

% Latitude and longitude limits
lat_vals = 0:0.1:90;
lon_vals = -180:0.2:0;

% Create 2D coordinate grids
[lon_grid, lat_grid] = meshgrid(lon_vals, lat_vals);

clear lat_vals lon _vals;

% rxvr loc for "calibration"
%chistochina = [62.561760, -144.647490];
AU = [32.466212, -85.470926];

% mag_dec at rxvr
decl = -1.6;


% Locations of xmtrs

cutler = [44.637479, -67.278594];
lua = [21.429708, -158.160890];
lam = [46.365933, -98.335640];
jimk = [48.203059, -121.917135];

azm_grid_naa = azimuth(lat_grid,lon_grid,cutler(1),cutler(2));
azm_grid_nlk = azimuth(lat_grid,lon_grid,jimk(1),jimk(2));
azm_grid_nlm = azimuth(lat_grid,lon_grid,lam(1),lam(2));
azm_grid_npm = azimuth(lat_grid,lon_grid,lua(1),lua(2));

% true azim values for calibration
true_bear_naa = azimuth(AU(1),AU(2),cutler(1),cutler(2));
true_bear_npm = azimuth(AU(1),AU(2),lua(1),lua(2));
true_bear_nlk = azimuth(AU(1),AU(2),jimk(1),jimk(2));
true_bear_nlm = azimuth(AU(1),AU(2),lam(1),lam(2));






%% normalize everything

naas = {naa.s0,naa.s1./naa.s0,naa.s2./naa.s0,naa.s3./naa.s0};

nlks = {nlk.s0,nlk.s1./nlk.s0,nlk.s2./nlk.s0,nlk.s3./nlk.s0};

nlms = {nlm.s0,nlm.s1./nlm.s0,nlm.s2./nlm.s0,nlm.s3./nlm.s0};

npms = {npm.s0,npm.s1./npm.s0,npm.s2./npm.s0,npm.s3./npm.s0};




%% determine angles 
naa_ang = mod(180 - (0.5 * atan2d(naas{3}, naas{2})), 360) -180+decl;

nlk_ang = mod(180 - (0.5 * atan2d(nlks{3}, nlks{2})), 360) -180+decl;

nlm_ang = mod(180 - (0.5 * atan2d(nlms{3}, nlms{2})), 360) -180+decl;

npm_ang = mod(180 - (0.5 * atan2d(npms{3}, npms{2})), 360) -180+decl;


naa_ang = 360 - mod(naa_ang,360);
nlk_ang = 360 - mod(nlk_ang,360);
nlm_ang = 360 - mod(nlm_ang,360);
npm_ang = 360 - mod(npm_ang,360);



% calibration values
% cali_naa = mod(mean(naa_ang(1:100)),180) - true_bear_naa;
% cali_nlk = mod(mean(nlk_ang(1:100)),180) - true_bear_nlk;
% cali_nlm = mod(mean(nlm_ang(1:100)),180) - true_bear_nlm;
% cali_npm = mod(mean(npm_ang(1:100)),180) - true_bear_npm;


cali_naa = abs(mean(naa_ang(1:100)) - true_bear_naa);
cali_nlk = abs(mean(nlk_ang(1:100)) - true_bear_nlk);
cali_nlm = abs(mean(nlm_ang(1:100)) - true_bear_nlm);
cali_npm = abs(mean(npm_ang(1:100)) - true_bear_npm);


if cali_naa <0 
    cali_naa = 360 - mod(cali_naa,360);
end
if cali_nlk <0 
    cali_nlk = mod(cali_nlk,360);
end
if cali_nlm <0 
    cali_nlm = 360 - mod(cali_nlm,360);
end
if cali_npm <0 
    cali_npm = 360 - mod(cali_npm,360);
end

% cali_nlk = 52.1;
% cali_nlm = 135.2;

%% Find error in angles



error_grid_naa = abs(azm_grid_naa - naa_ang(1) - cali_naa/2);
error_grid_naa = mod(error_grid_naa,180);



error_grid_nlk = abs(azm_grid_nlk - nlk_ang(1) - cali_nlk/2);%;
error_grid_nlk = mod(error_grid_nlk+(360+cali_nlk),180);



error_grid_nlm = abs(azm_grid_nlm - nlm_ang(1) - cali_nlm/2);
error_grid_nlm = mod(error_grid_nlm+90,180);




error_grid_npm = abs(azm_grid_npm - npm_ang(1)- cali_npm/2);
error_grid_npm = mod(error_grid_npm,180);


eg_sum =  error_grid_nlm + error_grid_nlk + error_grid_naa - 180;
% error_grid_npm +
geoscatter(lat_grid(:),lon_grid(:),20,abs(eg_sum(:)),'filled')

subplot(2,2,1)
geoscatter(lat_grid(:),lon_grid(:),20,abs(error_grid_naa(:)),'filled')
subplot(2,2,2)
geoscatter(lat_grid(:),lon_grid(:),20,abs(error_grid_nlk(:)),'filled')
subplot(2,2,3)
geoscatter(lat_grid(:),lon_grid(:),20,abs(error_grid_nlm(:)),'filled')
subplot(2,2,4)
geoscatter(lat_grid(:),lon_grid(:),20,abs(error_grid_npm(:)),'filled')




figure;

cont_naa = getCont(lat_grid,lon_grid,error_grid_naa);
cont_nlm = getCont(lat_grid,lon_grid,error_grid_nlm);
cont_nlk = getCont(lat_grid,lon_grid,error_grid_nlk);
cont_npm = getCont(lat_grid,lon_grid,error_grid_npm);

gx = geoaxes;
hold(gx,'on');

geoscatter(cont_naa(:,1),cont_naa(:,2))
geoscatter(cont_nlm(:,1),cont_nlm(:,2))
geoscatter(cont_nlk(:,1),cont_nlk(:,2))
geoscatter(cont_npm(:,1),cont_npm(:,2))





% contour1, contour2, contour3
% format: [lat lon]

% ---- Pairwise nearest intersections ----

[idx12,d12] = knnsearch(cont_nlk, cont_naa);
pts12 = (cont_naa + cont_nlk(idx12,:))/2;

[idx13,d13] = knnsearch(cont_nlm, cont_naa);
pts13 = (cont_naa + cont_nlm(idx13,:))/2;

[idx23,d23] = knnsearch(cont_nlm, cont_nlk);
pts23 = (cont_nlk + cont_nlm(idx23,:))/2;

% ---- Keep only close matches ----

tol = 1; % degrees

good12 = d12 < tol;
good13 = d13 < tol;
good23 = d23 < tol;

candidatePts = [
    pts12(good12,:);
    pts13(good13,:);
    pts23(good23,:)
];

% ---- Estimated overlap location ----

overlapPoint = mean(candidatePts,1);

lat_est = overlapPoint(1);
lon_est = overlapPoint(2);

fprintf('Estimated overlap:\n');
fprintf('Latitude:  %.4f\n', lat_est);
fprintf('Longitude: %.4f\n', lon_est);

geoscatter(gx, lat_est, lon_est, ...
           200, 'r', '*', ...
           'LineWidth', 2);




























function coords = getCont(lat_grid,lon_grid,error_grid)
% Build contours
C = contourc(lon_grid(1,:), ...
    lat_grid(:,1), ...
    error_grid, ...
    [-0.1 0.1]);

% Extract contour matrix
% C = h.ContourMatrix;

% C is the contour matrix returned by contour/contourc

coords = [];

k = 1;

while k < size(C,2)

    % Number of points in this contour segment
    npts = C(2,k);

    % Indices of contour coordinates
    idx = k + (1:npts);

    % Extract coordinates
    x = C(1,idx)';
    y = C(2,idx)';

    % Append to master list
    coords = [coords; [y, x]];

    % Move to next contour block
    k = k + npts + 1;
end
end