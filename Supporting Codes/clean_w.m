function clean_w(in)
%CLEAN_W Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    in
end

system('cd C:\\LWPCwin\\ && del *.lwf *.mds ');

if in ~= 0
system('cd C:\\LWPCwin\\ && del *.lwf *.mds *.log *.prf *.inp');
end
%system('wsl.exe bash -lc "cd ~/work/LWPC/LWPCv21/output && find . -type f -not -name ".ignore" -delete"');

end