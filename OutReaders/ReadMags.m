fid = fopen("C:\Users\quinn\OneDrive\Desktop\temp.txt");
fin = [];
while(~feof(fid))
    line = fgetl(fid);
    arr = sscanf(line, '%f');
    fin = [fin,reshape(arr,3,[])];
end
[dist,idx] = sort(fin(1,:));
mag = fin(2,idx);
phase = fin(3,idx);
fclose(fid);


plot(dist,mag)
figure;
plot(dist,phase)
figure;
savedCorrs = [];
ii = 0;
xaxis = [];
for numSamples = 550:-1:3
    ii = ii+1;
    [xx,yy] = evenSpacing(mag,numSamples);
    savedCorrs(ii) = xx(2);
    sp = yy;
    xaxis(ii) = 11000/numSamples;
end

errorbar(xaxis,savedCorrs,sp)
xlabel('Sample Rate (km)');
ylabel('Correlation Value');
title('Correlation of Reconstructed Signal to True Signal with Spatial Sample Rate');
grid on;