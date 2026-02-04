% Number of files
paths = '\\wsl.localhost\Ubuntu-24.04\home\quinn\work\v3.0.1';
numFiles = 10;

% Filenames
for ii = 1:numFiles
    filenames{ii} = sprintf('File%d',ii);
    TXdata{ii} = sprintf('TX%d',ii);
end

% Receiver positions
RX = repmat([100],[numFiles,1]);

% Maximum range
RNG = 5000;

% Call the MEX function
tic
err = fileMake(numFiles, filenames, TXdata, RX, RNG,char(paths));
toc

tic
printfiles(numFiles, filenames, TXdata, RX, RNG,paths)
toc
% Check if there was an error
if err
    disp('Some files could not be written!');
else
    disp('All files written successfully.');
end
