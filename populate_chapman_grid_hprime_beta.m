%this script will read output files for a grid of hprime and beta values
%and store 6 field values at each site as a function of hprime and beta.
%dependencies: read_output_lwpv3_T_fofr.m, lw_sum_modes

clearvars

fclose all;
% output_path = 'C:\hcburch\Research\Dissertation\Prelminary_work\outputs\';
%for use on local machine
% output_path = 'F:\polarization_lwpc_outputs_2020-08-10\chapman\parameterized\EG\';

%for use on HPC
output_path = '/blue/moore/hcburch/lwpv3/test/outputs/chapman/parameterized/EG/';

f = 24.0; txname = 'NAA';
power = 1;
w = 2*pi*f*1000; %rad/s
c = 299792458; %m/s
k = w/c; %rad/m
k = k*1000; %rad/km
a = 6370; %radius of earth in km
alpha = 2/a; %in km
eps0 = 8.8541878176203898505e-9; %permittivity of free space in F/km
pi = 3.1415926535897932385;
dtr = pi/180;   %change degrees to radians in eigenangle formulas
rtd = 180/pi;


% hprime = 68:.2:87;
% beta = 0.15:0.005:0.66;
% % h_0 = 95:105;
% h_0 = 100;

% %evaluate role of h_0 in daytime
% hprime = 73;
% beta = 0.3;
% h_0 = 75:0.1:150;

% %evaluate role of h_0 in nighttime
% hprime = 86;
% beta = 0.44;
% h_0 = 86:0.1:200;

% create a 3-parameter search space
hprime = 68.0:0.2:90.0;
beta = 0.300:0.005:0.660;
h_0 = 75.0:1:110.0;


rxnames = {'EG';'CN';'CB'};
rxname = 'EG';
rxdists = [532,1388,2084];
% rxdists = [2084];
% Ex = zeros(length(rxdists),length(hprime),length(beta));
% Ey = zeros(length(rxdists),length(hprime),length(beta));
% Ez = zeros(length(rxdists),length(hprime),length(beta));
% Hx = zeros(length(rxdists),length(hprime),length(beta));
% Hy = zeros(length(rxdists),length(hprime),length(beta));
% Hz = zeros(length(rxdists),length(hprime),length(beta));
filecounter = 0;

%     rxname = rxnames{rr};
for hh=1:length(hprime)
    for bb=1:length(beta)
        for tt=1:length(h_0)

%                 filecounter = filecounter +1;
            basename = sprintf('%03.fb%03.fh%04.f_%s-%s',hprime(hh)*10,beta(bb)*1000,h_0(tt)*10,txname,rxname);
            %specify log file
            log_file = [basename '.log'];
            %read values from log file and save to temp output file
            [rho, sigma, epsr, eigen, eigens, ht, Ex_mag, Ex_ang, Ey_mag, Ey_ang, Ez_mag, Ez_ang, ...
                Hx_mag, Hx_ang, Hy_mag, Hy_ang, Hz_mag, Hz_ang, fofr, T1, T2, T3, T4, Amk] ...
                = read_output_lwpv3_T_fofr(output_path, log_file);

            save('output_file.mat','rho', 'sigma', 'epsr', 'eigen', 'eigens',...
                'ht', 'Ex_mag', 'Ex_ang', 'Ey_mag', 'Ey_ang', 'Ez_mag', 'Ez_ang', ...
                'Hx_mag', 'Hx_ang', 'Hy_mag', 'Hy_ang', 'Hz_mag', 'Hz_ang', 'fofr',...
                'T1', 'T2', 'T3', 'T4', 'Amk','k','f','a')

            for rr = 1:length(rxdists)  %for each receiver
                rxdist = rxdists(rr);
                filecounter = filecounter +1;
                %sum modes at receiver location for all components
                for nc = 1:6 %1=Ez, 2=Ey, 3=Ex, 4=Hz, 5=Hy, 6=Hx
                    [amp,phs] = lw_sum_modes(power,rxdist,nc);
                    aa(nc) = 10.^(amp./20); %make amplitude linear
                    pp(nc) = phs; %phase in degrees
                end
            

                %make an array of 6 complex-valued fields indexed by (rr,hh,bb)
                Ez(rr,hh,bb,tt) = aa(1).*exp(complex(0,pp(1)*dtr));
                Ey(rr,hh,bb,tt) = aa(2).*exp(complex(0,pp(2)*dtr));
                Ex(rr,hh,bb,tt) = aa(3).*exp(complex(0,pp(3)*dtr));
                Hz(rr,hh,bb,tt) = aa(4).*exp(complex(0,pp(4)*dtr));
                Hy(rr,hh,bb,tt) = aa(5).*exp(complex(0,pp(5)*dtr));
                Hx(rr,hh,bb,tt) = aa(6).*exp(complex(0,pp(6)*dtr));
            end

%                 rr
%                 hh
%                 nn
%                 ss
        end
        sprintf('File number: %i/%i',filecounter, length(rxdists)*length(hprime)*length(h_0)*length(beta))
        sprintf('Progress: %f %%',100*filecounter./(length(rxdists)*length(hprime)*length(h_0)*length(beta)))
    end
end


save('sixfields_chapman_hbh0_NAA-EG.mat','h_0','hprime','beta','txname','rxnames','rxdists','Ez','Ey','Ex','Hz','Hy','Hx');

%calculate polarization in x-y plane
for rr = 1:length(rxdists)
    s0(rr,:,:,:) =  abs(Hx(rr,:,:,:)).^2 + abs(Hy(rr,:,:,:)).^2;
    s1(rr,:,:,:) =  abs(Hx(rr,:,:,:)).^2 - abs(Hy(rr,:,:,:)).^2;
    s2(rr,:,:,:) =  2.*real(Hx(rr,:,:,:).*conj(Hy(rr,:,:,:)));
    s3(rr,:,:,:) = -2.*imag(Hx(rr,:,:,:).*conj(Hy(rr,:,:,:)));
end

save('lwpc_polarization_chapman_hbh0_NAA-EG.mat','h_0','hprime','beta','txname','rxnames','rxdists','s0','s1','s2','s3')

figure
for tt = 10:length(h_0)
    imagesc(beta,hprime,abs(squeeze(s3(1,:,:,tt)./s0(1,:,:,tt))))
    axis xy
    caxis([0 1])
    title(sprintf('h_0 = %f',h_0(tt)))
    yline(h_0(tt),'r')
    pause(0.5)
end
