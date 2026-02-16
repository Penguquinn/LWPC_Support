%% build_LWPM_mex.m
clc;
disp('=== Starting LWPM MEX build using MATLAB MEX compiler ===');

%% =========================
%% 0. Paths
%% =========================
rootDir     = pwd;
libDir      = fullfile(rootDir,'library');
dataDir     = fullfile(rootDir,'data');
includeDir  = fullfile(rootDir,'include');
wrapperC    = fullfile(rootDir,'wrapper.c');        % your C wrapper
wrapperF    = fullfile(rootDir,'lwpm_c_wrapper.f90'); % Fortran wrapper
lwpmFor     = fullfile(rootDir,'lwpm.f');         % main LWPM driver

%% =========================
%% 1. Gather Fortran sources
%% =========================
libForFiles = dir(fullfile(libDir,'*.f'));
libF90Files = dir(fullfile(libDir,'*.f90'));
libFiles = [libForFiles; libF90Files];
libFiles = fullfile({libFiles.folder}, {libFiles.name});

% Exclude wrapper itself if inside library folder
libFiles = setdiff(libFiles, {wrapperF}, 'stable');

%% =========================
%% 2. Compile library objects
%% =========================
disp('Compiling library Fortran sources...');
libObjFiles = {};
for k = 1:length(libFiles)
    src = libFiles{k};
    [~, name, ext] = fileparts(src);
    objFile = fullfile(rootDir,[name,'.obj']);
    fprintf('Compiling %s -> %s\n', src, objFile);

    if strcmp(ext,'.for')
        % MATLAB MEX doesn't recognize .for directly; treat as Fortran
        mex('-c','-fcompiler','gfortran',src,['-I',includeDir]);
    else
        mex('-c',src,['-I',includeDir]);
    end
    
    libObjFiles{end+1} = objFile;
end

%% =========================
%% 3. Compile lwpm Fortran wrapper
%% =========================
disp('Compiling Fortran wrapper...');
[~, name, ~] = fileparts(wrapperF);
wrapperObj = fullfile(rootDir,[name,'.obj']);
mex('-c',wrapperF,['-I',includeDir]);

%% =========================
%% 4. Compile main LWPM driver
%% =========================
disp('Compiling main LWPM Fortran file...');
[~, name, ~] = fileparts(lwpmFor);
lwpmObj = fullfile(rootDir,[name,'.obj']);
mex('-c',lwpmFor,['-I',includeDir]);

%% =========================
%% 5. Compile C wrapper
%% =========================
disp('Compiling C wrapper...');
[~, name, ~] = fileparts(wrapperC);
wrapperCObj = fullfile(rootDir,[name,'.obj']);
mex('-c',wrapperC,['-I',includeDir]);

%% =========================
%% 6. Link all objects into MEX
%% =========================
disp('Linking all objects into MEX function LWPM...');
allObjs = [libObjFiles, {wrapperObj, lwpmObj, wrapperCObj}];

%mexCmd = ['mex -v ' strjoin(allObjs,' ') [' -I"' includeDir '" -output LWPM']];
%disp(['Running: ' mexCmd]);
%eval(mexCmd);
% bigString = allObjs{1};
% for ii = 2:numel(allObjs)
% bigString = [bigString, ', ', allObjs{ii}];
% end
mex( [rootDir,'/wrapper.obj'], [rootDir,'/lwpm.obj'], [rootDir,'/lwpm_c_wrapper.obj'], allObjs{:}, ...
    ['-I' includeDir], '-L C:\\ProgramData\\MATLAB\\SupportPackages\\R2025b\\3P.instrset\\mingw_w64.instrset\\lib\\gcc\\x86_64-w64-mingw32\\8.1.0\\', ...
    '-lgfortran','-lquadmath','-output', 'LWPM')

%% =========================
%% 7. Clean up object files
%% =========================
disp('Cleaning up intermediate object files...');
delete(allObjs{:});

disp('=== LWPM MEX build complete! ===');
