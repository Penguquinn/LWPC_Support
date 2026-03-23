%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%            The Givens             %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
clear all;
clc;

angle_step = 0.1;
dist_max = 10000;
angle_min = 230;
angle_max = 270;
freak = 24;
paths = 'C:\LWPCwin\';
% cleanup(0);
% clean_w(1);
hprime = 70.1:.1:100;
beta = .301:.001:0.6;
h_0 = 5;%60:4:100;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%        Build Profile files        %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tagsm = angle_min:angle_step:angle_max;
% filenames = chapman_prf(paths,hprime,beta,h_0);
filenames = prf_exp(paths,hprime,beta);


for ii=1:numel(filenames)
TXdata{1,ii} = 'NAA240';
end
disp("Finished PRF")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%        Build input files          %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xmtr_loc = [44.633,67.283]; % NAA, Cutler
% xmtr_loc = [46.366   98.336]; % NLK, Jim Creek
% rxvr_loc = [32.466224, 85.470938]; % Auburn
% rxvr_loc = [62.567234209170635, 144.66236353401382]; % Chistochina
rxvr_loc = [41.945013, 72.727013]; % East Granby

path_len = distance(rxvr_loc(1),rxvr_loc(2),xmtr_loc(1),xmtr_loc(2),'degrees');
path_len = deg2km(path_len);



% chapman_write(paths,hprime,beta,h_0,filenames,rxvr_loc(1),rxvr_loc(2),dist_max,TXdata{1})
exp_write(paths,hprime,beta,filenames,TXdata{1},rxvr_loc(1),rxvr_loc(2))
disp("Finished INP")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Run list of lwpc commands      %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parfor ii = 1:numel(filenames)
    if isfile(sprintf("C:\\LWPCwin\\%s.log",filenames{ii}))
        continue
    end
    [status, cmdout] = RunLWPC(filenames{ii});

end
clean_w(0);
disp("Finished RUN")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Read Outputs into .mat files   %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ii = 1:numel(hprime)
    for jj = 1:numel(beta)
        try
        [s0_c{ii,jj},s1_c{ii,jj},s2_c{ii,jj},s3_c{ii,jj}, hx{ii,jj},hy{ii,jj}, rho_full] = ...
            lw_vs_d_function(paths,filenames{ii,jj},freak,dist_max);
        catch
            s0_c{ii,jj} = NaN(1001,1);
            s1_c{ii,jj} = NaN(1001,1);
            s2_c{ii,jj} = NaN(1001,1);
            s3_c{ii,jj} = NaN(1001,1);
            hx{ii,jj} = NaN(1001,1);
            hy{ii,jj} = NaN(1001,1);
        end
    end
end

disp("Finished READ")



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%            Build S Grid           %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
idx = find(abs(rho_full-path_len)==min(abs(rho_full-path_len)));
for ii = 1:numel(hprime)
    for jj = 1:numel(beta)
        gs0(ii,jj) = s0_c{ii,jj}(idx);
        gs1(ii,jj) = s1_c{ii,jj}(idx)./gs0(ii,jj);
        gs2(ii,jj) = s2_c{ii,jj}(idx)./gs0(ii,jj);
        gs3(ii,jj) = s3_c{ii,jj}(idx)./gs0(ii,jj);

    end
end
load("nb_polarization\CH240815013000NLK_001.mat")

s1 = movmean(s1./s0,30);
s2 = movmean(s2./s0,30);
s3 = movmean(s3./s0,30);

sr = complex(s1,s2) * exp( -1i * (pi + mean(angle(complex(s1,s2)))));
s1r = real(sr); s2r = imag(sr);
figure; plot(s1r); hold on; plot(s2r); plot(s3);
legend('s1','s2','s3')


for ii = 1:size(s0,1)
[~, linearIdx] = min(abs(gs1 - s1(ii)), [], 'all');
[row1(ii), col1(ii)] = ind2sub(size(gs1), linearIdx);
[~, linearIdx] = min(abs(gs2 - s2(ii)), [], 'all');
[row2(ii), col2(ii)] = ind2sub(size(gs2), linearIdx);
[~, linearIdx] = min(abs(gs3 - s3(ii)), [], 'all');
[row3(ii), col3(ii)] = ind2sub(size(gs3), linearIdx);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%              Plotting             %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Create figure
gifFile = 'errorMapOverTime.gif';
delayTime = 0.5;
fig2 = figure('Color','w');
set(fig2,'Position',[100 100 900 600])

for sel = 1:50

% temp1 = gs1(dim1(1,1),:,:);
% temp1 = squeeze(abs(temp1 - s1r(sel)));
% temp2 = gs2(dim1(1,2),:,:);
% temp2 = squeeze(abs(temp2 - s2r(sel)));
% temp3 = gs3(dim1(1,3),:,:);
% temp3 = squeeze(abs(temp3 - s3(sel)));

temp1 = gs1-s1r(sel);
temp2 = gs2-s2r(sel);
temp3 = gs3-s3(sel);


mag = sqrt(temp1.^2 + temp2.^2 + temp3.^2);
[~, idx] = min(mag(:));
[row, col] = ind2sub(size(mag), idx);


subplot(2,2,1)
% imagesc(squeeze(gs1)); hold on;
imagesc(hprime,beta,temp1); hold on;

