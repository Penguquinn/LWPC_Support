load("651hp800_301b600_1000ho1200_NAA_EG.mat")


%%
day = 0;

if day == 0
    NS_amp = load("C:\VLF_data\EG\2016\06\11\000000\EG160611000000NAA_004A.mat")
    NS_phase = load("C:\VLF_data\EG\2016\06\11\000000\EG160611000000NAA_004B.mat")
    EW_amp = load("C:\VLF_data\EG\2016\06\11\000000\EG160611000000NAA_005A.mat")
    EW_phase = load("C:\VLF_data\EG\2016\06\11\000000\EG160611000000NAA_005B.mat")
else
    NS_amp = load("C:\VLF_data\EG\2016\06\11\120000\EG160611120000NAA_004A.mat")
    NS_phase = load("C:\VLF_data\EG\2016\06\11\120000\EG160611120000NAA_004B.mat")
    EW_amp = load("C:\VLF_data\EG\2016\06\11\120000\EG160611120000NAA_005A.mat")
    EW_phase = load("C:\VLF_data\EG\2016\06\11\120000\EG160611120000NAA_005B.mat")
end


time = 1:length(NS_phase.data);
NS = NS_amp.data .* exp(1i .* deg2rad(unwrap( NS_phase.data)));
EW = EW_amp.data .* exp(1i .* deg2rad(unwrap( EW_phase.data)));

p0 = abs(NS).^2 + abs(EW).^2;
p1 = abs(NS).^2 - abs(EW).^2;
p2 = 2* real(NS.* conj(EW));
p3 = 2* imag(NS.* conj(EW));
pn1 = p1./p0;
pn2 = p2./p0;
pn3 = p3./p0;


% plot(time,p0);hold on;plot(time,p1);plot(time,p2);plot(time,p3);
% figure;
% plot(time,p1./p0);hold on;plot(time,p2./p0);plot(time,p3./p0);
% plot(NS_amp.data);figure;plot(abs(NS));
% figure;
% plot(deg2rad(unwrap(NS_phase.data)));figure;plot(unwrap(angle(NS)));



%% Do the inversion

% hprime = 65.1:.1:80;
% beta = .301:.001:0.6;
% h_0 = 100:10:120;%80:2:100;

rho_full = linspace(0,10000,1001);
path_len = 533;
idx = find(abs(rho_full-path_len)==min(abs(rho_full-path_len)));
for kk = 1:numel(h_0)
    for ii = 1:numel(hprime)
        for jj = 1:numel(beta)
            gs0(ii,jj,kk) = s0_c{ii,jj,kk}(idx);
            gs1(ii,jj,kk) = s1_c{ii,jj,kk}(idx)./gs0(ii,jj,kk);
            gs2(ii,jj,kk) = s2_c{ii,jj,kk}(idx)./gs0(ii,jj,kk);
            gs3(ii,jj,kk) = s3_c{ii,jj,kk}(idx)./gs0(ii,jj,kk);

        end
    end
end




xx = abs(gs1 - pn1(1)) + abs(gs2 - pn2(1)) + abs(gs3-pn3(1));
[aa,bb] = min(xx(:));
[rr,cc,dd] = ind2sub(size,bb);

s1_space = squeeze(gs1(:,:,dd));
s2_space = squeeze(gs2(:,:,dd));
s3_space = squeeze(gs3(:,:,dd));

figure;
imagesc(beta,hprime,squeeze(xx(:,:,dd)))
hold on;
plot(beta(cc), hprime(rr), 'r*', 'MarkerSize', 10, 'LineWidth', 2);
title(['Error Map in H\prime abd \beta at h_0 = ', num2str(h_0(dd))],FontSize=30)
set(gca, 'FontSize', 20)
xlabel("\beta",FontSize=20)
ylabel("H\prime","FontSize",20)




%% again as a gif

% gifFile = 'EG_STOKE_ERROR.gif';
% delayTime = 0.1;
% fig2 = figure('Color','w');
% set(fig2,'Position',[100 100 900 400])

% for ii = 1:max(time)
% 
%     xx = abs(gs1 - pn1(ii)) + abs(gs2 - pn2(ii)) + abs(gs3-pn3(ii));
%     [aa,bb] = min(xx(:));
%     [rr,cc,dd] = ind2sub([150,300,3],bb);
% 
% 
% 
% 
%     sav_col(ii) = cc;
%     sav_row(ii) = rr;
%     sav_dep(ii) = dd;
% 
% 
% end

