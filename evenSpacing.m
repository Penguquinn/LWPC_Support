function [avgReplicability,pval] = evenSpacing(mag,numSamples)
%EVENSPACING Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    mag
    numSamples
end

arguments (Output)
    avgReplicability
    pval
end

trueSamp = length(mag);
samp = linspace(1,trueSamp,numSamples);
samp = round(samp);

newData = mag(samp);
newData = interp1(samp,newData,1:trueSamp);
[avgReplicability,pval] = corrcoef(newData,mag);

end