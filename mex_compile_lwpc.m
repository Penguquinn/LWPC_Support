%% build_LWPM_mex.m
% MATLAB build script for LWPM MEX function
% Replicates the behavior of your Intel Makefile

clc;
disp('Starting LWPM MEX build...');

%% Paths
includeDir = '.\include';
libraryDir = '.\library';
dataDir    = '.\data';

%% Source files
fortranSrc1 = 'lwpm.for';
fortranSrc2 = 'lwpm_c_wrapper.f90';
cWrapper    = 'wrapper.c';

%% Object files
obj1 = 'lwpm.obj';
obj2 = 'lwpm_c_wrapper.obj';

%% Fortran compilation flags (Intel Fortran)
FOPT   = '/O3 /QxHost';
FFLAGS = [FOPT ' /warn:none /Qsave /Qinit:zero /I' includeDir ' /fixed /extend-source:132'];

%% C compilation flags (Intel C)
CFLAGS = ['/O3 /I' includeDir];

%% ----------------------
%% 1. Compile Fortran objects
%% ----------------------
disp('Compiling Fortran sources...');
status1 = system(['ifx /c ' FFLAGS ' ' fortranSrc1]);
if status1 ~= 0
    error('Failed to compile %s', fortranSrc1);
end

status2 = system(['ifx /c /O3 /QxHost /warn:nounused /warn:nointerfaces /Qsave /Qinit:zero /I' includeDir ' ' fortranSrc2]);
if status2 ~= 0
    error('Failed to compile %s', fortranSrc2);
end

%% ----------------------
%% 2. Build library (optional)
%% ----------------------
disp('Building library...');
libFile = fullfile(libraryDir, 'lwpc.lib');
if ~isfile(libFile)
    warning('Library lwpc.lib not found in %s. Make sure it exists.', libraryDir);
end

%% ----------------------
%% 3. Compile MEX
%% ----------------------
disp('Compiling MEX function...');
mexCmd = ['mex ', cWrapper, ' ', obj1, ' ', obj2, ' ', libFile, ' -I', includeDir];

disp(['Running: ', mexCmd]);
eval(mexCmd);

disp('LWPM MEX build complete!');
