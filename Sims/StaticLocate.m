%% Load Data


naa = load('C:\Users\qdh0004\OneDrive - Auburn University\Desktop\nb_polarization\CH240815013000NAA_001.mat');
nlk = load('C:\Users\qdh0004\OneDrive - Auburn University\Desktop\nb_polarization\CH240815013000NLK_001.mat');
nlm = load('C:\Users\qdh0004\OneDrive - Auburn University\Desktop\nb_polarization\CH240815013000NLM_001.mat');
npm = load('C:\Users\qdh0004\OneDrive - Auburn University\Desktop\nb_polarization\CH240815013000NPM_001.mat');


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
chistochina = [62.561760, -144.647490];


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
true_bear_naa = azimuth(chistochina(1),chistochina(2),cutler(1),cutler(2));
true_bear_npm = azimuth(chistochina(1),chistochina(2),lua(1),lua(2));
true_bear_nlk = azimuth(chistochina(1),chistochina(2),jimk(1),jimk(2));
true_bear_nlm = azimuth(chistochina(1),chistochina(2),lam(1),lam(2));






%% normalize everything

naas = {naa.s0,naa.s1./naa.s0,naa.s2./naa.s0,naa.s3./naa.s0};

nlks = {nlk.s0,nlk.s1./nlk.s0,nlk.s2./nlk.s0,nlk.s3./nlk.s0};

nlms = {nlm.s0,nlm.s1./nlm.s0,nlm.s2./nlm.s0,nlm.s3./nlm.s0};

npms = {npm.s0,npm.s1./npm.s0,npm.s2./npm.s0,npm.s3./npm.s0};




%% determine angles 
naa_ang = mod(180 - (0.5 * atan2d(naas{3}, naas{2})), 360) -180+21;

nlk_ang = mod(180 - (0.5 * atan2d(nlks{3}, nlks{2})), 360) -180+21;

nlm_ang = mod(180 - (0.5 * atan2d(nlms{3}, nlms{2})), 360) -180+21;

npm_ang = mod(180 - (0.5 * atan2d(npms{3}, npms{2})), 360) -180+21;

% calibration values
cali_naa = mod(180+mean(naa_ang(1:100)),180) - true_bear_naa;
cali_nlk = mod(180+mean(nlk_ang(1:100)),180) - true_bear_nlk;
cali_nlm = mod(180+mean(nlm_ang(1:100)),180) - true_bear_nlm;
cali_npm = mod(180+mean(npm_ang(1:100)),180) - true_bear_npm;
cali_npm = mod(-1* cali_npm,180);
%% find first guess coords

min_num = 20;

figure;
gx = geoaxes;
hold(gx,'on');
[~,bb] = mink(abs(azm_grid_naa(:) - mod((naa_ang(1) - cali_naa),180)),min_num);
[rr,cc] = ind2sub(size(azm_grid_naa),bb);


[naa_guess_lat,sort_idx] = sort(lat_grid(rr));
naa_guess_lon = lon_grid(1,cc);
naa_guess_lon = naa_guess_lon(sort_idx);

geoplot(gx,naa_guess_lat,naa_guess_lon)

[~,bb] = mink(abs(azm_grid_nlk(:) - mod((nlk_ang(1) - cali_nlk),180)),min_num);
[rr,cc] = ind2sub(size(azm_grid_nlk),bb);


[nlk_guess_lat,sort_idx] = sort(lat_grid(rr));
nlk_guess_lon = lon_grid(1,cc);
nlk_guess_lon = nlk_guess_lon(sort_idx);

geoplot(gx,nlk_guess_lat,nlk_guess_lon)

[~,bb] = mink(abs(azm_grid_nlm(:) - mod((nlm_ang(1) ),180)),min_num);
[rr,cc] = ind2sub(size(azm_grid_nlm),bb);


[nlm_guess_lat,sort_idx] = sort(lat_grid(rr));
nlm_guess_lon = lon_grid(1,cc);
nlm_guess_lon = nlm_guess_lon(sort_idx);

geoplot(gx,nlm_guess_lat,nlm_guess_lon)


[~,bb] = mink(abs(azm_grid_npm(:) - mod((npm_ang(1) +14),360)),min_num);
[rr,cc] = ind2sub(size(azm_grid_npm),bb);


[npm_guess_lat,sort_idx] = sort(lat_grid(rr));
npm_guess_lon = lon_grid(1,cc);
npm_guess_lon = npm_guess_lon(sort_idx);

geoplot(gx,npm_guess_lat,npm_guess_lon)


% - cali_npm  - cali_nlm




%% reckon great circle paths



tbnaa = azimuth(chistochina(1),chistochina(2),cutler(1),cutler(2));




range = linspace(0,2*6371*pi,1000);
range = km2deg(range,"earth");

figure;
gx = geoaxes;
hold(gx,"on");

[gsp_lat,gsp_lon] = reckon(cutler(1),cutler(2),range,mod(90-(naa_ang(1)-cali_naa),360)+127);
[gsp_lon,II] = sort(gsp_lon);
gsp_lat = gsp_lat(II);
geoplot(gsp_lat,gsp_lon)


[gsp_lat,gsp_lon] = reckon(jimk(1),jimk(2),range,nlk_ang(1)-cali_nlk);
[gsp_lon,II] = sort(gsp_lon);
gsp_lat = gsp_lat(II);
geoplot(gsp_lat,gsp_lon)


[gsp_lat,gsp_lon] = reckon(lam(1),lam(2),range,nlm_ang(1)-cali_nlm);
[gsp_lon,II] = sort(gsp_lon);
gsp_lat = gsp_lat(II);
geoplot(gsp_lat,gsp_lon)


[gsp_lat,gsp_lon] = reckon(lua(1),lua(2),range,npm_ang(1)-cali_npm);
[gsp_lon,II] = sort(gsp_lon);
gsp_lat = gsp_lat(II);
geoplot(gsp_lat,gsp_lon)


legend('cutler','jim creek','la moure','lualualei')





%% find convergent place
% [gsp_lat,gsp_lon] = reckon(sav_lat,sav_lon,range,azm_grid_naa(rr,cc));
% [gsp_lon,II] = sort(gsp_lon);
% gsp_lat = gsp_lat(II);
% geoplot(gsp_lat,gsp_lon)



%% map
