function xx = exp_write(savepath,hprime,beta,prf,txdata,rxlat,rxlon)


% txdata = 'NAA240';
% rxlat = 32.6082;
% rxlon = 85.4799;
for hh=1:length(hprime)
    for bb=1:length(beta)
        basename_inp = sprintf('%03.fb%03.f',hprime(hh)*10,beta(bb)*1000);
        fid = fopen([savepath basename_inp '.inp'],'w');
        fprintf(fid,['case-id     AU Prop\n']);
        fprintf(fid,['tx          ' basename_inp '\n']);
        fprintf(fid,['tx-data      ' txdata '\n']);
            %% next line needs filepath fixed
        fprintf(fid,[sprintf('ionosphere  homogeneous table ./%s.prf\n',prf{hh,bb})]);
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
