load('trainTrax.mat');
lat = routeCoords(idx_redux,1);
lon = routeCoords(idx_redux,2);

% Compute headings between consecutive reduced points
heading = azimuth(lat(1:end-1), lon(1:end-1), ...
                  lat(2:end),   lon(2:end));

heading = mod(heading,360);
heading = [heading;heading(end)];

% % Vector length
% L = 0.05;
% 
% % Vector endpoints
% lat2 = lat(1:end-1) + L .* cosd(heading);
% lon2 = lon(1:end-1) + L .* sind(heading);
% 
% figure
% geoplot(lat, lon, 'b-', 'LineWidth', 2)
% hold on
% 
% for k = 1:length(heading)
%     geoplot([lat(k) lat2(k)], ...
%             [lon(k) lon2(k)], ...
%             'r-', 'LineWidth', 2)
% end
% 
% geobasemap streets
% title('Heading Vectors')

dst_ref = 0:10:1000;
% [1,0,0,1]
xmtrs = {'NAA240','NML252','NLK248','NPM214'};
xlocs = [[44.633,67.283];[46.366, 98.336];[48.204, 121.917];[21.420, 158.151]];

for ii = 1:numel(xmtrs)
    
    to_xmtr = azimuth(lat,lon,xlocs(ii,1),xlocs(ii,2));
    off_heading = mod(to_xmtr - heading + 180,360) - 180;



    load(['trainStokes_5redux_',xmtrs{ii},'.mat']);
    dst_to_track{ii} = distance(lat,lon,xlocs(ii,1),-xlocs(ii,2));
    dst_gsp = deg2km(dst_to_track{ii});
    for kk = 1:length(s0)
        [~, idx_path] = min(abs(dst_ref - dst_gsp(kk)));
        s0l(kk) = s0{kk}(idx_path);
        s1l(kk) = s1{kk}(idx_path)./s0l(kk);
        s2l(kk) = s2{kk}(idx_path)./s0l(kk);
        s3l(kk) = s3{kk}(idx_path)./s0l(kk);
        rs1(kk) = (s1l(kk) * cosd(off_heading(kk))) + (s2l(kk)*sind(off_heading(kk)));
        rs2(kk) = (-s1l(kk) * cosd(off_heading(kk))) + (s2l(kk)*sind(off_heading(kk)));
    end
    
    final_s1{ii} = rs1;
    final_s2{ii} = rs2;
    final_s3{ii} = s3l;

end


% figure;
% geoplot(routeCoords(:,1),routeCoords(:,2))





figure;

sgtitle("Stokes Parameters as Measured Aboard a Train En Route From Kansas City to Seattle with Homogeneous Exponential Ionosphere H\prime = 75 \beta = .4")

subplot(3,1,1)
hold on;
for ii = 1:length(xmtrs)
    plot(final_s1{ii})
end
ylim([-1,1])
legend(xmtrs)
title("S1 as Received by Perpendicular H-Field Antenna with Orientation FWD-AFT / Lateral","FontName","Times New Roman","FontSize",20)
ylabel("S1 Normalized by S0","FontSize",15,"FontName","Times New Roman")
xlabel("Index Step Along Path","FontSize",15,"FontName","Times New Roman")
xlim([0,4542])



subplot(3,1,2)
hold on;
for ii = 1:length(xmtrs)
    plot(final_s2{ii})
end
ylim([-1,1])
legend(xmtrs)
title("S2 as Received by Perpendicular H-Field Antenna with Orientation FWD-AFT / Lateral","FontName","Times New Roman","FontSize",20)
ylabel("S2 Normalized by S0","FontSize",15,"FontName","Times New Roman")
xlabel("Index Step Along Path","FontSize",15,"FontName","Times New Roman")
xlim([0,4542])


subplot(3,1,3)
hold on;
for ii = 1:length(xmtrs)
    plot(final_s3{ii})
end
ylim([-1,1])
legend(xmtrs)
title("S3 as Received by Perpendicular H-Field Antenna with Orientation FWD-AFT / Lateral","FontName","Times New Roman","FontSize",20)
ylabel("S3 Normalized by S0","FontSize",15,"FontName","Times New Roman")
xlabel("Index Step Along Path","FontSize",15,"FontName","Times New Roman")
xlim([0,4542])

figure;
gx = geoaxes;

% range = 0:20:7000;
% R = 6371; % km
% range_deg = rad2deg(range./R);


track_idx = 500;
for ii=1:length(xmtrs)
xmtr_2_track_bearings = azimuth(xlocs(ii,1),-xlocs(ii,2),lat(track_idx),lon(track_idx));
[lat_2track,lon_2track] = reckon(xlocs(ii,1),-xlocs(ii,2),linspace(0,dst_to_track{ii}(track_idx),100),xmtr_2_track_bearings);
geoplot(lat_2track,lon_2track)
hold(gx,"on");
% Plot circle marker
geoscatter(gx, xlocs(ii,1), -xlocs(ii,2), 100, 'blue', 'filled')

% Add label slightly north of point
text(gx, xlocs(ii,1) + 1, -xlocs(ii,2), xmtrs{ii}, ...
    'HorizontalAlignment','center', ...
    'FontWeight','bold')
end
geolimits(gx,[2.3408   57.3569],[ -169.0270  -36.9274])
geoplot(routeCoords(:,1),routeCoords(:,2))




