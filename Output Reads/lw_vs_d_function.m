%This script will copy the utility of the Fortran LW_VS_D subroutinedst


function [s0,s1,s2,s3,hx,hy]=lw_vs_d_function(output_path,log_file,f,rho_full)
% f = 25.2; txname = 'NLM'; %transmitter frequency in kHz
power = 1;
pi = 3.1415926535897932385;
w = 2*pi*f*1000; %rad/s
c = 299792458; %m/s
k = w/c; %rad/m
k = k*1000; %rad/km
a = 6370; %radius of earth in km
alpha = 2/a; %in km
eps0 = 8.8541878176203898505e-9; %permittivity of free space in F/km

dtr = pi/180;   %change degrees to radians in eigenangle formulas
rtd = 180/pi;

% fclose all;
% output_path = [filepathing_wsl(),'input\'];
% log_file = 'CircProp210.log';

[rho, sigma, epsr, eigen, eigens, ht, Ex_mag, Ex_ang, Ey_mag, Ey_ang, Ez_mag, Ez_ang, ...
    Hx_mag, Hx_ang, Hy_mag, Hy_ang, Hz_mag, Hz_ang, fofr, T1, T2, T3, T4, Amk] ...
    = read_output_lwpv3_T_fofr(output_path, [log_file,'.log']);

data = struct( ...
    'rho', rho, ...
    'sigma', sigma, ...
    'epsr', epsr, ...
    'eigen', eigen, ...
    'ht', ht, ...
    'Ex_mag', Ex_mag, 'Ex_ang', Ex_ang, ...
    'Ey_mag', Ey_mag, 'Ey_ang', Ey_ang, ...
    'Ez_mag', Ez_mag, 'Ez_ang', Ez_ang, ...
    'Hx_mag', Hx_mag, 'Hx_ang', Hx_ang, ...
    'Hy_mag', Hy_mag, 'Hy_ang', Hy_ang, ...
    'Hz_mag', Hz_mag, 'Hz_ang', Hz_ang, ...
    'fofr', fofr, ...
    'T1', T1, 'T2', T2, 'T3', T3, 'T4', T4, ...
    'k', k, ...
    'f', f, ...
    'a', a);
    


nrpts = 1000;
rho_max = max(rho);
rho_full = 0:rho_max/nrpts:rho_max;

% for rho_ind = 1:length(rho_full)
%     for nc = 1:6 %1=Ez, 2=Ey, 3=Ex, 4=Hz, 5=Hy, 6=Hx
%         [amp,phs] = lw_sum_modes(power,rho_full(rho_ind),nc,data,eigens,Amk);
%         aa(rho_ind,nc) = amp;
%         pp(rho_ind,nc) = phs;
%     end
% end

[aa,pp] = efficient_lw_sum_modes(power, rho_full,data,eigens,Amk);

aa_linear = 10.^(aa./20);
cmplx_flds = aa_linear.*exp(1j.*pp.*pi/180);
hx = cmplx_flds(:,6);
hy = cmplx_flds(:,5);

s0 = abs(hx).^2 + abs(hy).^2;
s1 = abs(hx).^2 - abs(hy).^2;
s2 = 2*real(hx.*conj(hy));
s3 = 2*imag(hx.*conj(hy));

end