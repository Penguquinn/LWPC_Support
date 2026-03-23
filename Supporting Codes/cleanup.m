function [outputArg1] = cleanup(in)
%CLEANUP Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    in
end

arguments (Output)
    outputArg1
end

system('wsl.exe bash -lc "cd ~/work/v3.0.1 && find *.mds -type f -delete"');
system('wsl.exe bash -lc "cd ~/work/v3.0.1 && find *.lwf -type f -delete"');

if in ~= 0
system('wsl.exe bash -lc "cd ~/work/v3.0.1 && find *.log -type f -delete"');
%system('wsl.exe bash -lc "cd ~/work/v3.0.1 && find *.inp -type f -delete"');
%system('wsl.exe bash -lc "cd ~/work/v3.0.1/profile && find *.prf -type f -delete"');
end
%system('wsl.exe bash -lc "cd ~/work/LWPC/LWPCv21/output && find . -type f -not -name ".ignore" -delete"');
outputArg1 = 1;
end