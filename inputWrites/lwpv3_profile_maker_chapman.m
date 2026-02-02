function filenames = lwpv3_profile_maker_chapman()

save_path = '\\wsl.localhost\Ubuntu-24.04\home\quinn\work\v3.0.1\profile\';
h = 50:5:100;

% h_0 = 90:150;
% logno = 5:10; %log of electron density at reference height
% H = 5:25;
h_0 = 90:0.5:150;
logno = 8; %log of electron density at reference height
H = 5:0.2:25;

%exponential slope for lower atmosphere
m=2.5/20;
b=-12.7;
dest1 = m*h+b;

for nn=1:length(logno)
    for hh=1:length(h_0)
        for ss=1:length(H)
            h = 50:5:100;
            basename = sprintf('%04.fn%03.fs%03.f',h_0(hh)*10,logno(nn)*10,H(ss)*10);
            filenames{nn,hh,ss} = basename;
            N_0 = exp(logno(nn));
            z = (h-h_0(hh))./H(ss);
            N = N_0.*exp(0.5.*(1-z-exp(-z)));
            en = N+exp(dest1);
            
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
end