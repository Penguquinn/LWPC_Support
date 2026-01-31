save_path = 'C:\hcburch\Research\Dissertation\Preliminary_work\profiles\';
        
h = 50:10:100;
% hprime = 70:2:90;
% beta = 0.4:0.02:0.6;

hprime = 68:.1:87;
beta = 0.3:0.002:0.66;

% hprime = 74; 
% beta = 0.50; 

for n=1:length(hprime)
    for m=1:length(beta)
        h = 50:10:100;
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
        fid = fopen([save_path sprintf('%03.fb%02.f',hprime(n)*10,beta(m)*1000) '.prof'],'w+');
        fprintf(fid, sprintf('   %.5f   \t%.5f\r\n',prof));
        fclose(fid);
    end
end

% height = 100:-10:50;
% hpr = 84.0;
% betta = 0.40;
% Ne = 1.43*1e7*exp(-0.15*hpr)*exp((betta-0.15)*(height-hpr))