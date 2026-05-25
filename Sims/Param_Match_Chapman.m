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
clean_w(1);
hprime = 65:1:80;
beta = .3:.05:0.6;
h_0 = 110;%80:2:100;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%        Build Profile files        %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tagsm = angle_min:angle_step:angle_max;
filenames = chapman_prf(paths,hprime,beta,h_0);
save(sprintf('%dhp%d_%db%d_%dho%d_filenames.mat',min(hprime)*10,max(hprime)*10,min(beta)*1000,max(beta)*1000,min(h_0)*10,max(h_0)*10),"filenames")


% for ii=1:numel(filenames)
TXdata{1} = 'NAA240';
% end
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



chapman_write(paths,hprime,beta,h_0,filenames,rxvr_loc(1),rxvr_loc(2),dist_max,TXdata{1})

disp("Finished INP")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Run list of lwpc commands      %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parfor ii = 1:numel(filenames)
[status, cmdout] = RunLWPC(filenames{ii});

end
% clean_w(0);
disp("Finished RUN")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Read Outputs into .mat files   %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for kk = 1:numel(h_0)
    for ii = 1:numel(hprime)
        parfor jj = 1:numel(beta)
            % [status, cmdout] = RunLWPC(filenames{ii});
            try
            [s0_c{ii,jj,kk},s1_c{ii,jj,kk},s2_c{ii,jj,kk},s3_c{ii,jj,kk}] = ...
                lw_vs_d_function(paths,filenames{ii,jj,kk},freak,dist_max);
            catch
                disp(sprintf("error at %d %d %d", ii, jj, kk))
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
% elemn = numel(h_0)*numel(beta)*numel(hprime);
% s0_c = cell(elemn,1);
% s1_c = cell(elemn,1);
% s2_c = cell(elemn,1);
% s3_c = cell(elemn,1);
% parfor kk = 1:elemn
%     [status, cmdout] = RunLWPC(filenames{kk});
%     try
%     [s0_c{kk},s1_c{kk},s2_c{kk},s3_c{kk}, hx{kk},hy{kk}] = ...
%         lw_vs_d_function(paths,filenames{kk},freak,dist_max);
%     catch
%         s0_c{kk} = NaN(1001,1);
%         s1_c{kk} = NaN(1001,1);
%         s2_c{kk} = NaN(1001,1);
%         s3_c{kk} = NaN(1001,1);
%         hx{kk} = NaN(1001,1);
%         hy{kk} = NaN(1001,1);
%     end
% end
% [~,~,~,~,~,~,rho_full] = lw_vs_d_function(paths,filenames{end},freak,dist_max);
% 
% s0_c = reshape(s0_c,numel(hprime),numel(beta),numel(h_0));
% s1_c = reshape(s1_c,numel(hprime),numel(beta),numel(h_0));
% s2_c = reshape(s2_c,numel(hprime),numel(beta),numel(h_0));
% s3_c = reshape(s3_c,numel(hprime),numel(beta),numel(h_0));



disp("Finished READ")
save(sprintf('%dhp%d_%db%d_%dho%d.mat',min(hprime)*10,max(hprime)*10,min(beta)*1000,max(beta)*1000,min(h_0)*10,max(h_0)*10),"s0_c","s1_c","s2_c","s3_c")



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%            Build S Grid           %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%
nrpts = 1000;
rho_max = max(dist_max);
rho_full = 0:rho_max/nrpts:rho_max;
idx = find(abs(rho_full-path_len)==min(abs(rho_full-path_len)));
for kk = 1%:numel(h_0)
    for ii = 1:numel(hprime)
        for jj = 1:numel(beta)
            gs0(ii,jj,kk) = s0_c{ii,jj,kk}(idx);
            gs1(ii,jj,kk) = s1_c{ii,jj,kk}(idx)./gs0(ii,jj,kk);
            gs2(ii,jj,kk) = s2_c{ii,jj,kk}(idx)./gs0(ii,jj,kk);
            gs3(ii,jj,kk) = s3_c{ii,jj,kk}(idx)./gs0(ii,jj,kk);

            % gs1(ii,jj,kk) = gs1(ii,jj,kk)-ns1(idx);
            % gs2(ii,jj,kk) = gs2(ii,jj,kk)-ns2(idx);
            % gs3(ii,jj,kk) = gs3(ii,jj,kk)-ns3(idx);
            % 
            % rse(ii,jj,kk) = (gs1(ii,jj,kk)^2 + gs2(ii,jj,kk)^2 + gs3(ii,jj,kk)^2)/3;

        end
    end
end


figure("Theme","Light");

for ii = 1 %:numel(h_0)

    % sgtitle("Error from run of 72.65h\prime .4005\beta 120h_0","FontSize",25)

    % ---------------- S1 ----------------
    subplot(1,3,1)

    h = imagesc(beta, hprime, squeeze(gs1(:,:,ii)));
    set(h, 'AlphaData', ~isnan(squeeze(gs1(:,:,ii))));
    set(gcf, 'Color', 'w'); % Sets background to white (or any other color)
    axis xy;

    colorbar;
    clim([-1 1])

    xlabel('\beta','FontSize',15);
    ylabel('Hprime','FontSize',15);

    title("Normalized S1","FontSize",20);


    % ---------------- S2 ----------------
    subplot(1,3,2)

    imagesc(beta, hprime, squeeze(gs2(:,:,ii)));
    axis xy;

    colorbar;
    clim([-1 1])

    xlabel('\beta','FontSize',15);
    ylabel('Hprime','FontSize',15);

    title("Normalized S2","FontSize",20);


    % ---------------- S3 ----------------
    subplot(1,3,3)

    imagesc(beta, hprime, squeeze(gs3(:,:,ii)));
    axis xy;

    colorbar;
    clim([-1 1])

    xlabel('\beta','FontSize',15);
    ylabel('Hprime','FontSize',15);

    title("Normalized S3","FontSize",20);

