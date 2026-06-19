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
hprime = 60:1:80;
beta = 0.3:0.01:0.6;
h_0 = 110:1:130;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%        Build Profile files        %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tagsm = angle_min:angle_step:angle_max;
filenames = chapman_prf(paths,hprime,beta,h_0);
save(sprintf('hp%d_%d_%d_b%d_%d_%d_ho%d_%d_%d_filenames.mat',min(hprime)*10,max(hprime)*10,numel(hprime),min(beta)*1000,max(beta)*1000,numel(beta),min(h_0)*10,max(h_0)*10,numel(h_0)),"filenames")


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




disp("Finished READ")
save(sprintf('hp%d_%d_%d_b%d_%d_%d_ho%d_%d_%d.mat',min(hprime)*10,max(hprime)*10,numel(hprime),min(beta)*1000,max(beta)*1000,numel(beta),min(h_0)*10,max(h_0)*10,numel(h_0)),"s0_c","s1_c","s2_c","s3_c")



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%            Build S Grid           %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%
nrpts = 1000;
rho_max = max(dist_max);
rho_full = 0:rho_max/nrpts:rho_max;
idx = find(abs(rho_full-path_len)==min(abs(rho_full-path_len)));
for kk = 1:numel(h_0)
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%         Select Squeeze Dim        %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
depth = 16;
fdim = 2;
switch(fdim)
    case(1)
        sel1 = squeeze(gs1(depth,:,:));
        sel2 = squeeze(gs2(depth,:,:));
        sel3 = squeeze(gs3(depth,:,:));
        xaxis = h_0;
        yaxis = beta;
        xname = 'H_0';
        yname = '\beta';
    case(2)
        sel1 = squeeze(gs1(:,depth,:));
        sel2 = squeeze(gs2(:,depth,:));
        sel3 = squeeze(gs3(:,depth,:));
        xaxis = h_0;
        yaxis = hprime;
        xname = 'H_0';
        yname = 'H\prime';
    case(3)
        sel1 = squeeze(gs1(:,:,depth));
        sel2 = squeeze(gs2(:,:,depth));
        sel3 = squeeze(gs3(:,:,depth));
        xaxis = beta;
        yaxis = hprime;
        xname = '\beta';
        yname = 'H\prime';
end


figure("Theme","Dark");



% sgtitle("Error from run of 72.65h\prime .4005\beta 120h_0","FontSize",25)

% ---------------- S1 ----------------
subplot(1,3,1)

h = imagesc(xaxis, yaxis, sel1);
set(h, 'AlphaData', ~isnan(sel1));
set(gcf, 'Color', 'w'); % Sets background to white (or any other color)
axis xy;

colorbar;
clim([-1 1])

xlabel(xname,'FontSize',15);
ylabel(yname,'FontSize',15);

title("Normalized S1","FontSize",20);


% ---------------- S2 ----------------
subplot(1,3,2)

h = imagesc(xaxis, yaxis, sel2);
set(h, 'AlphaData', ~isnan(sel2));
set(gcf, 'Color', 'w'); % Sets background to white (or any other color)
axis xy;

colorbar;
clim([-1 1])

xlabel(xname,'FontSize',15);
ylabel(yname,'FontSize',15);

title("Normalized S2","FontSize",20);


% ---------------- S3 ----------------
subplot(1,3,3)

h = imagesc(xaxis, yaxis, sel3);
set(h, 'AlphaData', ~isnan(sel3));
set(gcf, 'Color', 'w'); % Sets background to white (or any other color)
axis xy;

colorbar;
clim([-1 1])

xlabel(xname,'FontSize',15);
ylabel(yname,'FontSize',15);

title("Normalized S3","FontSize",20);










% figure("Theme","Dark");
% % sgtitle("Error from run of 72.65h\prime .4005\beta 120h_0","FontSize",25)
% 
% % ---------------- S1 ----------------
% subplot(1,3,1)
% 
% h = imagesc(xaxis, yaxis, log10(abs(sel1)));
% set(h, 'AlphaData', ~isnan(sel1));
% set(gcf, 'Color', 'w'); % Sets background to white (or any other color)
% axis xy;
% 
% colorbar;
% % clim([-1 1])
% 
% xlabel(xname,'FontSize',15);
% ylabel(yname,'FontSize',15);
% 
% title("Normalized S1","FontSize",20);
% 
% 
% % ---------------- S2 ----------------
% subplot(1,3,2)
% 
% h = imagesc(xaxis, yaxis, log10(abs(sel2)));
% set(h, 'AlphaData', ~isnan(sel2));
% set(gcf, 'Color', 'w'); % Sets background to white (or any other color)
% axis xy;
% 
% colorbar;
% % clim([-1 1])
% 
% xlabel(xname,'FontSize',15);
% ylabel(yname,'FontSize',15);
% 
% title("Normalized S2","FontSize",20);
% 
% 
% % ---------------- S3 ----------------
% subplot(1,3,3)
% 
% h = imagesc(xaxis, yaxis, log10(abs(sel3)));
% set(h, 'AlphaData', ~isnan(sel3));
% set(gcf, 'Color', 'w'); % Sets background to white (or any other color)
% axis xy;
% 
% colorbar;
% % clim([-1 1])
% 
% xlabel(xname,'FontSize',15);
% ylabel(yname,'FontSize',15);
% 
% title("Normalized S3","FontSize",20);














