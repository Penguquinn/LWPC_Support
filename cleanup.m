function [outputArg1] = cleanup()
%CLEANUP Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)

end

arguments (Output)
    outputArg1
end

system('wsl.exe bash -lc "cd ~/work/v3.0.1 && find *.mds -type f -delete"');
system('wsl.exe bash -lc "cd ~/work/v3.0.1 && find *.lwf -type f -delete"');
%system('wsl.exe bash -lc "cd ~/work/v3.0.1 && find *.log -type f -delete"');
%system('wsl.exe bash -lc "cd ~/work/LWPC/LWPCv21/output && find . -type f -not -name ".ignore" -delete"');
outputArg1 = 1;
end