for ii = 1:max(time)

    xx = abs(gs1 - pn1(ii)) + abs(gs2 - pn2(ii)) + abs(gs3 - pn3(ii));

    % --- get 3 smallest ---
    [vals, idx] = mink(xx(:), 10);
    [rr, cc, dd] = ind2sub(size(xx), idx);

    % --- choose closest to previous ---
    if ii == 1
        % no previous → just take the smallest
        k = 1;
    else
        dist = hypot(rr - sav_row(ii-1), cc - sav_col(ii-1));
        [~, k] = min(dist);
    end

    % --- save result ---
    sav_row(ii) = rr(k);
    sav_col(ii) = cc(k);
    sav_dep(ii) = dd(k);

end


imagesc(beta,hprime,squeeze(xx(:,:,3))); hold on;
colormap turbo
colorbar
plot(beta(cc(1)), hprime(rr(1)), 'r*', 'MarkerSize', 10, 'LineWidth', 2);

subplot(1,2,1)
plot(abs(NS))
hold on;
plot(abs(EW))
title("field magnitude at receiver")
legend("NS","EW")
xlabel("Time (s)","FontSize",20)


subplot(1,2,2)
plot(movmean(beta(sav_col),600))
title("estimated \beta")
ylim([min(beta),max(beta)])

figure;
subplot(1,2,1)
plot(pn1)
hold on;
plot(pn2)
plot(pn3)
title("Normalized Stokes Parameter Value","FontSize",22)
legend("S1","S2","S3")
xlabel("Time (s)","FontSize",20)
ylabel("Normalized Stokes Value","FontSize",20)


subplot(1,2,2)
plot(movmean(hprime(sav_row),600))
title("Estimated H\prime","FontSize",22)
ylim([min(hprime),max(hprime)])
xlabel("Time (s)","FontSize",20)
ylabel("H\prime Estimate","FontSize",20)
sgtitle("Comparison of Normalized Stokes Parameters to H\prime Estimate",FontSize=25)


%% Make Ionosphere Height Chart
min_avg = .25;
sav_col = round(movmean(sav_col,min_avg*60));
sav_row = round(movmean(sav_row,min_avg*60));

h = 0:4:120;
h_0t = h_0(3);
qe = 1.602176634e-19; %C
eps0 = 8.8541878128e-12; %F/m
me = 9.1093837015e-31; %kg
wrprime = 2.5e5;
sav_en = [];
Htest = 5:.01:25;

for ii = 1:length(sav_col)
    
    %calculate N_0 and H based on the given values

    betatest = (0.5./Htest).*(exp(-((hprime(sav_row(ii))-h_0t)./Htest))-1);
    [~,betaind] = min(abs(betatest-beta(sav_col(ii))));
    % betaind = find(betatest-beta(bb) ==  min(abs(betatest-beta(bb))));
    H = Htest(betaind);
    
    nuprime = 5e6*exp(-0.15*(hprime(sav_row(ii))-70));
    enprime = wrprime*nuprime*eps0*me./(qe.^2)./100.^3; %electron density at the reflection height in cm^-3
    
    zprime = (hprime(sav_row(ii))-h_0t)./(H);
    N_0 = enprime*exp(-0.5*(1-zprime-exp(-zprime)));
    
    z = (h-h_0t)./H;
    en = N_0.*exp(0.5.*(1-z-exp(-z)));
    sav_en = [sav_en, fliplr(log10(en)).'];
end


tvec = (1:length(sav_en)) ./ (60*60);
imagesc(tvec,h,sav_en)
colormap jet
cb = colorbar;
clim([-8,5])
title("Electron Density Against Altitude","FontSize",22)
xlabel("Time (Hr)","FontSize",20)
ylabel("Altitude (km)","FontSize",20)
% clabel("Electron Density in Log Scale")
yt = get(gca, 'YTick');                 % tick positions (stay the same)
set(gca, 'YTickLabel', flip(yt));       % reverse what's displayed
ylabel(cb, 'Electron Density in Log Scale',FontSize=20);