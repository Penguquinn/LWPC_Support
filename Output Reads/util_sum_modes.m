function [aa, pp] = util_sum_modes(dst, xone, a, soln_b, nreigen2, const, mik, stp)

mikx = mik*(dst-xone);
factor = const / sqrt(abs(sin(dst / a)));
tb = 0;

for m2 = 1:nreigen2   % modes in the slab our dst lies in
    tb = tb + soln_b(1,m2) * exp(mikx * (stp(m2) - 1)) * factor;
end

aa = 20*log10(abs(tb));

phs2 = angle(tb)*180/pi();

cycle = 0;
if abs(phs2)>180
    if 0 < phs2
        cycle = -360;
    else
        cycle = 360;
    end
end

pp = phs2+cycle;


if dst == 0
    aa = 20*log10(const*80);
    pp = 0;
end
end
