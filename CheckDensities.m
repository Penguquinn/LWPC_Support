hprime = 65:1:80;
beta = .3:.1:0.6;
h_0 = 100:10:120;

for hh = 1:numel(hprime)
    for bb = 1:numel(beta)


for tt = 1:numel(h_0)
%% exponential section
        h = [20:5:75 77:2:120];
%         hprime = 70:2:90;
%         beta = 0.4:0.02:0.6;
        en = 1.43*1e7*exp(-0.15*hprime(n))*exp((beta(m)-0.15)*(h-hprime(n)));
        en = [0 0 en];
        en = fliplr(en);



%% chapman density section
h = h_0(tt)-20 :2 : h_0(tt)+4;
% h(h>h_0(tt)) = [];
if hprime(hh) >= h_0(tt)
    continue
end
basename = sprintf('%03.fb%03.fh%04.f',hprime(hh)*10,beta(bb)*1000,h_0(tt)*10);
filenames{hh,bb,tt} = basename;

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


end
    end
end