end






















% load("C:\Users\qdh0004\OneDrive - Auburn University\Desktop\nb_polarization\CH240815013000NLK_001.mat")
% 
% s1 = movmean(s1./s0,20);
% s2 = movmean(s2./s0,20);
% s3 = movmean(s3./s0,20);
% 
% sr = complex(s1,s2) * exp( -1i * (pi + mean(angle(complex(s1,s2)))));
% s1r = real(sr); s2r = imag(sr);
% figure; plot(s1r); hold on; plot(s2r); plot(s3);
% legend('s1','s2','s3')
% 
% 
% for ii = 1:size(s0,1)
% [~, linearIndex] = min(abs(gs1(:) - s1(ii)));
% [dim1(ii,1), dim2(ii,1), dim3(ii,1)] = ind2sub(size(gs1), linearIndex);
% 
% [~, linearIndex] = min(abs(gs2(:) - s2(ii)));
% [dim1(ii,2), dim2(ii,2), dim3(ii,2)] = ind2sub(size(gs1), linearIndex);
% 
% [~, linearIndex] = min(abs(gs3(:) - s3(ii)));
% [dim1(ii,3), dim2(ii,3), dim3(ii,3)] = ind2sub(size(gs1), linearIndex);
% 
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%              Plotting             %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% %% Create figure
% gifFile = 'errorMapOverTime.gif';
% delayTime = 0.5;
% fig2 = figure('Color','w');
% set(fig2,'Position',[100 100 900 400])
% 
% for sel = 1:50
% 
% % temp1 = gs1(dim1(1,1),:,:);
% % temp1 = squeeze(abs(temp1 - s1r(sel)));
% % temp2 = gs2(dim1(1,2),:,:);
% % temp2 = squeeze(abs(temp2 - s2r(sel)));
% % temp3 = gs3(dim1(1,3),:,:);
% % temp3 = squeeze(abs(temp3 - s3(sel)));
% 
% temp1 = gs1(:,:,1);
% temp1 = squeeze(abs(temp1 - s1r(sel)));
% temp2 = gs2(:,:,1);
% temp2 = squeeze(abs(temp2 - s2r(sel)));
% temp3 = gs3(:,:,1);
% temp3 = squeeze(abs(temp3 - s3(sel)));
% 
% mag = sqrt(temp1.^2 + temp2.^2 + temp3.^2);
% [~, idx] = min(mag(:));
% [row, col] = ind2sub(size(mag), idx);
% 
% 
% subplot(1,3,1)
% % imagesc(squeeze(gs1)); hold on;
% imagesc(hprime,beta,temp1); hold on;
% 
% plot(col, row, 'p', ...
%     'MarkerEdgeColor','black', ...
%     'MarkerFaceColor','yellow', ...
%     'MarkerSize',15)
% axis xy          % puts origin at bottom-left (like spectrograms)
% colorbar
% xlabel("Hprime")
% colormap(jet)    % or parula, turbo, hot, etc.
% title('Error S1')
% ylabel("beta")
% subplot(1,3,2)
% 
% % imagesc(squeeze(gs2)); hold on;
% imagesc(hprime,beta,temp2); hold on;
% 
% plot(col, row, 'p', ...
%     'MarkerEdgeColor','black', ...
%     'MarkerFaceColor','yellow', ...
%     'MarkerSize',15)
% axis xy          % puts origin at bottom-left (like spectrograms)
% colorbar
% colormap(jet)    % or parula, turbo, hot, etc.
% xlabel("Hprime")
% title('Error S2')
% ylabel("beta")
% 
% 
% subplot(1,3,3)
% temp3(isnan(temp3))
% % imagesc(squeeze(gs3)); hold on;
% imagesc(hprime,beta,temp3); hold on;
% 
% plot(col, row, 'p', ...
%     'MarkerEdgeColor','black', ...
%     'MarkerFaceColor','yellow', ...
%     'MarkerSize',15)
% axis xy          % puts origin at bottom-left (like spectrograms)
% colorbar
% colormap(jet)    % or parula, turbo, hot, etc.
% % colormap("bone")
% title('Error S3')
% xlabel("Hprime")
% ylabel("beta")
% drawnow
% frame = getframe(fig2);
% 
%     im = frame2im(frame);
%     [A,map] = rgb2ind(im,256);
%     if sel == 1
%         imwrite(A,map,gifFile,'gif','LoopCount',inf,'DelayTime',delayTime);
%     else
%         imwrite(A,map,gifFile,'gif','WriteMode','append','DelayTime',delayTime);
%     end
% 
% end
% 
% 
% 
% gifFile = 'continuity.gif';
% delayTime = 0.5;
% 
% %% Create figure
% fig = figure('Color','w');
% set(fig,'Position',[100 100 900 400])
% for ii = 1:size(gs1,1)
%     plot(gs1(ii,:))
%     ylim([-1, 1])
%     drawnow
%     frame = getframe(fig);
% 
%     im = frame2im(frame);
%     [A,map] = rgb2ind(im,256);
%     if ii == 1
%         imwrite(A,map,gifFile,'gif','LoopCount',inf,'DelayTime',delayTime);
%     else
%         imwrite(A,map,gifFile,'gif','WriteMode','append','DelayTime',delayTime);
%     end
% end