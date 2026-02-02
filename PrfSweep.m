%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%            The Givens             %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% close all;
% clear all;
% clc;

angle_step = 0.1;
dist_max = 4000;
angle_min = 230;
angle_max = 270;
freak = 24;
output_path = filepathing_wsl();

cleanup(0);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Make a list of files to run    %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tagsm = angle_min:angle_step:angle_max;
filenames = LWPC_profile_maker_en();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%        build input files          %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%xmtr_loc = [44.633,-67.283];
xmtr_loc = [46.366   -98.336];

rxvr_loc = [32.466224, -85.470938];

parfor ii = 1:numel(filenames)
    fid = fopen([filepathing_wsl(),filenames{ii},'.inp'],'w+');
%    fprintf(fid,['FILE-MDS ./mds/',newline]);
%    fprintf(fid,['FILE-LWF ./lwf/',newline]);
    fprintf(fid,['CASE-ID  Prop of wave at %d kHz to %d %d ',newline],freak,rxvr_loc(1),rxvr_loc(2));
    fprintf(fid,['TX    %s',newline],filenames{ii});
    fprintf(fid,['TX-DATA    NAA240',newline]);
    fprintf(fid,['IONOSPHERE   HOMOGENEOUS TABLE /home/quinn/work/v3.0.1/profile/%s.prf',newline],filenames{ii});
    fprintf(fid,['RANGE-MAX    %d',newline], dist_max);
    fprintf(fid,['RECEIVERS   %f   %f',newline],rxvr_loc(1),rxvr_loc(2));
    fprintf(fid,['LWF-VS-DIST 20000',newline]);
    fprintf(fid,['MC-OPTIONS  FULL-WAVE 0 TRUE',newline]);
    fprintf(fid,['LWFIELDS',newline]);
    fprintf(fid,['PRINT-MDS    0',newline]);
    fprintf(fid,['PRINT-WF    2',newline]);
    fprintf(fid,['PRINT-LWF    2',newline]);
    fprintf(fid,['PRINT-SWG    2',newline]);
    fprintf(fid,['PRINT-MC    1',newline]);
    fprintf(fid,['START',newline]);
    fprintf(fid,['QUIT',newline]);
    fclose(fid);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%        build Profile files        %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Run list of lwpc commands      %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parfor ii = 1:numel(filenames)
[status, cmdout] = RunLWPC(filenames{ii});
end
cleanup(0)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Read Outputs into .mat files   %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ii = 1:size(filenames,2)
    try
    [s0_c{ii},s1_c{ii},s2_c{ii},s3_c{ii}, hx{ii},hy{ii}] = ...
        lw_vs_d_function(output_path,filenames{ii},freak,dist_max);
    catch
        s0_c{ii} = NaN(1001,1);
        s1_c{ii} = NaN(1001,1);
        s2_c{ii} = NaN(1001,1);
        s3_c{ii} = NaN(1001,1);
        hx{ii} = NaN(1001,1);
        hy{ii} = NaN(1001,1);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%              Plotting             %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curhp = 75:.1:85;
gifFile = 'stokes_evolution_prf_sweep.gif';
delayTime = 0.1;   % seconds between frames
dist_vec = (dist_max/length(s0_c{1}))*(1:length(s0_c{1}));
fg = figure('Color','w');
theme(fg,"light")

for ii = 1:length(s0_c)

    clf;  % clear figure for next frame

    % -------- Subplot 1 -------- %
    subplot(2,2,1)
    geoplot([xmtr_loc(1),rxvr_loc(1)],[xmtr_loc(2),rxvr_loc(2)])
    geolimits([10 50], [-115 -60])
    title('Prop from NLM to AU')

    % -------- Subplot 2 -------- %
    subplot(2,2,2)
    plot(dist_vec, s1_c{ii}./s0_c{ii}); hold on
    plot(dist_vec, s2_c{ii}./s0_c{ii});
    plot(dist_vec, s3_c{ii}./s0_c{ii});
    yline(0)
    xline(1880);
    title('Stokes parameters normalized by S_0')
    xlabel('Distance from transmitter (km)')
    ylabel('Normalized magnitude')
    legend('S_1 (Q)','S_2 (U)','S_3 (V)','Location','northeast')
    xlim([0 4000])
    ylim([-1 1])

    % -------- Subplot 3 -------- %
    subplot(2,2,3)
    plot(dist_vec,10*log10(abs(hx{ii}))); hold on
    plot(dist_vec,10*log10(abs(hy{ii})))
    %plot(dist_vec,10*log10(abs(s2_c{ii})))
    %plot(dist_vec,10*log10(abs(s3_c{ii})))
    xline(1880);
    title('Amplitude Hx and Hy')
    xlabel('Distance from transmitter (km)')
    ylabel('Amplitude (dB)')
    legend('Hx','Hy','Location','northeast')
    xlim([0 4000])
    ylim([-20 60])

    % -------- Subplot 4 -------- %
    subplot(2,2,4)
    plot(dist_vec,20*log10(abs(s1_c{ii}./s0_c{ii}))); hold on
    plot(dist_vec,20*log10(abs(s2_c{ii}./s0_c{ii})))
    plot(dist_vec,20*log10(abs(s3_c{ii}./s0_c{ii})))
    xline(1880);
    title('Stokes parameters normalized by S_0, log scale')
    xlabel('Distance from transmitter (km)')
    ylabel('Amplitude (dB)')
    legend('S_1 (Q)','S_2 (U)','S_3 (V)','Location','northeast')
    xlim([0 4000])
    ylim([-120 0])

    sgtitle(sprintf("Sweep of h` from 70 to 90 (%f)",curhp(ii)))
    drawnow

    % -------- Capture frame --------
    frame = getframe(gcf);
    im = frame2im(frame);
    [imind, cm] = rgb2ind(im, 256);

    % -------- Write to GIF --------
    if ii == 1
        imwrite(imind, cm, gifFile, 'gif', ...
                'Loopcount', inf, 'DelayTime', delayTime);
    else
        imwrite(imind, cm, gifFile, 'gif', ...
                'WriteMode', 'append', 'DelayTime', delayTime);
    end
end