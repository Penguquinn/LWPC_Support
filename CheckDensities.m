
hprime = 71:1:80;
beta = 1;%:.01:0.4;
h_0 = 120;%:4:100;


%% Make Ionosphere Height Chart

h = 0:4:120;
qe = 1.602176634e-19; %C
eps0 = 8.8541878128e-12; %F/m
me = 9.1093837015e-31; %kg
wrprime = 2.5e3;
sav_en = [];


for ii = 1:length(hprime)
    
    %calculate N_0 and H based on the given values
    Htest = 5:.01:100;
    betatest = (0.5./Htest).*(exp(-((hprime(ii)-h_0)./Htest))-1);
    [~,betaind] = min(abs(betatest-beta));
    %             betaind = find(betatest-beta(bb) ==  min(abs(betatest-beta(bb))));
    H = Htest(betaind);
    
    nuprime = 5e6*exp(-0.15*(hprime(ii)-70));
    enprime = wrprime*nuprime*eps0*me./(qe.^2)./100.^3; %electron density at the reflection height in cm^-3

    zprime = (hprime(ii)-h_0)./(H);
    zp2 = -log(2*H*beta)+log(1);
    N_0 = enprime*exp(-0.5*(1-zp2-exp(-zp2)));

    % N_0 = 10^5;
    
    z = (h-h_0)./H;
    en = N_0.*exp(0.5.*(1-z-exp(-z)));
    sav_en = [sav_en, fliplr(en).'];
end


tvec = (1:length(sav_en)) ./ (60*60);
imagesc(tvec,h,sav_en)
colormap jet
cb = colorbar;
% clim([-8,5])
title("Electron Density Against Altitude","FontSize",22)
xlabel("Time (Hr)","FontSize",20)
ylabel("Altitude (km)","FontSize",20)
% clabel("Electron Density in Log Scale")
yt = get(gca, 'YTick');                 % tick positions (stay the same)
set(gca, 'YTickLabel', flip(yt));       % reverse what's displayed
ylabel(cb, 'Electron Density in Log Scale',FontSize=20);