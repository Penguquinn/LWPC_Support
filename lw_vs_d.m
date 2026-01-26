%This script will copy the utility of the Fortran LW_VS_D subroutine

% clearvars

f = 24.0; txname = 'NAA';
% f = 25.2; txname = 'NLM'; %transmitter frequency in kHz
power = 1;
w = 2*pi*f*1000; %rad/s
c = 299792458; %m/s
k = w/c; %rad/m
k = k*1000; %rad/km
% k = k.*.985; %correction factor of unknown origin
a = 6370; %radius of earth in km
% a = a*1e3;  %in m
alpha = 2/a; %in km
eps0 = 8.8541878176203898505e-9; %permittivity of free space in F/km
pi = 3.1415926535897932385;
dtr = pi/180;   %change degrees to radians in eigenangle formulas
rtd = 180/pi;

fclose all;
output_path = '\\wsl.localhost\Ubuntu\home\qdh0004\git_repos\LWPC\LWPCv21\';
log_file = 'bearings.log';

[rho, sigma, epsr, eigen, eigens, ht, Ex_mag, Ex_ang, Ey_mag, Ey_ang, Ez_mag, Ez_ang, ...
    Hx_mag, Hx_ang, Hy_mag, Hy_ang, Hz_mag, Hz_ang, fofr, T1, T2, T3, T4, Amk] ...
    = read_output_lwpv3_T_fofr(output_path, log_file);

save('output_file.mat','rho', 'sigma', 'epsr', 'eigen', 'eigens',...
                'ht', 'Ex_mag', 'Ex_ang', 'Ey_mag', 'Ey_ang', 'Ez_mag', 'Ez_ang', ...
                'Hx_mag', 'Hx_ang', 'Hy_mag', 'Hy_ang', 'Hz_mag', 'Hz_ang', 'fofr',...
                'T1', 'T2', 'T3', 'T4', 'Amk','k','f','a')


nrpts = 1000;
rho_max = max(rho);
rho_full = 0:rho_max/nrpts:rho_max;

for rho_ind = 1:length(rho_full)
    for nc = 1:6 %1=Ez, 2=Ey, 3=Ex, 4=Hz, 5=Hy, 6=Hx
        [amp,phs] = lw_sum_modes(power,rho_full(rho_ind),nc);
        aa(rho_ind,nc) = amp;
        pp(rho_ind,nc) = phs;
    end
end

aa_linear = 10.^(aa./20);
cmplx_flds = aa_linear.*exp(1j.*pp.*pi/180);
hx = cmplx_flds(:,6);
hy = cmplx_flds(:,5);

s0 = abs(hx).^2 + abs(hy).^2;
s1 = abs(hx).^2 - abs(hy).^2;
s2 = 2*real(hx.*conj(hy));
s3 = 2*imag(hx.*conj(hy));

%calculate stokes parameters along the path
% aa_linear = 10.^(aa./20);
% s0 = abs(aa_linear(:,6)).^2 + abs(aa_linear(:,5)).^2;
% s1 = abs(aa_linear(:,6)).^2 - abs(aa_linear(:,5)).^2;
% s2 = 2*real(aa_linear(:,6).*exp(complex(0,pp(:,6))).*aa_linear(:,5).*exp(complex(0,-pp(:,5))));
% s3 = -2*imag(aa_linear(:,6).*exp(complex(0,pp(:,6))).*aa_linear(:,5).*exp(complex(0,-pp(:,5))));



figure; plot(rho_full,s1./s0)
hold on; plot(rho_full,s2./s0)
hold on; plot(rho_full,s3./s0)
yline(0)
title('Stokes parameters normalized by S_0')
xlabel('Distance from transmitter (km)')
ylabel('Normalized magnitude')
legend('S_1 (Q)','S_2 (U)','S_3 (V)')

figure; plot(rho_full,10*log10(abs(s0)))
hold on; plot(rho_full,10*log10(abs(s1)))
hold on; plot(rho_full,10*log10(abs(s2)))
hold on; plot(rho_full,10*log10(abs(s3)))
xline(532); xline(1388); xline(2084);
title('Stokes parameters, log scale')
xlabel('Distance from transmitter (km)')
ylabel('Amplitude (dB)')
legend('S_0 (I)','S_1 (Q)','S_2 (U)','S_3 (V)')
xlim([0 2200])


figure; plot(rho_full,20*log10(abs(s1./s0)))
hold on; plot(rho_full,20*log10(abs(s2./s0)))
hold on; plot(rho_full,20*log10(abs(s3./s0)))
xline(532); xline(1388); xline(2084);
title('Stokes parameters normalized by S_0, log scale')
xlabel('Distance from transmitter (km)')
ylabel('Normalized amplitude (dB)')
legend('S_1 (Q)','S_2 (U)','S_3 (V)')
xlim([0 2200])



% [dist, amplitude, phase] = read_output_lwpv3_fields_vs_dist(output_path, log_file);
% ufamp = aa(:,1);
% ufphs = pp(:,1);
% ss = find(ufphs<0);
% ufphs(ss) = ufphs(ss)+360;
% ufphs = unwrap(ufphs*dtr)*rtd;
% 
% amp_err = ufamp-amplitude;
% mean_amp_err = repmat(mean(amp_err(2:end),'omitnan'),size(amplitude));
% std_amp_err = repmat(std(amp_err(2:end),'omitnan'),size(amplitude));
% 
% phs_err = ufphs-phase;
% mean_phs_err = repmat(mean(phs_err,'omitnan'),size(amplitude));
% std_phs_err = repmat(std(phs_err,'omitnan'),size(amplitude));

% figure
% subplot(2,1,1)
% plot(dist,amplitude)
% hold on
% % for bound = 1:length(rho)
% %     line([rho(bound) rho(bound)],[0 100])
% % end
% plot(rho_full, ufamp-mean_amp_err)
% % plot(rho_full, ufamp-(ufamp(2)-amplitude(2)))
% % plot(rho_full, 20*log10(abs(Ez_wvgd(1,:)))-20*log10(abs(Ez_wvgd(1,2)))+amplitude(2))
% title(sprintf('%s to CB; E_z at z=0',txname))
% xlabel('Distance (km)')
% ylabel('Amplitude (dB)')
% legend('LWPC Output','UF Method')
% 
% subplot(2,1,2)
% plot(dist,phase)
% % plot(dist,wrapTo2Pi(dtr*phase)*rtd)
% hold on
% % for bound = 1:length(rho)
% %     line([rho(bound) rho(bound)],[-400 400])
% % end
% plot(rho_full, ufphs)
% % title('E_z at z=0')
% xlabel('Distance (km)')
% ylabel('Phase (Degrees)')

% figure
% subplot(2,1,1)
% plot(dist,amp_err-mean_amp_err)
% hold on
% % for bound = 1:length(rho)
% %     line([rho(bound) rho(bound)],[-2 2])
% % end
% plot(dist, std_amp_err,'r')
% plot(dist, -std_amp_err,'r')
% ylim([-2 2])
% title(sprintf('%s to CB; E_z at z=0',txname))
% xlabel('Distance (km)')
% ylabel('Amplitude Error (dB)')
% 
% subplot(2,1,2)
% plot(dist,(phs_err))
% hold on
% % for bound = 1:length(rho)
% %     line([rho(bound) rho(bound)],[-20 20])
% % end
% plot(dist, mean_phs_err+std_phs_err,'r')
% plot(dist, mean_phs_err-std_phs_err,'r')
% ylim([-20 20])
% % title('E_z at z=0')
% xlabel('Distance (km)')
% ylabel('Phase Error (Degrees)')