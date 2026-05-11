%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%            The Givens             %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
clear all;
clc;

angle_step = 1;
dist_max = 10000;
angle_min = 230;
angle_max = 270;
freak = 24;
paths = 'C:\LWPCwin\';
% cleanup(0);
clean_w(1);
hprime = 75; %65:1:80;
beta = .4; %.3:.1:0.6;
h_0 = 120;%80:2:100;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%        Build Profile files        %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tagsm = angle_min:angle_step:angle_max;
filenames = prf_exp(paths,hprime,beta);



% for ii=1:numel(filenames)
TXdata = 'NAA240';
% end
disp("Finished PRF")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%        Build input files          %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xmtr_loc = [44.633,67.283]; % NAA, Cutler
% xmtr_loc = [46.366   98.336]; % NLK, Jim Creek
rxvr_loc = [32.466224, 85.470938]; % Auburn
% rxvr_loc = [62.567234209170635, 144.66236353401382]; % Chistochina
% rxvr_loc = [41.945013, 72.727013]; % East Granby

% path_len = distance(rxvr_loc(1),rxvr_loc(2),xmtr_loc(1),xmtr_loc(2),'degrees');
% path_len = deg2km(path_len);
load("trainTrax.mat")

redux_factor = 5;
idx_redux = 1:redux_factor:numel(routeCoords)/2;

rxvr_lat = routeCoords(idx_redux,1);
rxvr_lon = -routeCoords(idx_redux,2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Run list of lwpc commands      %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parfor ii = 1:length(rxvr_lon)
    basename_inp = sprintf('%d',ii);
    fid = fopen([paths basename_inp '.inp'],'w');
    fprintf(fid,['case-id     AU Prop\n']);
    fprintf(fid,['tx          ' basename_inp '\n']);
    fprintf(fid,['tx-data      ' TXdata '\n']);
        %% next line needs filepath fixed
    fprintf(fid,[sprintf('ionosphere  homogeneous table ./%s.prf\n',filenames{1})]);
    fprintf(fid,['range-max   2200.0\n']);
    fprintf(fid,[sprintf('receivers     %f   %f\n',rxvr_lat(ii),rxvr_lon(ii))]);
    fprintf(fid,['mc-options  full-wave 0 true\n']);
    fprintf(fid,['lwflds\n']);
    fprintf(fid,['print-mds   0\n']);
    fprintf(fid,['print-wf    2\n']);
    fprintf(fid,['print-lwf   2\n']);
    fprintf(fid,['print-swg   2\n']);
    fprintf(fid,['print-mc    1\n']);
    fprintf(fid,['start\n']);
    fprintf(fid,['quit']);
    fclose(fid);

    [status, cmdout] = RunLWPC([basename_inp]);

    try
    [s0{ii},s1{ii},s2{ii},s3{ii},hx{ii},hy{ii}] = ...
        lw_vs_d_function(paths,basename_inp,freak,dist_max);
    catch
        % disp(sprintf("error at %d %d %d", ii, jj, kk))
        s0_c{ii} = NaN(1001,1);
        s1_c{ii} = NaN(1001,1);
        s2_c{ii} = NaN(1001,1);
        s3_c{ii} = NaN(1001,1);
        hx{ii} = NaN(1001,1);
        hy{ii} = NaN(1001,1);
    end

end
% clean_w(0);
disp("Finished RUN")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GIF with 4-panel subplot
% Panel 1: path between two coordinate sets
% Panels 2-4: placeholders for your own plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% GIF setup

gif_name = 'path_animation.gif';

figure('Color','w')
set(gcf,'Position',[100 100 1200 800])

%% Animation loop


N = length(rxvr_lon);



for kk = 1:N

    s1n = s1{kk} ./ s0{kk};
    s2n = s2{kk} ./ s0{kk};
    s3n = s3{kk} ./ s0{kk};

    clf

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SUBPLOT 1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    subplot(2,2,1)

    geoplot([xmtr_loc(1),rxvr_lat(kk)],[-xmtr_loc(2),rxvr_lon(kk)])

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SUBPLOT 2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    subplot(2,2,2)

    title('Your Plot 2')
    grid on
    hold on

    plot(s1n)
    plot(s2n)
    plot(s3n)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SUBPLOT 3
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    subplot(2,2,3)

    title('Your Plot 3')
    grid on
    hold on

    plot(10*log10(abs(hx{kk})))
    plot(10*log10(abs(hy{kk})))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SUBPLOT 4
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    subplot(2,2,4)

    title('Your Plot 4')
    grid on
    hold on

    % Example placeholder
    plot(10*log10(abs(s1n)))
    plot(10*log10(abs(s2n)))
    plot(10*log10(abs(s3n)))

    drawnow

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Write frame to GIF
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    frame = getframe(gcf);
    im = frame2im(frame);

    [A,map] = rgb2ind(im,256);

    if kk == 1
        imwrite(A,map,gif_name,...
            'gif',...
            'LoopCount',Inf,...
            'DelayTime',0.05);
    else
        imwrite(A,map,gif_name,...
            'gif',...
            'WriteMode','append',...
            'DelayTime',0.05);
    end

end

disp('GIF complete')




