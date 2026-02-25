function [pathToData] = filepathing()
%FILEPATHING Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    
end

arguments (Output)
    pathToData
end

    name = string(java.net.InetAddress.getLocalHost().getHostName());
    if name == "Penguin"
        pathToData = 'C:\Users\quinn\OneDrive\Desktop\Pars_25\Data\';
    elseif name == "elec32"
        pathToData = 'C:\Users\qdh0004\OneDrive - Auburn University\Desktop\Pars_25\Data\';
    else
        return
    end

end