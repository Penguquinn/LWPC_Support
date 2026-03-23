%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%            The Givens             %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% close all;
% clear all;
% clc;

angle_step = 0.1;
dist_max = 4000;
hprime = 78.0:1:90;
beta = 0.2:0.01:.8;
h_0 = 80:1:120.0;
freak = 24;
%output_path = filepathing_wsl();
paths = '\\wsl.localhost\Ubuntu-24.04\home\quinn\work\v3.0.1\';
cleanup(0);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%        Build Profile files        %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tagsm = angle_min:angle_step:angle_max;
lwpv3_profile_maker_chapman_hprime_beta(paths, hprime, beta, h_0)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%        build input files          %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%xmtr_loc = [44.633,-67.283];
xmtr_loc = [46.366   -98.336];
rxvr_loc = [32.466224, 85.470938];

filenames = lwpv3_input_file_writer_chapman_hprime_beta(paths,hprime, beta, h_0, 'NAA', 'NAA240', rxvr_loc(1), rxvr_loc(2),'AU');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Run list of lwpc commands      %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numLoop = numel(filenames);
h = waitbar(0,'Starting...');

for ii = 1:length(filenames)
    [status, cmdout] = RunLWPC(filenames{ii});
    waitbar(ii/numLoop, h, sprintf('Processing: %d of %d\n %s', ii, numLoop,filenames{ii}));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Read Outputs into .mat files   %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numLoop = size(filenames,1)*size(filenames,2)*size(filenames,3);
h = waitbar(0,'Starting...');

for ii = 1:size(filenames,1)
    for jj = size(filenames,2)
        for kk = size(filenames,3)
            try
            [s0_c{ii,jj,kk},s1_c{ii,jj,kk},s2_c{ii,jj,kk},s3_c{ii,jj,kk}, hx{ii,jj,kk},hy{ii,jj,kk}] = ...
                lw_vs_d_function(paths,filenames{ii},freak,dist_max);
            catch
                s0_c{ii} = NaN(1001,1);
                s1_c{ii} = NaN(1001,1);
                s2_c{ii} = NaN(1001,1);
                s3_c{ii} = NaN(1001,1);
                hx{ii} = NaN(1001,1);
                hy{ii} = NaN(1001,1);
            end
            waitbar(ii/numLoop, h, sprintf('Processing: %d of %d', ii, numLoop));
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%              Plotting             %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curhp = 70:.1:81;
gifFile = 'stokes_evolution_prf_sweep_beta_60.gif';
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

    sgtitle(sprintf("Sweep of h` from %d to %d (%f)",min(curhp),max(curhp),curhp(ii)))
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