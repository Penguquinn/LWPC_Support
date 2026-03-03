file = "\\wsl.localhost\Ubuntu\home\qdh0004\git_repos\LWPC\LWPCv21\bearings.log";
%doc = fopen(file);
doc = fileread(file);
doc = splitlines(doc);

% lins = zeros(numel(doc)-1,1);

for ii = 1:numel(doc)-1
    lins(ii) = ~(numel(doc{ii})<=4) && (doc{ii}(1:4)=="  di");
    line(ii) = ~(numel(doc{ii})<=4) && (doc{ii}(1:4)=="nc n");
end

start = find(lins==1);
stop = find(line==1);