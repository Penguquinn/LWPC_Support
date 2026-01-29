%This script will copy the utility of the Fortran LW_SUM_MODES subroutine

function [amp,phs] = lw_sum_modes(power,dist_var,nc)
% clearvars
% close all
% fclose all;
% output_path = 'C:\hcburch\Research\Leidos\waveguide_fields\outputs\';
% log_file = 'lwpm-python-10602-S9M26X.log';    %NAA
% log_file = 'lwpm-python-40514-Z2MWJ4.log';    %NAA
% log_file = 'lwpm-python-56560-9Z6WOO.log';      %NML
% log_file = 'lwpm-python-56560-9Z6WOO_precise.log';      %NML with high precision outputs

% [rho, sigma, epsr, eigen, eigens, ht, Ex_mag, Ex_ang, Ey_mag, Ey_ang, Ez_mag, Ez_ang, ...
%     Hx_mag, Hx_ang, Hy_mag, Hy_ang, Hz_mag, Hz_ang, fofr, T1, T2, T3, T4, Amk] ...
%     = read_output_lwpv3_T_fofr(output_path, log_file);
dtr = pi/180;   %change degrees to radians in eigenangle formulas
rtd = 180/pi;

load('output_file.mat');

switch nc
    case 1
        fieldmag = Ez_mag;
        fieldang = Ez_ang;
    case 2
        fieldmag = Ey_mag;
        fieldang = Ey_ang;
    case 3
        fieldmag = Ex_mag;
        fieldang = Ex_ang;
    case 4
        fieldmag = Hz_mag;
        fieldang = Hz_ang;
    case 5
        fieldmag = Hy_mag;
        fieldang = Hy_ang;
    case 6
        fieldmag = Hx_mag;
        fieldang = Hx_ang;
end

Amk{1} = eye(length(eigens{1}));

mik = complex(0,-k);
aconst = -8686*k;
econst=20.*log10(35.*k);
sum0=682.2408*sqrt(f*power);
const = sum0;



xone = 0;
if length(rho)>1
    xtwo = rho(2);
else
    xtwo = dist_var;
end
t = [1 0 0]; %antenna orientation factors; 1-0-0 is a vertical dipole
nsgmnt = 1; %starting in the first slab
nreigen2 = length(eigens{1});
for neigen = 1:nreigen2
    tp(neigen) = eigens{1}(neigen);
    stp(neigen) = sin(tp(neigen).*dtr);
    eyhy(neigen) = fofr(1,neigen);
    xtra(1,neigen) = -T1(1,neigen).*stp(neigen);
    xtra(2,neigen) = T3(1,neigen).*T4(1,neigen);
    xtra(3,neigen) = T1(1,neigen);
end
phs1 = 0;
cycle = 0;

for m2 = 1:nreigen2
    %Hy excitation factor
    ta = xtra(1,m2);
    soln_a(m2) = ta;
    
    %Ez excitation factor
%     tb = -stp(m2).*ta;
    tb = -ta;
    soln_b(1,m2) = tb.*fieldmag(1,1,m2).*exp(sqrt(-1).*fieldang(1,1,m2));
end

while dist_var>xtwo     %passed the end of the slab
    mikx = mik*(xtwo-xone);
    nreigen1 = nreigen2;
    for m1 = 1:nreigen1
        soln_a(m1) = soln_a(m1).*exp(mikx*(stp(m1)-1));
        temp(m1)   = soln_a(m1);
    end
    
    xone = xtwo;
    nsgmnt = nsgmnt + 1;
    if nsgmnt+1 > length(rho)
        xtwo = 10000;
    else
        xtwo = rho(nsgmnt+1);
    end
    nreigen2 = length(eigens{nsgmnt});
    
    for neigen = 1:nreigen2
        tp(neigen) = eigens{nsgmnt}(neigen);
        stp(neigen) = sin(tp(neigen).*dtr);
        eyhy(neigen) = fofr(nsgmnt,neigen);
    end
    [nreigen2, nreigen1] = size(Amk{nsgmnt}); %added to correct for dropped modes
    for m2 = 1:nreigen2
        %Hy excitation factor
        soln_a(m2) = 0;
        for m1=1:nreigen1
            soln_a(m2) = soln_a(m2) + temp(m1)*Amk{nsgmnt}(m2,m1);
        end
        ta = soln_a(m2);

        %Ez excitation factor
%         tb = -stp(m2).*ta;
        tb = -ta;
        soln_b(1,m2) = tb.*fieldmag(1,nsgmnt,m2).*exp(sqrt(-1).*fieldang(1,nsgmnt,m2));
    end
end

mikx = mik*(dist_var-xone);
factor = const/sqrt(abs(sin(dist_var/a)));

tb = 0;
for m2 = 1:nreigen2
    tb = tb + soln_b(1,m2)*exp(mikx*(stp(m2)-1))*factor;
end

amp = 20*log10(abs(tb));
% phs = (angle(tb))*rtd;

phs2 = angle(tb)*rtd;
if abs(phs1-phs2)>180
    if phs1 < phs2
        cycle = cycle-360;
    else
        cycle = cycle + 360;
    end
end
phs1 = phs2;
phs = phs2+cycle;

if dist_var==0
    amp = 20*log10(const*80);
    phs = 0;
end

















    