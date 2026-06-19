%this code produces the Stokes polarization parameters for a user-defined
%narrowband VLF transmitter from broadband VLF data

%location of matGetVariable
% addpath C:\hcburch\MATLAB\Processing_Codes

clearvars

%user defined input parameters
Fs = 100e3;  %broadband sampling frequency in Hz
Fs_nb = 1;     %narrowband output sampling frequency in Hz
txname = 'TFK'; %name of narrowband transmitter
Fc = 37.5e3;    %transmitter center frequency in Hz
filepath = 'C:\VLF_data\AU\';         %filepath to broadband data
outputpath = 'C:\VLF_data\NB\AU_Pol\';   %filepath to narrowband output

%detect files at path location
files = dir(filepath);

%handle the first file first
n=3;
%interpret name code of the data file
name0 = files(n  ).name;
name1 = files(n+1).name;
site  = name0( 1:2 );
year  = name0( 3:4 );
month = name0( 5:6 );
day   = name0( 7:8 );
hour  = name0( 9:10);
minute= name0(11:12);
second= name0(13:14);
if strcmp(name0(1:end-8),name1(1:end-8)) && strcmp(name0(end-4),'0') && strcmp(name1(end-4),'1')
    bblength = matGetDataLength([filepath name0]); %length of the data file in seconds

    start_second = str2double(hour)*3600+str2double(minute)*60+str2double(second); %start time in seconds of bb file
    end_second = start_second + bblength;
    
    start_offset = mod(60-str2double(second),60);%start at the next minute
    if start_offset == 0 %if the broadband file starts on time the narrowband file has the same start time
        minute_nb = minute;
    else %if the bb file starts late the nb file starts on the next round minute
        minute_nb = num2str(str2double(minute)+1,'%02.f');
    end
    hour_nb = hour;
    second_nb = '00';
    name_nb = [site year month day hour minute_nb second_nb];

    offset = start_offset;
    
    %read in data from broadband file
    data_ns = matGetVariable([filepath name0],'data',60*Fs,offset*Fs);
    data_ew = matGetVariable([filepath name1],'data',60*Fs,offset*Fs);
    %calculate narrowband polarization
    [s0data,s1data,s2data,s3data]=nb_polarization(data_ns,data_ew,Fc,Fs,Fs_nb);
    
    %keep only the first 45s of the 60s long s0-3data
    s0 = s0data(1:45*Fs_nb);
    s1 = s1data(1:45*Fs_nb);
    s2 = s2data(1:45*Fs_nb);
    s3 = s3data(1:45*Fs_nb);

    for offset = start_offset+30:30:bblength-60
        fprintf('File %i/%i, %3.f%% complete\n',n-2,length(files)-2,offset/(bblength-60)*100)
        
        %read in data from broadband file
        data_ns = matGetVariable([filepath name0],'data',60*Fs,offset*Fs);
        data_ew = matGetVariable([filepath name1],'data',60*Fs,offset*Fs);
        %calculate narrowband polarization
        [s0data,s1data,s2data,s3data]=nb_polarization(data_ns,data_ew,Fc,Fs,Fs_nb);
    
        %keep only the middle 30s of the 60s long s0-3data
        s0 = [s0; s0data(1+15*Fs_nb:45*Fs_nb)];
        s1 = [s1; s1data(1+15*Fs_nb:45*Fs_nb)];
        s2 = [s2; s2data(1+15*Fs_nb:45*Fs_nb)];
        s3 = [s3; s3data(1+15*Fs_nb:45*Fs_nb)];
    end

    start_second_prev = start_second;
    end_second_prev = end_second;
else
    disp('Error: Unexpected file structure')
