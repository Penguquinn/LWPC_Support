% function [squishedCell] = squish_output(file)
file = "\\wsl.localhost\Ubuntu\home\qdh0004\git_repos\LWPC\LWPCv21\bearings.log";
%doc = fopen(file);
doc = fileread(file);
doc = splitlines(doc);

lins = zeros(numel(doc)-1,1);

for ii = 1:numel(doc)-1
    lins(ii) = ~(numel(doc{ii})<=4) && (doc{ii}(1:4)=="  di");
end
lins = find(lins==1)+1;
numCel = numel(lins);
% this next line does not expand to more than 2 lists
lins = [lins(1),lins(2)-5,lins(2),numel(doc)-1];

for ii = 0:numCel-1
    inc = 0;
    for jj = lins((2*ii)+1):lins((2*ii)+2)
        inc = inc+1;
        vals(inc,:) = cell2mat(textscan(doc{jj}(:), '%f %f %f %f %f %f %f %f %f'));
    end
    vals = shapeify(vals);
    [vals(:,1),I] = sort(vals(:,1));
    vals(:,2) = vals(I,2);
    vals(:,3) = vals(I,3);
    squishedCell{ii+1} = vals;
    clearvars vals;
end


% end

function shaped = shapeify(matIn)
    
    len = size(matIn);
    shaped = zeros(3*len(1),3);
    for ii = 1:len(1)
       shaped(ii,1:3) = matIn(ii,1:3);
       shaped(ii+len(1),1:3) = matIn(ii,4:6); 
       shaped(ii+(2*len(1)),1:3) = matIn(ii,7:9);
    end


end