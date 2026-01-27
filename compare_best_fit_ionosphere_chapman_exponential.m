%Using VLF data, compare the best fit ionospheric profile selected from a
%search space of exponential ionospheres and a search space of Chapman
%layer ionospheres

clearvars
Fs = 100000;

%for a given site and date, automatically extract ns/ew amplitude/phase data
txname = 'NAA';
rxname = 'EG';
year = '2016';
month = '06';
day = '11'; %quiet night
% month = '09';
% day = '22'; %quiet night

% dirpath = ['F:\VLF_Narrowband\' rxname '\' year '\' month '\' day '\'];
dirpath = ['C:\Users\hcb0003\Documents\Research\Dissertation\Paper_Drafts\Ionosphere_inversion_with_polarization\Data\' rxname '\' year '\' month '\' day '\'];
dirs = dir(dirpath);
amp_ns = [];
phase_ns = [];
amp_ew = [];
phase_ew = [];
for nn = 3:length(dirs) %for each directory at the filepath
    dirname = dirs(nn).name;
    % filepath = [dirpath dirname '\']; %windows
    filepath = [dirpath dirname '/']; %linux
%     files = dir(filepath);
    filename = [rxname year(3:4) month day dirname txname '_004A.mat'];
    load([filepath filename])
    amp_ns = [amp_ns; data];
    
    filename = [rxname year(3:4) month day dirname txname '_004B.mat'];
    load([filepath filename])
    phase_ns = [phase_ns; data];
    
    filename = [rxname year(3:4) month day dirname txname '_005A.mat'];
    load([filepath filename])
    amp_ew = [amp_ew; data];
    
    filename = [rxname year(3:4) month day dirname txname '_005B.mat'];
    load([filepath filename])
    phase_ew = [phase_ew; data];
    
    if length(amp_ns)>length(phase_ns)
        amp_ns(end) = [];
        amp_ew(end) = [];
    end
end


t = 1:length(amp_ns);
tplot = t./Fs./3600;

%%% Use this code to check the phase for errors
figure; plot(tplot,unwrap(phase_ns)); hold on; plot(tplot,unwrap(phase_ew))
figure; plot(tplot,phase_ns); hold on; plot(tplot,phase_ew)
% figure; plot(tplot,mod(phase_ns,90)); hold on; plot(tplot,mod(phase_ew,90))


%Use these as needed to fix phase erros
% phase_ns = fix_phasedata180(phase_ns,100);
% phase_ew = fix_phasedata180(phase_ew,100);

% phase_ns = fix_phasedata90(phase_ns,1000);
% phase_ew = fix_phasedata90(phase_ew,1000);
% phase_ns = fix_phasedata90(phase_ns,50);
% phase_ew = fix_phasedata90(phase_ew,50);

ns = amp_ns.*exp(complex(0,phase_ns*pi/180));
ew = amp_ew.*exp(complex(0,phase_ew*pi/180));

%special phase adjustment
% ns = ns.*exp(complex(0,-pi/2));
% ew = -ew;

t = 1:length(amp_ns);
tplot = t./Fs./3600;
% figure; plot(tplot,20.*log10(amp_ns)); hold on; plot(t/Fs/3600,20.*log10(amp_ew))
% legend('NS','EW')
dayns = mean(ns(61200-5*60*Fs:61200+5*60*Fs));
dayew = mean(ew(61200-5*60*Fs:61200+5*60*Fs));


%test rotation dependence
for theta = 0:.1:180
    thetar = theta.*pi/180;
    R = [cos(thetar) sin(thetar); -sin(thetar) cos(thetar)]; %clockwise rotation matrix
    fields = R*[dayns; dayew];
    xfield(round(theta/.1 +1)) = fields(2);
    yfield(round(theta/.1 +1)) = fields(1);
    
end

theta = 0:.1:180;
figure; plot(theta,20.*log10(abs(xfield))); hold on; plot(theta,20.*log10(abs(yfield)))
% figure; plot(theta,abs(xfield)); hold on; plot(theta,abs(yfield))

%rotate by the determined theta to maximize yfield
[~,tindex]=min(xfield);
theta_rotate = theta(tindex)*pi/180; %calculate from daytime polarization
% theta_rotate = 108*pi/180; %based on a certain day
R = [cos(theta_rotate) sin(theta_rotate); -sin(theta_rotate) cos(theta_rotate)];
hx = zeros(length(ns),1);
hy = zeros(length(ns),1);
for n = 1:length(ns)
    hfields = R*[ns(n); ew(n)];
    hx(n) = hfields(2);
    hy(n) = hfields(1);
end

%plot rotated fields
figure; plot(tplot,20.*log10(abs(hx))); hold on; plot(tplot,20.*log10(abs(hy)))
legend('H_x', 'H_y')

%calculate polarization
s0data =  abs(hx).^2 + abs(hy).^2;
s1data =  abs(hx).^2 - abs(hy).^2;
s2data =  2*real(hx.*conj(hy));
s3data = -2*imag(hx.*conj(hy));

%downsampled polarization
downfactor = 1*60;
tdown = downsample(t,downfactor);
hxdown = downsample(movmean(hx,downfactor),downfactor);
hydown = downsample(movmean(hy,downfactor),downfactor);
s0down =  abs(hxdown).^2 + abs(hydown).^2;
s1down =  abs(hxdown).^2 - abs(hydown).^2;
s2down =  2*real(hxdown.*conj(hydown));
s3down = -2*imag(hxdown.*conj(hydown));

s0data = s0down;
s1data = s1down;
s2data = s2down;
s3data = s3down;
tplot = tdown./Fs./3600;

% figure; plot(tplot,20.*log10(abs(s1data./s0data)))
% hold on; plot(tplot,20.*log10(abs(s2data./s0data)))
% hold on; plot(tplot,20.*log10(abs(s3data./s0data)))
% legend('S_1','S_2','S_3')
% title([txname '-' rxname ' ' year '-' month '-' day]);
% xlabel('Time after 00:00 UTC (hours)')
% ylabel('Normalized amplitude (dB)')
% 
% figure; plot(tplot,s1data./s0data)
% hold on; plot(tplot,s2data./s0data)
% hold on; plot(tplot,s3data./s0data)
% legend('S_1','S_2','S_3')
% title([txname '-' rxname ' ' year '-' month '-' day]);
% xlabel('Time after 00:00 UTC (hours)')
% ylabel('Normalized S-value')

figure; plot(tplot,10.*log10(abs(s1data./s0data)),'k')
hold on; plot(tplot,10.*log10(abs(s2data./s0data)),'--k')
hold on; plot(tplot,10.*log10(abs(s3data./s0data)),':k')
legend('S_1','S_2','S_3','location','southeast')
title([txname '-' rxname ' ' year '-' month '-' day]);
xlabel('Time after 00:00 UTC (hours)')
ylabel('Normalized amplitude (dB)')
grid on

%find best fit exponential ionosphere for each stokes parameter
switch rxname
    case 'EG'
        rxnum = 1;
    case 'CN'
        rxnum = 2;
    case 'CB'
        rxnum = 3;
end

%data analysis complete; load in LWPC database for comparison
%first database: coarse resolution exponential profiles
load('lwpc_polarization_half_res.mat') %s0(rr,hh,bb) indicies are receiver, hprime, beta
hprime_edge_exp = zeros(size(s0data));
beta_edge_exp = zeros(size(s0data));

% fig = figure;
% frameno = 0;
for tt = 1:length(s0data)
%     M = abs(squeeze(s1(rxnum,:,:,:)./s0(rxnum,:,:,:))-s1data(tt)./s0data(tt)).^2 + ...
%         abs(squeeze(s2(rxnum,:,:,:)./s0(rxnum,:,:,:))-s2data(tt)./s0data(tt)).^2 + ...
%         abs(squeeze(s3(rxnum,:,:,:)./s0(rxnum,:,:,:))-s3data(tt)./s0data(tt)).^2;
    M1 = abs(squeeze(s1(rxnum,:,:)./s0(rxnum,:,:))-s1data(tt)./s0data(tt)).^2;
    [minval,mindex] = min(M1,[],'all','linear');
    [hh,bb] = ind2sub(size(M1),mindex);
    hprime_est1(tt) = hprime(hh);
    beta_est1(tt) = beta(bb);
    
    M2 = abs(squeeze(s2(rxnum,:,:)./s0(rxnum,:,:))-s2data(tt)./s0data(tt)).^2;
    [minval,mindex] = min(M2,[],'all','linear');
    [hh,bb] = ind2sub(size(M2),mindex);
    hprime_est2(tt) = hprime(hh);
    beta_est2(tt) = beta(bb);
    
    M3 = abs(squeeze(s3(rxnum,:,:)./s0(rxnum,:,:))-s3data(tt)./s0data(tt)).^2;   
    [minval,mindex] = min(M3,[],'all','linear');
    [hh,bb] = ind2sub(size(M3),mindex);
    hprime_est3(tt) = hprime(hh);
    beta_est3(tt) = beta(bb);

    M = abs(squeeze(s1(rxnum,:,:)./s0(rxnum,:,:))-s1data(tt)./s0data(tt)).^2 + ...
        abs(squeeze(s2(rxnum,:,:)./s0(rxnum,:,:))-s2data(tt)./s0data(tt)).^2 + ...
        abs(squeeze(s3(rxnum,:,:)./s0(rxnum,:,:))-s3data(tt)./s0data(tt)).^2;

% %weighted by SNR
%     M = (s1data(tt)./s0data(tt)).^2.*abs(squeeze(s1(rxnum,:,:)./s0(rxnum,:,:))-s1data(tt)./s0data(tt)).^2 + ...
%         (s2data(tt)./s0data(tt)).^2.*abs(squeeze(s2(rxnum,:,:)./s0(rxnum,:,:))-s2data(tt)./s0data(tt)).^2 + ...
%         (s3data(tt)./s0data(tt)).^2.*abs(squeeze(s3(rxnum,:,:)./s0(rxnum,:,:))-s3data(tt)./s0data(tt)).^2;
    [minval,mindex] = min(M,[],'all','linear');
    [hh,bb] = ind2sub(size(M),mindex);

    minvals_exp(tt) = minval;
    hprime_exp(tt) = hprime(hh);
    beta_exp(tt) = beta(bb);
    
    %note if a parameter went out of bounds
    if hprime(hh) == max(hprime)
        hprime_edge_exp(tt) = 1;
    elseif hprime(hh) == min(hprime)
        hprime_edge_exp(tt) = -1;
    end
    
    if beta(bb) == max(beta)
        beta_edge_exp(tt) = 1;
    elseif beta(bb) == min(beta)
        beta_edge_exp(tt) = -1;
    end
%     if hprime_est(tt) == 73 && beta_est(tt) == 0.3
%         print('yup')
%     end
        

%     if mod(tt,Fs*5*60)==0
%         [minval,mindex] = min(M,[],'all','linear');
%         [hh,bb] = ind2sub(size(M),mindex);
% 
%         
%         hold off; imagesc(beta, hprime, 20*log10(abs(M))); axis xy; 
%         hold on;  plot(beta_est(tt),hprime_est(tt),'w*')
%         hold on;  plot(beta_est1(tt),hprime_est1(tt),'r*')
%         hold on;  plot(beta_est2(tt),hprime_est2(tt),'g*')
%         hold on;  plot(beta_est3(tt),hprime_est3(tt),'b*')
% 
%         
% 
%         thour = floor(tt/Fs/3600);
%         tminute = floor((tt-thour*Fs*3600)/Fs/60);
%         tsecond = floor((tt-thour*Fs*3600-tminute*Fs*60)/Fs);
%         title(sprintf('%0.2i:%0.2i:%0.2iUT',thour,tminute,tsecond))
%         caxis([-90 0])
%         drawnow
%         frameno = frameno +1;
%         F(frameno) = getframe(fig);  
%     end
end

%daytime error plot
tt = round(length(s0data).*0.75);
M = abs(squeeze(s1(rxnum,:,:)./s0(rxnum,:,:))-s1data(tt)./s0data(tt)).^2 + ...
    abs(squeeze(s2(rxnum,:,:)./s0(rxnum,:,:))-s2data(tt)./s0data(tt)).^2 + ...
    abs(squeeze(s3(rxnum,:,:)./s0(rxnum,:,:))-s3data(tt)./s0data(tt)).^2;
M = M./3;

figure; imagesc(beta,hprime,10*log10(abs(M))); 
hold on; plot(beta_exp(tt),hprime_exp(tt),'*w')
axis xy
colormap('gray')
colorbar
caxis([-70 0])

title('Stokes Parameters MSE, Day')
xlabel('Exponential Slope \beta (km^{-1})')
ylabel('Reflection Height h'' (km)')


%nighttime error plot
tt = round(length(s0data).*0.25);
M = abs(squeeze(s1(rxnum,:,:)./s0(rxnum,:,:))-s1data(tt)./s0data(tt)).^2 + ...
    abs(squeeze(s2(rxnum,:,:)./s0(rxnum,:,:))-s2data(tt)./s0data(tt)).^2 + ...
    abs(squeeze(s3(rxnum,:,:)./s0(rxnum,:,:))-s3data(tt)./s0data(tt)).^2;
M = M./3;

figure; imagesc(beta,hprime,10*log10(abs(M)));
hold on; plot(beta_exp(tt),hprime_exp(tt),'*k')
axis xy
colormap('gray')
colorbar
caxis([-70 0])

title('Stokes Parameters MSE, Night')
xlabel('Exponential Slope \beta (km^{-1})')
ylabel('Reflection Height h'' (km)')

%daytime estimate of hprime and beta
figure; subplot(2,1,1); plot(tplot, hprime_exp,'.k')
xlim([12 21])
ylim([68 78])
grid on
title(['Estimated Ionospheric Parameters NAA-EG ' year '-' month '-' day])
ylabel('Est. Reflection Height h'' (km)')

subplot(2,1,2); plot(tplot, beta_exp, '.k')
xlim([12 21])
ylim([0.3 0.6])
grid on
ylabel('Est. Exponential Slope \beta (km^{-1})')
xlabel('Hours after 00:00 UTC')

% figure; plot(tplot,10*log10(abs(movmean(minvals_exp,600))))
% figure; plot(tplot,10*log10(abs(minvals_exp)))


% %save as gif
% gifname = 'test_animation.gif'; % Specify the output file name
% for idx = 1:length(F)
%     im{idx} = frame2im(F(idx));
%     [A,map] = rgb2ind(im{idx},256);
%     if idx == 1
%         imwrite(A,map,gifname,'gif','LoopCount',Inf,'DelayTime',0.05);
%     else
%         imwrite(A,map,gifname,'gif','WriteMode','append','DelayTime',0.05);
%     end
% end

%second database: coarse resolution chapman layer profiles (3 parameter)
load('lwpc_polarization_chapman_hbh0_NAA-EG.mat') %s0(rr,hh,bb) indicies are receiver, hprime, beta

hprime_edge_chap = zeros(size(s0data));
beta_edge_chap = zeros(size(s0data));
h0_edge_chap = zeros(size(s0data));



% fig = figure;
% frameno = 0;
for tt = 1:length(s0data)
%     M = abs(squeeze(s1(rxnum,:,:,:)./s0(rxnum,:,:,:))-s1data(tt)./s0data(tt)).^2 + ...
%         abs(squeeze(s2(rxnum,:,:,:)./s0(rxnum,:,:,:))-s2data(tt)./s0data(tt)).^2 + ...
%         abs(squeeze(s3(rxnum,:,:,:)./s0(rxnum,:,:,:))-s3data(tt)./s0data(tt)).^2;
    M1 = abs(squeeze(s1(rxnum,:,:,:)./s0(rxnum,:,:,:))-s1data(tt)./s0data(tt)).^2;
    [minval,mindex] = min(M1,[],'all','linear');
    [hh,bb,mm] = ind2sub(size(M1),mindex);
    hprime_est1(tt) = hprime(hh);
    beta_est1(tt) = beta(bb);
    h0_est1(tt) = h_0(mm);
    
    M2 = abs(squeeze(s2(rxnum,:,:,:)./s0(rxnum,:,:,:))-s2data(tt)./s0data(tt)).^2;
    [minval,mindex] = min(M2,[],'all','linear');
    [hh,bb,mm] = ind2sub(size(M2),mindex);
    hprime_est2(tt) = hprime(hh);
    beta_est2(tt) = beta(bb);
    h0_est2(tt) = h_0(mm);
    
    M3 = abs(squeeze(s3(rxnum,:,:,:)./s0(rxnum,:,:,:))-s3data(tt)./s0data(tt)).^2;   
    [minval,mindex] = min(M3,[],'all','linear');
    [hh,bb,mm] = ind2sub(size(M3),mindex);
    hprime_est3(tt) = hprime(hh);
    beta_est3(tt) = beta(bb);
    h0_est3(tt) = h_0(mm);

    M = abs(squeeze(s1(rxnum,:,:,:)./s0(rxnum,:,:,:))-s1data(tt)./s0data(tt)).^2 + ...
        abs(squeeze(s2(rxnum,:,:,:)./s0(rxnum,:,:,:))-s2data(tt)./s0data(tt)).^2 + ...
        abs(squeeze(s3(rxnum,:,:,:)./s0(rxnum,:,:,:))-s3data(tt)./s0data(tt)).^2;
    M = M./3;
    [minval,mindex] = min(M,[],'all','linear');
    [hh,bb,mm] = ind2sub(size(M),mindex);

    minvals_chap(tt) = minval;
    hprime_chap(tt) = hprime(hh);
    beta_chap(tt) = beta(bb);
    h0_chap(tt) = h_0(mm);
    
        %note if a parameter went out of bounds
    if hprime(hh) == max(hprime)
        hprime_edge_chap(tt) = 1;
    elseif hprime(hh) == min(hprime)
        hprime_edge_chap(tt) = -1;
    end
    
    if beta(bb) == max(beta)
        beta_edge_chap(tt) = 1;
    elseif beta(bb) == min(beta)
        beta_edge_chap(tt) = -1;
    end
    
    if h_0(mm) == max(h_0)
        h0_edge_chap(tt) = 1;
    elseif h_0(mm) == min(h_0)
        h0_edge_chap(tt) = -1;
    end
    
%     if hprime_est(tt) == 73 && beta_est(tt) == 0.3
%         print('yup')
%     end
        

%     if mod(tt,Fs*5*60)==0
%         [minval,mindex] = min(M,[],'all','linear');
%         [hh,bb] = ind2sub(size(M),mindex);
% 
%         
%         hold off; imagesc(beta, hprime, 20*log10(abs(M))); axis xy; 
%         hold on;  plot(beta_est(tt),hprime_est(tt),'w*')
%         hold on;  plot(beta_est1(tt),hprime_est1(tt),'r*')
%         hold on;  plot(beta_est2(tt),hprime_est2(tt),'g*')
%         hold on;  plot(beta_est3(tt),hprime_est3(tt),'b*')
% 
%         
% 
%         thour = floor(tt/Fs/3600);
%         tminute = floor((tt-thour*Fs*3600)/Fs/60);
%         tsecond = floor((tt-thour*Fs*3600-tminute*Fs*60)/Fs);
%         title(sprintf('%0.2i:%0.2i:%0.2iUT',thour,tminute,tsecond))
%         caxis([-90 0])
%         drawnow
%         frameno = frameno +1;
%         F(frameno) = getframe(fig);  
%     end
end

%interpolate search space
hprimemin = hprime(1);
hprimedelta = hprime(2)-hprime(1);
hprimemax = hprime(end);
hprimeinterp = hprimemin:round(hprimedelta/4,2):hprimemax;

betamin = beta(1);
betadelta = beta(2)-beta(1);
betamax = beta(end);
betainterp = betamin:round(betadelta/4,4):betamax;

h0min = h_0(1);
h0delta = h_0(2)-h_0(1);
h0max = h_0(end);
h0interp = h0min:round(h0delta/10,2):h0max;


[BETA, HPRIME, H0] = meshgrid(beta, hprime, h_0);
[BETAINTERP, HPRIMEINTERP, H0INTERP] = meshgrid(betainterp, hprimeinterp, h0interp);

s1n = squeeze(s1(1,:,:,:)./s0(1,:,:,:));
s2n = squeeze(s2(1,:,:,:)./s0(1,:,:,:));
s3n = squeeze(s3(1,:,:,:)./s0(1,:,:,:));

s1n(isnan(s1n)) = 0;
s2n(isnan(s2n)) = 0;
s3n(isnan(s3n)) = 0;

s1ninterp = interp3(BETA,HPRIME,H0,s1n,BETAINTERP,HPRIMEINTERP,H0INTERP,'spline');
s2ninterp = interp3(BETA,HPRIME,H0,s2n,BETAINTERP,HPRIMEINTERP,H0INTERP,'spline');
s3ninterp = interp3(BETA,HPRIME,H0,s3n,BETAINTERP,HPRIMEINTERP,H0INTERP,'spline');

%find solutions in interpolated search space
for tt = 1:length(s0data)

%         M created using interpolated search space
    M = abs(squeeze(s1ninterp)-s1data(tt)./s0data(tt)).^2 + ...
        abs(squeeze(s2ninterp)-s2data(tt)./s0data(tt)).^2 + ...
        abs(squeeze(s3ninterp)-s3data(tt)./s0data(tt)).^2;
    M = M./3;
    [minval,mindex] = min(M,[],'all','linear');
    [hh,bb,mm] = ind2sub(size(M),mindex);
    
% %     M created using real search space, then M is in interpolated
%     M = abs(s1n-s1data(tt)./s0data(tt)).^2 + ...
%         abs(s2n-s2data(tt)./s0data(tt)).^2 + ...
%         abs(s3n-s3data(tt)./s0data(tt)).^2;
%     M = M./3;
%     Minterp = interp3(BETA,HPRIME,H0,M,BETAINTERP,HPRIMEINTERP,H0INTERP,'spline');
%     [minval,mindex] = min(Minterp,[],'all','linear');
%     [hh,bb,mm] = ind2sub(size(Minterp),mindex);

    minvals_chapinterp(tt) = minval;
    hprime_chapinterp(tt) = hprimeinterp(hh);
    beta_chapinterp(tt) = betainterp(bb);
    h0_chapinterp(tt) = h0interp(mm);
end

% %daytime error plot
% tt = round(length(s0data).*0.75)+1;
% M = abs(squeeze(s1(rxnum,:,:,:)./s0(rxnum,:,:,:))-s1data(tt)./s0data(tt)).^2 + ...
%         abs(squeeze(s2(rxnum,:,:,:)./s0(rxnum,:,:,:))-s2data(tt)./s0data(tt)).^2 + ...
%         abs(squeeze(s3(rxnum,:,:,:)./s0(rxnum,:,:,:))-s3data(tt)./s0data(tt)).^2;
% M = M./3;
% [minval,mindex] = min(M,[],'all','linear');
% [hh,bb,mm] = ind2sub(size(M),mindex);
% 
% figure; imagesc(beta,hprime,10*log10(abs(squeeze(M(:,:,mm))))); 
% hold on; plot(beta_chap(tt),hprime_chap(tt),'*w')
% axis xy
% colormap('gray')
% ylim([68 86])
% colorbar
% caxis([-70 0])
% 
% %nighttime error plot
% tt = round(length(s0data).*0.25)+3;
% M = abs(squeeze(s1(rxnum,:,:,:)./s0(rxnum,:,:,:))-s1data(tt)./s0data(tt)).^2 + ...
%         abs(squeeze(s2(rxnum,:,:,:)./s0(rxnum,:,:,:))-s2data(tt)./s0data(tt)).^2 + ...
%         abs(squeeze(s3(rxnum,:,:,:)./s0(rxnum,:,:,:))-s3data(tt)./s0data(tt)).^2;
% M = M./3;
% [minval,mindex] = min(M,[],'all','linear');
%     [hh,bb,mm] = ind2sub(size(M),mindex);
% 
% figure; imagesc(beta,hprime,10*log10(abs(squeeze(M(:,:,mm))))); 
% hold on; plot(beta_chap(tt),hprime_chap(tt),'*k')
% axis xy
% colormap('gray')
% ylim([68 86])
% colorbar
% caxis([-70 0])

%nighttime estimates of hprime
figure; subplot(2,1,1); plot(tplot, hprime_exp,'.k')
xlim([0 12])
ylim([70 85])
grid on
title(['Estimated Reflection Height h'' NAA-EG ' year '-' month '-' day])
ylabel('2-Parameter Exponential')

subplot(2,1,2); plot(tplot, hprime_chap,'.k')
xlim([0 12])
ylim([70 85])
grid on
ylabel('3-Parameter Chapman')
xlabel('Hours after 00:00 UTC')



% hold on; plot(tplot,10*log10(abs(minvals_chap)))


avgper = 5; %averaging period
linealpha = 0.6;



figure; subplot(2,1,1); plot(tplot,10*log10(abs(minvals_exp)),'color',[0 0 0]+linealpha)
hold on; plot(tplot,10*log10(movmean(abs(minvals_exp),avgper)),'k')
title('Stokes Parameters MSE of Best Fit Profile')
xlim([0 24])
ylim([-100 -20])
grid on
ylabel('2-Parameter MSE (dB)')

subplot(2,1,2); plot(tplot,10*log10(abs(minvals_chap)),'color',[0 0 0]+linealpha)
hold on; plot(tplot,10*log10(movmean(abs(minvals_chap),avgper)),'k')
xlim([0 24])
ylim([-100 -20])
grid on
ylabel('3-Parameter MSE (dB)')
xlabel('Hours after 00:00 UTC')

% figure; plot(tplot,10*log10(abs(minvals_exp./minvals_chap)),'.k')


