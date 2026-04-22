angle_step = 0.1;
dist_max = 10000;
angle_min = 230;
angle_max = 270;
freak = 24;
paths = 'C:\LWPCwin\';
% cleanup(0);
% clean_w(1);
hprime = 72.6;
beta = .4005;
h_0 = 110;%80:2:100;

xmtr_loc = [44.633,67.283]; % NAA, Cutler
% xmtr_loc = [46.366   98.336]; % NLK, Jim Creek
% rxvr_loc = [32.466224, 85.470938]; % Auburn
% rxvr_loc = [62.567234209170635, 144.66236353401382]; % Chistochina
rxvr_loc = [41.945013, 72.727013]; % East Granby
TXdata = {"NAA240"};

runname = chapman_prf(paths,hprime,beta,h_0);

basename_prf = sprintf('%03.fb%03.fh%04.f',hprime*10,beta*1000,h_0*10);
basename_inp = 'TestRun';%sprintf('%03.fb%03.fh%04.f',hprime(hh)*10,beta(bb)*1000,h_0(tt)*10);
fid = fopen([paths basename_inp '.inp'],'w');
fprintf(fid,['case-id     AU Prop\n']);
fprintf(fid,['tx          ' basename_inp '\n']);
fprintf(fid,['tx-data      ' 'NAA240' '\n']);
    %% next line needs filepath fixed
fprintf(fid,[sprintf('ionosphere  homogeneous table ./%s.prf\n',basename_prf)]);
fprintf(fid,['range-max   %d\n'],dist_max);
fprintf(fid,[sprintf('receivers     %f   %f\n',rxvr_loc(1),rxvr_loc(2))]);
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

[status, cmdout] = RunLWPC(basename_inp);

[s0,s1,s2,s3, hx,hy] = ...
                lw_vs_d_function(paths,basename_inp,freak,dist_max);
ns1 = s1./s0;
ns2 = s2./s0;
ns3 = s3./s0;