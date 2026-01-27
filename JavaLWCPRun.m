%% build command strings and get set
rt = java.lang.Runtime.getRuntime();
pr = rt.exec('wsl.exe rm -f /home/qdh0004/git_repos/LWPC/build/*.mds');
pr.waitFor();
pr.destroy();







%% use java runtime to execute wsl commands in powershell

tic
command = 'wsl -e bash -c "cd /home/qdh0004/git_repos/LWPC/build/ && ./lwpc.bin ../LWPCv21/bearings';

pr = rt.exec(command);

stderr = java.io.BufferedReader(java.io.InputStreamReader(pr.getErrorStream()));
line = stderr.readLine();

disp(line)

pr.waitFor();
pr.destroy();
toc