plot(hprime(col), beta(row), 'p', ...
    'MarkerEdgeColor','black', ...
    'MarkerFaceColor','yellow', ...
    'MarkerSize',15)
axis xy          % puts origin at bottom-left (like spectrograms)
colorbar
ylabel("Beta",Color='black',FontSize=15)
colormap(jet)    % or parula, turbo, hot, etc.
title('Error S1',Color='black',FontSize=15)
xlabel("hprime",Color='black',FontSize=15)



subplot(2,2,2)

% imagesc(squeeze(gs2)); hold on;
imagesc(hprime,beta,temp2); hold on;

plot(hprime(col), beta(row), 'p', ...
    'MarkerEdgeColor','black', ...
    'MarkerFaceColor','yellow', ...
    'MarkerSize',15)
axis xy          % puts origin at bottom-left (like spectrograms)
colorbar
colormap(jet)    % or parula, turbo, hot, etc.
ylabel("Beta",Color='black',FontSize=15)
title('Error S2',Color='black',FontSize=15)
xlabel("hprime",Color='black',FontSize=15)


subplot(2,2,3)
% temp3(isnan(temp3))
% imagesc(squeeze(gs3)); hold on;
imagesc(hprime,beta,temp3); hold on;

plot(hprime(col), beta(row), 'p', ...
    'MarkerEdgeColor','black', ...
    'MarkerFaceColor','yellow', ...
    'MarkerSize',15)
axis xy          % puts origin at bottom-left (like spectrograms)
colorbar
colormap(jet)    % or parula, turbo, hot, etc.
% colormap("bone")
title('Error S3',Color='black',FontSize=15)
ylabel("Beta",Color='black',FontSize=15)
xlabel("hprime",Color='black',FontSize=15)


subplot(2,2,4)
% imagesc(squeeze(gs1)); hold on;
imagesc(hprime,beta,mag); hold on;

plot(hprime(col), beta(row), 'p', ...
    'MarkerEdgeColor','black', ...
    'MarkerFaceColor','yellow', ...
    'MarkerSize',15)
axis xy          % puts origin at bottom-left (like spectrograms)
colorbar
ylabel("Beta",Color='black',FontSize=15)
colormap(jet)    % or parula, turbo, hot, etc.
title('Total RSS Error',Color='black',FontSize=15)
xlabel("hprime",Color='black',FontSize=15)
drawnow
frame = getframe(fig2);
    
    im = frame2im(frame);
    [A,map] = rgb2ind(im,256);
    if sel == 1
        imwrite(A,map,gifFile,'gif','LoopCount',inf,'DelayTime',delayTime);
    else
        imwrite(A,map,gifFile,'gif','WriteMode','append','DelayTime',delayTime);
    end

end



gifFile = 'continuity.gif';
delayTime = 0.5;

%% Create figure
fig = figure('Color','w');
set(fig,'Position',[100 100 900 400])
for ii = 1:26
    plot(gs1(ii,:))
    ylim([-1, 1])
    drawnow
    frame = getframe(fig);
    
    im = frame2im(frame);
    [A,map] = rgb2ind(im,256);
    if ii == 1
        imwrite(A,map,gifFile,'gif','LoopCount',inf,'DelayTime',delayTime);
    else
        imwrite(A,map,gifFile,'gif','WriteMode','append','DelayTime',delayTime);
    end
end


%% extra plot
gifFile = 'stokesSpace.gif';
delayTime = 0.5;
fig4 = figure('Color','w');
set(fig4,'Position',[100 100 900 600])


subplot(1,3,1)
% imagesc(squeeze(gs1)); hold on;
imagesc(hprime,beta,gs1); hold on;


axis xy          % puts origin at bottom-left (like spectrograms)
colorbar
ylabel("Beta",Color='black',FontSize=15)
colormap(jet)    % or parula, turbo, hot, etc.
title('Normalized S1',Color='black',FontSize=15)
xlabel("hprime",Color='black',FontSize=15)



subplot(1,3,2)

% imagesc(squeeze(gs2)); hold on;
imagesc(hprime,beta,gs2); hold on;

axis xy          % puts origin at bottom-left (like spectrograms)
colorbar
colormap(jet)    % or parula, turbo, hot, etc.
ylabel("Beta",Color='black',FontSize=15)
title('Normalized S2',Color='black',FontSize=15)
xlabel("hprime",Color='black',FontSize=15)


subplot(1,3,3)
% temp3(isnan(temp3))
% imagesc(squeeze(gs3)); hold on;
imagesc(hprime,beta,gs3); hold on;

axis xy          % puts origin at bottom-left (like spectrograms)
colorbar
colormap(jet)    % or parula, turbo, hot, etc.
% colormap("bone")
title('Normalized S3',Color='black',FontSize=15)
ylabel("Beta",Color='black',FontSize=15)
xlabel("hprime",Color='black',FontSize=15)



drawnow
frame = getframe(fig4);
    
    im = frame2im(frame);
    [A,map] = rgb2ind(im,256);
    if sel == 1
        imwrite(A,map,gifFile,'gif','LoopCount',inf,'DelayTime',delayTime);
    else
        imwrite(A,map,gifFile,'gif','WriteMode','append','DelayTime',delayTime);
    end

