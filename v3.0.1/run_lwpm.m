function [rng, amp, phs] = run_lwpm(f, h, b, txname, rxlat, rxlon)
% function [rng, amp, phs] = run_lwpm(f, h, b, txname, rxlat, rxlon)
cmdstr = sprintf('python run_lwpm.py %.6f %.6f %.6f %3s %.3f %.3f', f, h, b, txname, rxlat, rxlon);

% disp(cmdstr);

[stat, outp] = system(cmdstr);
m = 0;
if stat == 0
  s = char(strsplit(outp, '\n'));
  [m, n] = size(s);
end
if m > 3 && s(1,1) ~= '!'
  for i = 1:m
    x = sscanf(s(i, :), '%f %f %f');
    if(length(x) == 3)
      rng(i) = x(1);
      amp(i) = x(2);
      phs(i) = x(3);
    end
  end
else
  rng = [];
  amp = [];
  phs = [];
end

