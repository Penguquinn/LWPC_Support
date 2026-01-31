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

cmd = sprintf([ ...
    'wsl.exe bash -lc "cd ~/work/v3.0.1 && ' ...
    'bash setdat.sh && ' ...
    'echo $LWPC_DAT_LOC && ' ...
    './lwpm ./%s"' ], file);

[status, cmdout] = system(cmd);
end