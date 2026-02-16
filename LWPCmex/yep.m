%% Auto-detect MSVC and configure mex for C
clc;

% Step 1: Detect Visual Studio installations via vswhere
vswherePath = fullfile('C:\', 'Program Files (x86)', 'Microsoft Visual Studio', 'Installer', 'vswhere.exe');
if ~isfile(vswherePath)
    error('vswhere.exe not found. Install Visual Studio Installer or download vswhere from Microsoft.');
end

[status, cmdout] = system(['"', vswherePath, '" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath']);
if status ~= 0 || isempty(cmdout)
    error('No compatible Visual Studio with MSVC found.');
end

vsPath = strtrim(cmdout);

% Step 2: Locate MSVC bin folder
msvcDir = dir(fullfile(vsPath, 'VC', 'Tools', 'MSVC', '*'));
if isempty(msvcDir)
    error('MSVC folder not found under Visual Studio installation.');
end

% Take the latest version installed
msvcVersion = msvcDir(end).name;
binPath = fullfile(vsPath, 'VC', 'Tools', 'MSVC', msvcVersion, 'bin', 'Hostx64', 'x64');

if ~isfolder(binPath)
    error('MSVC x64 bin folder not found.');
end

fprintf('Detected MSVC path:\n%s\n', binPath);

% Step 3: Update MATLAB environment temporarily
setenv('PATH', [binPath ';' getenv('PATH')]);

% Step 4: Setup mex for C
try
    mex('-setup', 'C');
    fprintf('MEX C setup completed successfully!\n');
catch ME
    fprintf('Error configuring mex for C:\n%s\n', ME.message);
end
