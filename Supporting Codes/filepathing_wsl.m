function [pathToData] = filepathing_wsl()
%FILEPATHING Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    
end

arguments (Output)
    pathToData
end

    name = string(java.net.InetAddress.getLocalHost().getHostName());
    if name == "Penguin"
        pathToData = '\\wsl.localhost\Ubuntu-24.04\home\quinn\work\v3.0.1\';
    elseif name == "elec32"
        %pathToData = '\\wsl.localhost\Ubuntu\home\qdh0004\work\LWPC\LWPCv21\';
        pathToData = '\\wsl.localhost\Ubuntu\home\qdh0004\work\v3.0.1\';
    else
        return
    end

end