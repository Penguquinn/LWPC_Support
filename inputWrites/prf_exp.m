function filenames = prf_exp(save_path,hprime,beta)


% save_path = '\\wsl.localhost\Ubuntu-24.04\home\quinn\work\v3.0.1\profile\';
        
%h = 50:5:100;
% hprime = 70:2:90;
% beta = 0.4:0.02:0.6;

% hprime = 70;
% beta = .3;

% hprime = 74; 
% beta = 0.50; 

for n=1:length(hprime)
    for m=1:length(beta)
        h = [20:5:75 77:2:120];
%         hprime = 70:2:90;
%         beta = 0.4:0.02:0.6;
        en = 1.43*1e7*exp(-0.15*hprime(n))*exp((beta(m)-0.15)*(h-hprime(n)));
        en = [0 0 en];
        en = fliplr(en);
        h = [-99.99 0 h];
        h = fliplr(h);
        prof = zeros(2,length(h));
        prof(1,:) = h;
        prof(2,:) = en;
        filenames{n,m} = sprintf('%03.fb%02.f',hprime(n)*10,beta(m)*1000);
        fid = fopen([save_path filenames{n,m} '.prf'],'w+');
        fprintf(fid, '750b470_prfl\n');
        fprintf(fid,'SPECIES   1\n');
            fprintf(fid,'CHARGE   -1\n');
            fprintf(fid,'MASS-RATIO    1\n');
            fprintf(fid,'MODEL-PRF FORMATTED\n');
            fprintf(fid,'DENSITY-TABLE\n');
        fprintf(fid, sprintf('   %.5f   \t%.5f\r\n',prof));
        fprintf(fid,'MODEL-PRF FORMATTED\n');
        fclose(fid);
    end
end
end
% height = 100:-10:50;
% hpr = 84.0;
% betta = 0.40;
% Ne = 1.43*1e7*exp(-0.15*hpr)*exp((betta-0.15)*(height-hpr))