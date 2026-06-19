dist_max = 10000;
freak = 24;
save_path = 'C:\LWPCwin\';
hprime = 70;
beta = .4;
h_0 = 80;
txdata = 'NAA240';
range = 10e3;
% nu = 5e6*exp(-0.15*(h-70));
% wr = qe^2/eps0/me*en*100^3./nu;
rxlat = 41.945013;
rxlon =  72.727013;

qe = 1.602176634e-19; %C
eps0 = 8.8541878128e-12; %F/m
me = 9.1093837015e-31; %kg
wrprime = 2.5e5;



for hh=1:length(hprime)
    for bb=1:length(beta)
        for tt=1:length(h_0)
            h = [50:5:60, 62:2:86, 90:5:120];%h_0(tt)-20 :2 : h_0(tt)+4;
%             % h(h>h_0(tt)) = [];
%             if hprime(hh) >= h_0(tt)
%                 continue
%             end
%             basename = sprintf('%03.fb%03.fh%04.f',hprime(hh)*10,beta(bb)*1000,h_0(tt)*10);
%             filenames{hh,bb,tt} = basename;
% 
%             %calculate N_0 and H based on the given values
%             Htest = 5:.001:1000;
%             betatest = (0.75./Htest).*(exp(-((hprime(hh)-h_0(tt))./Htest))-1);
%             [~,betaind] = min(abs(betatest-beta(bb)));
% %             betaind = find(betatest-beta(bb) ==  min(abs(betatest-beta(bb))));
%             H = Htest(betaind);
% 
%             nuprime = 5e6*exp(-0.15*(hprime(hh)-70));
%             enprime = wrprime*nuprime*eps0*me./(qe.^2)./100.^3; %electron density at the reflection height in cm^-3
% 
%             zprime = (hprime(hh)-h_0(tt))./(H);
%             N_0 = enprime*exp(-0.5*(1-zprime-exp(-zprime)));
% 
%             z = (h-h_0(tt))./H;



            if hprime(hh) >= h_0(tt)
                continue
            end

            basename = sprintf('%03.fb%03.fh%04.f', ...
                hprime(hh)*10, beta(bb)*1000, h_0(tt)*10);

            filenames{hh,bb,tt} = basename;

            % calculate N_0 and H
            Htest = 5:0.001:1000;

            betatest = (0.75 ./ Htest) .* ...
                (exp(-((hprime(hh)-h_0(tt)) ./ Htest)) - 1);

            [~,betaind] = min(abs(betatest-beta(bb)));

            H = Htest(betaind);

            nuprime = 5e6 * exp(-0.15*(hprime(hh)-70));

            enprime = wrprime * nuprime * eps0 * me ./ ...
                (qe.^2) ./ 100.^3;

            % electron density at reflection height in cm^-3

            zprime = (hprime(hh)-h_0(tt)) ./ H;

            N_0 = enprime .* ...
                exp(-0.5 .* (1-zprime-exp(-zprime)));

            z = (h-h_0(tt)) ./ H;





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


for hh=1:length(hprime)
    for bb=1:length(beta)
        for tt=1:length(h_0)
            basename_prf = sprintf('%03.fb%03.fh%04.f',hprime(hh)*10,beta(bb)*1000,h_0(tt)*10);
            basename_inp = sprintf('%03.fb%03.fh%04.f',hprime(hh)*10,beta(bb)*1000,h_0(tt)*10);
            fid = fopen([save_path basename_inp '.inp'],'w');
            fprintf(fid,['case-id     AU Prop\n']);
            fprintf(fid,['tx          ' basename_inp '\n']);
            fprintf(fid,['tx-data      ' txdata '\n']);
                %% next line needs filepath fixed
            fprintf(fid,[sprintf('ionosphere  homogeneous table ./%s.prf\n',basename_inp)]);
            fprintf(fid,['range-max   %d\n'],range);
            fprintf(fid,[sprintf('receivers     %f   %f\n',rxlat,rxlon)]);
            fprintf(fid,['mc-options  full-wave 0 true\n']);
            fprintf(fid,['lwflds\n']);
            fprintf(fid,['print-mds   0\n']);
            fprintf(fid,['print-wf    2\n']);
            fprintf(fid,['print-lwf   2\n']);
            fprintf(fid,['print-swg   2\n']);
            fprintf(fid,['print-mc    1\n']);
            fprintf(fid,['start\n']);
            fprintf(fid,['quit']);
            fclose(fid);
        end
    end
end


[status, cmdout] = RunLWPC(basename_inp);