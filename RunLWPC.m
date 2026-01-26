function [status,cmdout] = RunLWPC(file)
%RUNLWPC Summary of this function goes here
%   Given a filename in the input section of lwpcv21 run it and return the
%   commandline output for debugging purposes
arguments (Input)
    file
end

arguments (Output)
    status
    cmdout
end

[status, cmdout] = system( ...
    ['wsl.exe bash -lc "cd ~/work/LWPC/build && ./lwpc.bin ../LWPCv21/input/' file '"'] );
end