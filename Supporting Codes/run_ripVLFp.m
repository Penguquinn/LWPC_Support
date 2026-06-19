%user defined input parameters
Fs = 100e3;  %broadband sampling frequency in Hz
filepath = '/home/new-ece/hcb0003/Documents/Research/HAARP/HAARP_Data/PARS24_Quinn/';         %filepath to broadband data
outputpath = '/home/new-ece/hcb0003/Documents/Research/HAARP/HAARP_Data/nb_polarization/';   %filepath to narrowband output

% Fs_nb = 50;     %narrowband output sampling frequency in Hz
% txname = 'NLK'; %name of narrowband transmitter
% Fc = 24.8e3;    %transmitter center frequency in Hz

% ripVLFp_function(Fs, Fs_nb, txname,Fc,filepath,outputpath)


% Fs_nbs = [1,50];
% txnames = [{'NAA'};{'NLM'};{'NLK'};{'NPM'}];
% Fcs = [24.0e3 25.2e3 24.75e3 21.4e3];
% 
% for n = 1:length(Fs_nbs)
%     Fs_nb = Fs_nbs(n);
%     for m = 1:length(txnames)
%         txname = txnames{m};
%         Fc = Fcs(m);
%         ripVLFp_function(Fs, Fs_nb, txname,Fc,filepath,outputpath);
%     end
% end

Fs_nbs = [1,50];
txnames = [{'NLK'}];
Fcs = [24.8e3];

for n = 1:length(Fs_nbs)
    Fs_nb = Fs_nbs(n);
    for m = 1:length(txnames)
        txname = txnames{m};
        Fc = Fcs(m);
        ripVLFp_function(Fs, Fs_nb, txname,Fc,filepath,outputpath);
    end
end