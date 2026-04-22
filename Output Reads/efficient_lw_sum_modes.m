% This script will copy the utility of the Fortran LW_SUM_MODES subroutine

function [aa,pp] = efficient_lw_sum_modes(power, rho_full,data,eigens,Amk)
%{

Inputs are currently loaded from a file. All necessary inputs are as
follows:
    rho_full : a vector of all distances we desire the field values at. Can be
spaced in a non-uniform manner, although no one really wants that.
    k : relevant radians/km value
    f : frequency
    power : power of signal emitted, usually just 1
    eigens : cell array of vectors of eigenangles for each mode in each
slab
    T1 : array of excitations for each mode in each slab. Only 1st used 
%}

dtr = pi/180;   %change degrees to radians in eigenangle formulas
rtd = 180/pi;



[rho, sigma, epsr, eigen, ht, ...
          Ex_mag, Ex_ang, Ey_mag, Ey_ang, Ez_mag, Ez_ang, ...
          Hx_mag, Hx_ang, Hy_mag, Hy_ang, Hz_mag, Hz_ang, ...
          fofr, T1, T2, T3, T4, k, f, a] = unpackData(data);

for nc = 1:6

switch nc
    case 1
        fieldmag = Ez_mag;
        fieldang = Ez_ang;
    case 2
        fieldmag = Ey_mag;
        fieldang = Ey_ang;
    case 3
        fieldmag = Ex_mag;
        fieldang = Ex_ang;
    case 4
        fieldmag = Hz_mag;
        fieldang = Hz_ang;
    case 5
        fieldmag = Hy_mag;
        fieldang = Hy_ang;
    case 6
        fieldmag = Hx_mag;
        fieldang = Hx_ang;
end



mik = complex(0,-k);
sum0=682.2408*sqrt(f*power);
const = sum0;



xone = 0;

if length(rho)>1
    xtwo = rho(2);
else
    xtwo = dst;
end


nsgmnt = 1; %starting in the first slab

nreigen2 = length(eigens{1});  % Number of modes in the first slab

for neigen = 1:nreigen2        % For each of these modes
    tp(neigen) = eigens{1}(neigen);     % This variable is the eigenangles of the first slab
    stp(neigen) = sin(tp(neigen).*dtr); % This is the sine of the eigenangles of the first slab; (S)ine of (T)heta (P)?
    xtra(1,neigen) = -T1(1,neigen).*stp(neigen); % For each mode these are also calculated
end

rho_index = 1;
dst = rho_full(rho_index);

while dst <= xtwo

    for m2 = 1:nreigen2         % Still number of modes in the first slab
        ta = xtra(1,m2);        % ta = -T1[1, mode] * stp[mode]
        soln_a(m2) = ta;        % soln_a[mode] = ^^^ same thing ig?
        tb = -ta;               % Straightforward
    
        % For each mode, first height and first slab of field value is used
        % Also, the extra dimension on this seems to be unnecessary, as it is
        % only used as a 1xn matrix.
        soln_b(1,m2) = tb .* fieldmag(1, 1, m2) .* exp(sqrt(-1) .* fieldang(1, 1, m2));
    end

    [aa(rho_index, nc), pp(rho_index, nc)] = util_sum_modes(dst, xone, a, soln_b, nreigen2, const, mik, stp);
    rho_index = rho_index + 1;
    dst = rho_full(rho_index);
end

while rho_index < size(rho_full, 2)     %passed the end of the slab
    mikx = mik*(xtwo-xone);  
    nreigen1 = nreigen2;     % nreigen1 is modes in first slab; after this it will update to further slabs
    for m1 = 1:nreigen1
        soln_a(m1) = soln_a(m1).*exp(mikx*(stp(m1)-1));
        temp(m1)   = soln_a(m1);
    end
    
    xone = xtwo;             % Beginning of 
    nsgmnt = nsgmnt + 1;     % Next slab

    if nsgmnt+1 > length(rho)
        xtwo = 10000;
    else
        xtwo = rho(nsgmnt+1);  % End of the current slab, start of next
    end

    nreigen2 = length(eigens{nsgmnt}); % Modes in this slab
    
    for neigen = 1:nreigen2            % Modes in this slab
        tp(neigen) = eigens{nsgmnt}(neigen);  % tp is all of the eigenangles in this slab
        stp(neigen) = sin(tp(neigen) .* dtr); % sine of that ^^
        eyhy(neigen) = fofr(nsgmnt, neigen);  % this is just the relevant fofr vals
    end

    [nreigen2, nreigen1] = size(Amk{nsgmnt}); %added to correct for dropped modes

    % ^^^ This line just gets the number of modes in each slab again ^^^

    for m2 = 1:nreigen2       % For modes in current slab
        soln_a(m2) = 0;       % clear
        for m1=1:nreigen1     % For modes in prev slab:
            % Add all prev mode vals * conversion factors to this mode
            soln_a(m2) = soln_a(m2) + temp(m1) * Amk{nsgmnt}(m2,m1);
        end

        ta = soln_a(m2); % Put it here
        tb = -ta;
        soln_b(1,m2) = tb .* fieldmag(1, nsgmnt, m2) .* exp(sqrt(-1) .* fieldang(1, nsgmnt, m2));
    end

    while dst <= xtwo && rho_index < size(rho_full, 2)
    [aa(rho_index, nc), pp(rho_index, nc)] = util_sum_modes(dst, xone, a, soln_b, nreigen2, const, mik, stp);
    rho_index = rho_index + 1;
    dst = rho_full(rho_index);
    end
end

[aa(rho_index, nc), pp(rho_index, nc)] = util_sum_modes(dst, xone, a, soln_b, nreigen2, const, mik, stp);

end
end








function [rho, sigma, epsr, eigen, ht, ...
          Ex_mag, Ex_ang, Ey_mag, Ey_ang, Ez_mag, Ez_ang, ...
          Hx_mag, Hx_ang, Hy_mag, Hy_ang, Hz_mag, Hz_ang, ...
          fofr, T1, T2, T3, T4, k, f, a] = unpackData(data)
%UNPACKDATA Unpack all fields from a data struct into individual variables

rho    = data.rho;
sigma = data.sigma;
epsr  = data.epsr;
eigen = data.eigen;

ht = data.ht;

Ex_mag = data.Ex_mag;
Ex_ang = data.Ex_ang;
Ey_mag = data.Ey_mag;
Ey_ang = data.Ey_ang;
Ez_mag = data.Ez_mag;
Ez_ang = data.Ez_ang;

Hx_mag = data.Hx_mag;
Hx_ang = data.Hx_ang;
Hy_mag = data.Hy_mag;
Hy_ang = data.Hy_ang;
Hz_mag = data.Hz_mag;
Hz_ang = data.Hz_ang;

fofr = data.fofr;

T1 = data.T1;
T2 = data.T2;
T3 = data.T3;
T4 = data.T4;

k   = data.k;
f   = data.f;
a   = data.a;

end


