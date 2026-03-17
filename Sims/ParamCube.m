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
paths = 'C:\LWPCwin\';
% cleanup(0);
%clean_w(1);
hprime = 60:.5:62;
beta = .35:0.01:0.37;
h_0 = 75:.5:77;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%        Build Profile files        %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tagsm = angle_min:angle_step:angle_max;
filenames = chapman_prf(paths,hprime,beta,h_0);
% filenames = prf_exp(paths,hprime,beta);


for ii=1:numel(filenames)
TXdata{1,ii} = 'NAA240';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%        build input files          %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%xmtr_loc = [44.633,-67.283];
xmtr_loc = [46.366   -98.336];
rxvr_loc = [32.466224, -85.470938];

chapman_write(paths,hprime,beta,h_0,filenames,rxvr_loc(1),rxvr_loc(2),dist_max,TXdata{1})
% exp_write(paths,hprime,beta,filenames)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Run list of lwpc commands      %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parfor ii = 1:numel(filenames)
[status, cmdout] = RunLWPC(filenames{ii});

end
clean_w(0);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Read Outputs into .mat files   %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for kk = 1:numel(h_0)
    for ii = 1:numel(hprime)
        for jj = 1:numel(beta)
            try
            [s0_c{ii,jj,kk},s1_c{ii,jj,kk},s2_c{ii,jj,kk},s3_c{ii,jj,kk}, hx{ii,jj,kk},hy{ii,jj,kk}] = ...
                lw_vs_d_function(paths,filenames{ii,jj,kk},freak,dist_max);
            catch
                s0_c{ii,jj,kk} = NaN(1001,1);
                s1_c{ii,jj,kk} = NaN(1001,1);
                s2_c{ii,jj,kk} = NaN(1001,1);
                s3_c{ii,jj,kk} = NaN(1001,1);
                hx{ii,jj,kk} = NaN(1001,1);
                hy{ii,jj,kk} = NaN(1001,1);
            end
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%              Plotting             %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% GIF settings
gifFile = 'three_panel_animation.gif';
delayTime = 0.3;

%% Create figure
fig = figure('Color','w');
set(fig,'Position',[100 100 900 400])

for kk = 1:numel(h_0)
    for ii = 1:numel(hprime)
        for jj = 1:numel(beta)

    clf

    %% Subplot 1
    subplot(2,3,1)
    plot(10*log10(abs(s0_c{ii,jj,kk})),'LineWidth',1.5)
    ylim([0,150])
    title('S0')
    grid on

    %% Subplot 2
    subplot(2,3,2)
    plot(10*log10(abs(s1_c{ii,jj,kk})),'LineWidth',1.5)
    title('S1')
    ylim([0,150])
    grid on

    %% Subplot 3
    subplot(2,3,3)
    plot(10*log10(abs(s2_c{ii,jj,kk})),'LineWidth',1.5)
    title('S2')
    ylim([0,150])
    grid on

    %% Subplot 4
    subplot(2,3,4)
    plot(10*log10(abs(s3_c{ii,jj,kk})),'LineWidth',1.5)
    title('S3')
    ylim([0,150])
    grid on

    %% Subplot 5
    subplot(2,3,5)
    plot(s1_c{ii,jj,kk}./s0_c{ii,jj,kk})
    hold on;
    plot(s2_c{ii,jj,kk}./s0_c{ii,jj,kk})
    plot(s3_c{ii,jj,kk}./s0_c{ii,jj,kk})


    %% Subplot 6
    h = [20:5:65 67:2:120 120:10:200];
    Nm = 1;
    en = Nm .* exp( 0.5 * ( beta(jj) * (hprime(ii) - h) + exp(-beta(jj) * (hprime(ii) - h_0(kk))) - exp(-beta(jj) * (h - h_0(kk))) ) );
    subplot(2,3,6);
    plot(log10(en),h)
    

    sgtitle(sprintf('H` = %f beta = %f h_0 = %f',hprime(ii),beta(jj),h_0(kk)))

    drawnow

    %% Capture frame for GIF
    frame = getframe(fig);
    im = frame2im(frame);
    [A,map] = rgb2ind(im,256);

    if ii*jj*kk == 1
        imwrite(A,map,gifFile,'gif','LoopCount',inf,'DelayTime',delayTime);
    else
        imwrite(A,map,gifFile,'gif','WriteMode','append','DelayTime',delayTime);
    end
        end
    end
end

disp('GIF saved.')