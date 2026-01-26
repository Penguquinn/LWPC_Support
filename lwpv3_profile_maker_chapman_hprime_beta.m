save_path = '\\wsl.localhost\Ubuntu\home\qdh0004\git_repos\LWPC\LWPCv21\input\';

% h = 50:5:100;
 
% hprime = 68:.2:87;
% beta = 0.25:0.005:0.66;
% h_0 = 100;

% %expand search space in beta
% hprime = 68:.2:87;
% beta = 0.15:0.005:0.25-0.005;
% h_0 = 100;

% hprime = 76;
% beta = 0.6;

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




% nu = 5e6*exp(-0.15*(h-70));
% wr = qe^2/eps0/me*en*100^3./nu;

qe = 1.602176634e-19; %C
eps0 = 8.8541878128e-12; %F/m
me = 9.1093837015e-31; %kg
wrprime = 2.5e5;

for hh=1:length(hprime)
    for bb=1:length(beta)
        for tt=1:length(h_0)
            h = 50:5:100;
            
            basename = sprintf('%03.fb%03.fh%04.f',hprime(hh)*10,beta(bb)*1000,h_0(tt)*10);
            
            %calculate N_0 and H based on the given values
            Htest = 5:.01:25;
            betatest = (0.5./Htest).*(exp(-((hprime(hh)-h_0(tt))./Htest))-1);
            [~,betaind] = min(abs(betatest-beta(bb)));
%             betaind = find(betatest-beta(bb) ==  min(abs(betatest-beta(bb))));
            H = Htest(betaind);
            
            nuprime = 5e6*exp(-0.15*(hprime(hh)-70));
            enprime = wrprime*nuprime*eps0*me./(qe.^2)./100.^3; %electron density at the reflection height in cm^-3
            
            zprime = (hprime(hh)-h_0(tt))./(H);
            N_0 = enprime*exp(-0.5*(1-zprime-exp(-zprime)));
        
            z = (h-h_0(tt))./H;
            en = N_0.*exp(0.5.*(1-z-exp(-z)));
            en = [0 0 en];
            en = fliplr(en);
            h = [-99.99 0 h];
            h = fliplr(h);
            prof = zeros(2,length(h));
            prof(1,:) = h;
            prof(2,:) = en;
            fid = fopen([save_path basename '.prf'],'w+');
            fprintf(fid, [basename '_prfl\n']);
            fprintf(fid,'SPECIES   1\n');
            fprintf(fid,'CHARGE   -1\n');
            fprintf(fid,'MASS-RATIO    1\n');
            fprintf(fid,'MODEL-PRF FORMATTED\n');
%             fprintf(fid,'COEFF-NU      27500000000.0\n');
%             fprintf(fid,'EXP-NU         -0.18\n');
            fprintf(fid,'DENSITY-TABLE\n');
            fprintf(fid, sprintf('   %.5f   \t%.5f\r\n',prof));
            fprintf(fid,'MODEL-PRF FORMATTED\n');
            fclose(fid);
        
        end
    end
end