end


    
%handle the rest of the files
for n=5:2:length(files)-1
    %interpret the name code
    name0 = files(n  ).name;
    name1 = files(n+1).name;
    site  = name0( 1:2 );
    year  = name0( 3:4 );
    month = name0( 5:6 );
    day   = name0( 7:8 );
    hour  = name0( 9:10);
    minute= name0(11:12);
    second= name0(13:14);
    
    %make sure the files are what you think they are
    if strcmp(name0(1:end-8),name1(1:end-8)) && strcmp(name0(end-4),'0') && strcmp(name1(end-4),'1')
        bblength = matGetDataLength([filepath name0]); %length of the data file in seconds
        
        start_second = str2double(hour)*3600+str2double(minute)*60+str2double(second); %start time in seconds of bb file
        end_second = start_second + bblength;
        
        %two possible cases from here: the current file starts from the end
        %of the last file (end_second_prev = start_second) or there is a
        %gap between the end of the previous file and beginning of the
        %current file
        if end_second_prev == start_second
            %stitch together the last 30s of previous file with first 30s
            %of new file
            %read in data from broadband file using last offset from old
            %file
            name0 = files(n-2  ).name;
            name1 = files(n-1).name;
            data_ns_old = matGetVariable([filepath name0],'data',30*Fs,(offset+30)*Fs);
            data_ew_old = matGetVariable([filepath name1],'data',30*Fs,(offset+30)*Fs);
            %read in data from new file with zero offset
            name0 = files(n  ).name;
            name1 = files(n+1).name;
            data_ns_new = matGetVariable([filepath name0],'data',30*Fs,0);
            data_ew_new = matGetVariable([filepath name1],'data',30*Fs,0);
            
            data_ns = [data_ns_old; data_ns_new];
            data_ew = [data_ew_old; data_ew_new];
            [s0data,s1data,s2data,s3data]=nb_polarization(data_ns,data_ew,Fc,Fs,Fs_nb);
            
            %keep only the middle 30s of the 60s long s0-3data
            s0 = [s0; s0data(1+15*Fs_nb:45*Fs_nb)];
            s1 = [s1; s1data(1+15*Fs_nb:45*Fs_nb)];
            s2 = [s2; s2data(1+15*Fs_nb:45*Fs_nb)];
            s3 = [s3; s3data(1+15*Fs_nb:45*Fs_nb)];
            
            for offset = 0:30:bblength-60
                fprintf('File %i/%i, %3.f%% complete\n',n-2,length(files)-2,offset/(bblength-60)*100)

                %read in data from broadband file
                data_ns = matGetVariable([filepath name0],'data',60*Fs,offset*Fs);
                data_ew = matGetVariable([filepath name1],'data',60*Fs,offset*Fs);
                %calculate narrowband polarization
                [s0data,s1data,s2data,s3data]=nb_polarization(data_ns,data_ew,Fc,Fs,Fs_nb);

                %keep only the middle 30s of the 60s long s0-3data
                s0 = [s0; s0data(1+15*Fs_nb:45*Fs_nb)];
                s1 = [s1; s1data(1+15*Fs_nb:45*Fs_nb)];
                s2 = [s2; s2data(1+15*Fs_nb:45*Fs_nb)];
                s3 = [s3; s3data(1+15*Fs_nb:45*Fs_nb)];
            end
            
        else %there is a gap between files
            %save off the old file and start over
            save([outputpath name_nb txname '_' num2str(Fs_nb,'%03.f') '.mat'],...
                's0','s1','s2','s3','Fc','txname','Fs_nb',...
                'year','day','hour_nb','minute_nb','second_nb')
            
            start_offset = mod(60-str2double(second),60);%start at the next minute
            if start_offset == 0 %if the broadband file starts on time the narrowband file has the same start time
                minute_nb = minute;
            else %if the bb file starts late the nb file starts on the next round minute
                minute_nb = num2str(str2double(minute)+1,'%02.f');
            end
            hour_nb = hour;
            second_nb = '00';
            name_nb = [site year month day hour minute_nb second_nb];

            offset = start_offset;

            %read in data from broadband file
            data_ns = matGetVariable([filepath name0],'data',60*Fs,offset*Fs);
            data_ew = matGetVariable([filepath name1],'data',60*Fs,offset*Fs);
            %calculate narrowband polarization
            [s0data,s1data,s2data,s3data]=nb_polarization(data_ns,data_ew,Fc,Fs,Fs_nb);

            %keep only the first 45s of the 60s long s0-3data
            s0 = s0data(1:45*Fs_nb);
            s1 = s1data(1:45*Fs_nb);
            s2 = s2data(1:45*Fs_nb);
            s3 = s3data(1:45*Fs_nb);
        end
    else
    disp('Error: Unexpected file structure')
    end
    start_second_prev = start_second;
    end_second_prev = end_second;
end

save([outputpath name_nb txname '_' num2str(Fs_nb,'%03.f') '.mat'],...
                's0','s1','s2','s3','Fc','txname','Fs_nb',...
                'year','day','hour_nb','minute_nb','second_nb')

%--------------------------------------------------------------------------
% Local functions
%--------------------------------------------------------------------------

%this function processes 60s of broadband data and generates 60s of 
%narrowband polarization data at the sample rate of Fs_nb
function [s0data,s1data,s2data,s3data]=nb_polarization(data_ns,data_ew,Fc,Fs,Fs_nb)
    %calculate arrays needed for Fourier analysis
    t = (0:1/Fs:length(data_ns)/Fs - 1/Fs); %seconds
    f = 0:Fs/length(t):Fs-1/length(t); %Hz
    f0 = Fc; %Hz
    w0 = 2*pi*f0; %rad/s
    mixdown = exp(-sqrt(-1).*(w0.*t));

    %create low pass filter with passband set by fpass
    fpass = 200;  %Hz
    npts = 2000;    %try 5000, 10000, etc until noise is not affected
    b= fir1(npts-1,2*fpass/Fs,kaiser(npts,8));

    %remove sferics
    s = find(abs(data_ns-mean(data_ns))>4*std(data_ns));
    data_ns(s) = mean(data_ns);
    data_ew(s) = mean(data_ew);

    vlfdata = data_ns;
    %apply filter forwards/backwards
    baseband = vlfdata.*mixdown.';
    baseband_filt = fftfilt(b,baseband);
    baseband_filt = fftfilt(b,baseband_filt(end:-1:1));
    ns_filt = baseband_filt(end:-1:1);

    vlfdata = data_ew;
    %apply filter forwards/backwards
    baseband = vlfdata.*mixdown.';
    baseband_filt = fftfilt(b,baseband);
    baseband_filt = fftfilt(b,baseband_filt(end:-1:1));
    ew_filt = baseband_filt(end:-1:1);

    s0data = abs(ns_filt).^2 + abs(ew_filt).^2;
    s1data = abs(ns_filt).^2 - abs(ew_filt).^2;
    s2data = 2*real(ns_filt.*conj(ew_filt));
    s3data = 2*imag(ns_filt.*conj(ew_filt));

    s0data = downsample(movmean(s0data,2*Fs./Fs_nb),Fs./Fs_nb);
    s1data = downsample(movmean(s1data,2*Fs./Fs_nb),Fs./Fs_nb);
    s2data = downsample(movmean(s2data,2*Fs./Fs_nb),Fs./Fs_nb);
    s3data = downsample(movmean(s3data,2*Fs./Fs_nb),Fs./Fs_nb);
end

    