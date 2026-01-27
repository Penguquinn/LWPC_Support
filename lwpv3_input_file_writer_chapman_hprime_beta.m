clearvars
fclose all;


savepath = '\\wsl.localhost\Ubuntu\home\qdh0004\git_repos\LWPC\LWPCv21\instruct\';

% h_0 = 90:150;
% logno = 5:10; %log of electron density at reference height
% H = 5:25;
% h_0 = 90:0.5:150;
% logno = 8; %log of electron density at reference height
% H = 5:0.2:25;

% hprime = 68:.2:87;
% beta = 0.25:0.005:0.66;
% % h_0 = 95:105;
% h_0 = 100;

% %expand search space in beta
% hprime = 68:.2:87;
% beta = 0.15:0.005:0.25-0.005;
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

% %NAA to EG
% txname = 'NAA';
% txdata = 'NAA240';
% rxname = 'EG';
% rxlat = 41.9508333;
% rxlon = 72.7235556;
% rxdist = 532;
% for hh=1:length(hprime)
%     for bb=1:length(beta)
%         for tt=1:length(h_0)
%             basename_prf = sprintf('%03.fb%03.fh%04.f',hprime(hh)*10,beta(bb)*1000,h_0(tt)*10);
%             basename_inp = sprintf('%03.fb%03.fh%04.f_%s-%s',hprime(hh)*10,beta(bb)*1000,h_0(tt)*10,txname,rxname);
%             fid = fopen([savepath rxname '\' basename_inp '.inp'],'w');
%             fprintf(fid,['case-id     run_lwpm() Python\n'...
%                 'tx          ' basename_inp '\n'...
%                 'tx-data      ' txdata '\n'...
%                 sprintf('ionosphere  homogeneous table /blue/moore/hcburch/lwpv3/test/p/%s.prf\n',basename_prf)...
%                 'range-max   550.0\n'...
%                 sprintf('receivers     %f   %f\n',rxlat,rxlon)...
%                 'mc-options  full-wave 0 true\n'...
%                 'lwflds\n'...
%                 'print-mds   0\n'...
%                 'print-wf    2\n'...
%                 'print-lwf   2\n'...
%                 'print-swg   2\n'...
%                 'print-mc    1\n'...
%                 'start\n'...
%                 'quit']);
%             fclose(fid);
%         end
%     end
% end

% %NAA to CN
% txname = 'NAA';
% txdata = 'NAA240';
% rxname = 'CN';
% rxlat = 35.966661;
% rxlon = 79.096591;
% for nn=1:length(logno)
%     for hh=1:length(h_0)
%         for ss=1:length(H)
%             basename_inp = sprintf('%03.fn%02.fs%02.f_%s-%s',h_0(hh),logno(nn),H(ss),txname,rxname);
%             basename_prf = sprintf('%03.fn%02.fs%02.f',h_0(hh),logno(nn),H(ss));
%             fid = fopen([savepath rxname '\' basename_inp '.inp'],'w');
%             fprintf(fid,['case-id     run_lwpm() Python\n'...
%                 'tx          ' basename_inp '\n'...
%                 'tx-data      ' txdata '\n'...
%                 sprintf('ionosphere  homogeneous table /blue/moore/hcburch/lwpv3/test/p/%s.prf\n',basename_prf)...
%                 'range-max   2200.0\n'...
%                 sprintf('receivers     %f   %f\n',rxlat,rxlon)...
%                 'mc-options  full-wave 0 true\n'...
%                 'lwflds\n'...
%                 'print-mds   0\n'...
%                 'print-wf    2\n'...
%                 'print-lwf   2\n'...
%                 'print-swg   2\n'...
%                 'print-mc    1\n'...
%                 'start\n'...
%                 'quit']);
%             fclose(fid);
%         end
%     end
% end
% 
%NAA to CB
txname = 'NAA';
txdata = 'NAA';
rxname = 'AU';
rxlat = 32.6082;
rxlon = 85.4799;
for hh=1:length(hprime)
    for bb=1:length(beta)
        for tt=1:length(h_0)
            basename_prf = sprintf('%03.fb%03.fh%04.f',hprime(hh)*10,beta(bb)*1000,h_0(tt)*10);
            basename_inp = sprintf('%03.fb%03.fh%04.f_%s-%s',hprime(hh)*10,beta(bb)*1000,h_0(tt)*10,txname,rxname);
            fid = fopen([savepath basename_inp '.inp'],'w');
            fprintf(fid,['case-id     run_lwpm() Python\n']);
            fprintf(fid,['tx          ' basename_inp '\n']);
            fprintf(fid,['tx-data      ' txdata '\n']);
                %% next line needs filepath fixed
            fprintf(fid,[sprintf('ionosphere  homogeneous table /home/qdh0004/git_repos/LWPC/LWPCv21/inputs/%s.prf\n',basename_prf)]);
            fprintf(fid,['range-max   2200.0\n']);
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

% %NAA to CB
% for n=1:length(hprime)
%     for m=1:length(beta)
%         for nn=1:length(coefnu)
%             for mm=1:length(expnu)
%                 fid = fopen([savepath 'NAA\' sprintf('%1$03.fb%2$02.f-%3$04.fb%4$4.f_NAA.lwpc',...
%                     hprime(n)*10,beta(m)*100,log(coefnu(nn))*100,abs(expnu(mm)*10000))],'w');
%                 fprintf(fid,['/ufrc/moore/hcburch/LWW/LWW/gtest/\n'...
%                     '1\n'...
%                     sprintf('/ufrc/moore/hcburch/LWW/LWW/p/d/%1$03.fb%2$02.f.prof\n',hprime(n)*10,beta(m)*100)...
%                     '1\n'...
%                     sprintf('/ufrc/moore/hcburch/LWW/LWW/p/c/%1$04.fb%2$4.f.prof\n',log(coefnu(nn))*100,abs(expnu(mm)*10000))...
%                     'RUN1\n'...
%                     'RUN11\n'...
%                     ' &datum\n'...
%                     ' power=1 freq=24.000 trlat=44.63573 trlong=67.22993\n'...
%                     ' rclat=29.943 rclong=82.029\n'...
%                     ' max_alt=100\n'...
%                     ' insphtype0=(1,1)\n'... 
%                     ' &end']);
%                 fclose(fid);
%             end
%         end
%     end
% end
