%% build command strings and get set
rt = java.lang.Runtime.getRuntime();
pr = rt.exec('wsl.exe rm -f /home/qdh0004/git_repos/LWPC/build/*.mds');
pr.waitFor();
pr.destroy();







%% use java runtime to execute wsl commands in powershell

tic
cmd = sprintf([ ...
    'wsl.exe bash -lc "cd ~/work/v3.0.1 && ' ...
    'export LWPC_DAT_LOC="/home/qdh0004/work/v3.0.1/data/" && ' ...
    './lwpm ./%s"' ], file);

pr = rt.exec(cmd);

stderr = java.io.BufferedReader(java.io.InputStreamReader(pr.getErrorStream()));
line = stderr.readLine();

disp(line)

pr.waitFor();
pr.destroy();
toc