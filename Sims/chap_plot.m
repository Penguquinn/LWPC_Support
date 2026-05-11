% nu = 5e6*exp(-0.15*(h-70));
% wr = qe^2/eps0/me*en*100^3./nu;

hprime = 60:1:90;
beta = 0.3;
h_0 = 85;


qe = 1.602176634e-19; %C
eps0 = 8.8541878128e-12; %F/m
me = 9.1093837015e-31; %kg
wrprime = 2.5e5;



for hh=1:length(hprime)
    for bb=1:length(beta)
        for tt=1:length(h_0)
            h = 20:2:200;
            
            basename = sprintf('%03.fb%03.fh%04.f',hprime(hh)*10,beta(bb)*1000,h_0(tt)*10);
            filenames{hh,bb,tt} = basename;
            
            %calculate N_0 and H based on the given values
            Htest = 5:.01:25;
            betatest = (0.5./Htest).*(exp(-((hprime(hh)-h_0(tt))./Htest))-1);
            [~,betaind] = min(abs(betatest-beta(bb)));
%             betaind = find(betatest-beta(bb) ==  min(abs(betatest-beta(bb))));
            H = Htest(betaind);
            % H = 1/beta(bb);
            
            nuprime = 5e6*exp(-0.15*(hprime(hh)-70));
            enprime = wrprime*nuprime*eps0*me./(qe.^2)./100.^3; %electron density at the reflection height in cm^-3
            
            zprime = (hprime(hh)-h_0(tt))./(H);
            N_0 = enprime*exp(-0.5*(1-zprime-exp(-zprime)));
        
            z = (h-h_0(tt))./H;
            en = N_0.*exp(0.5.*(1-z-exp(-z)));

            plot(h,en)
            title(['hprime ' num2str(hprime(hh)) 'Beta ' num2str(beta(bb)) 'h0 ' num2str(h_0(tt))])
            pause(1)
        end
    end
end

