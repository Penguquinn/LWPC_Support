function basename_inp = lwpv3_input_file_writer_chapman_hprime_beta(savepath,hprime, beta, h_0, txname, txdata, rxlat, rxlon,rxname)

for hh=1:length(hprime)
    for bb=1:length(beta)
        for tt=1:length(h_0)
            basename_prf = sprintf('%03.fb%03.fh%04.f',hprime(hh)*10,beta(bb)*1000,h_0(tt)*10);
            basename_inp{hh,bb,tt} = sprintf('%03.fb%03.fh%04.f_%s-%s',hprime(hh)*10,beta(bb)*1000,h_0(tt)*10,txname,rxname);
            fid = fopen([savepath basename_inp{hh,bb,tt} '.inp'],'w');
            fprintf(fid,['case-id     Chapman Grid Test\n']);
            fprintf(fid,['tx          ' basename_inp{hh,bb,tt} '\n']);
            fprintf(fid,['tx-data      ' txdata '\n']);
                %% next line needs filepath fixed
            fprintf(fid, 'ionosphere  homogeneous table ./%s\n', [basename_prf '.prf']);
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
end
