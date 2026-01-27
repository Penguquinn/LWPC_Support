function [outputArg1] = cleanup()
%CLEANUP Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)

end

arguments (Output)
    outputArg1
end

system('wsl.exe bash -lc "cd ~/work/LWPC/LWPCv21/input && find . -type f -delete"');
system('wsl.exe bash -lc "cd ~/work/LWPC/LWPCv21/output && find . -type f -not -name ".ignore" -delete"');
outputArg1 = 1;
end