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

%setenv("LWPC_DAT_LOC",'/home/quinn/work/v3.0.1/data')
cmd = sprintf([ ...
    'set LWPC_DAT_LOC=C:\\LWPCwin\\data\\ && '...
    'cd C:\\LWPCwin\\ &&' ...
    '.\\lwpm.exe ./%s"' ], file);
%[status, cmdout] = system('wsl bash -lc "echo $LWPC_DAT_LOC"')
[status, cmdout] = system(cmd);
end