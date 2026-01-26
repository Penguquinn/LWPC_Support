function build_mex_cmake()
% Automated CMake-based Fortran MEX build
% --------------------------------------

root = pwd;
srcdir = fullfile(root,'src');
cmakedir = fullfile(root,'cmake');
builddir = fullfile(root,'build');

mkdir_if_missing(srcdir);
mkdir_if_missing(cmakedir);
mkdir_if_missing(builddir);

%% ------------------------------------------------------------------------
% Example project layout (adjust to your real sources)
%
% src/
%   common/
%     numerics.f90
%     utils.f90
%   mex/
%     mex_func1.f90
%     mex_func2.f90
%% ------------------------------------------------------------------------

mkdir_if_missing(fullfile(srcdir,'common'));
mkdir_if_missing(fullfile(srcdir,'mex'));

%% ------------------------------------------------------------------------
% Write top-level CMakeLists.txt
%% ------------------------------------------------------------------------
write_file(fullfile(srcdir,'CMakeLists.txt'), ...
[ ...
"cmake_minimum_required(VERSION 3.20)", newline, ...
"project(mex_fortran LANGUAGES Fortran)", newline, newline, ...
"find_package(Matlab REQUIRED COMPONENTS MEX)", newline, newline, ...
"set(CMAKE_POSITION_INDEPENDENT_CODE ON)", newline, newline, ...
"add_compile_options(-O3 -fopenmp)", newline, ...
"add_link_options(-fopenmp)", newline, newline, ...
"add_subdirectory(src)", newline ...
]);

%% ------------------------------------------------------------------------
% Write src/CMakeLists.txt
%% ------------------------------------------------------------------------
write_file(fullfile(srcdir,'CMakeLists.txt'), ...
[ ...
"add_subdirectory(common)", newline, ...
"add_subdirectory(mex)", newline ...
]);

%% ------------------------------------------------------------------------
% Write common library CMakeLists.txt
%% ------------------------------------------------------------------------
write_file(fullfile(srcdir,'common','CMakeLists.txt'), ...
[ ...
"add_library(fortran_common STATIC", newline, ...
"    numerics.f90", newline, ...
"    utils.f90", newline, ...
")", newline ...
]);

%% ------------------------------------------------------------------------
% Write reusable MEX macro
%% ------------------------------------------------------------------------
write_file(fullfile(cmakedir,'AddMexFortran.cmake'), ...
[ ...
"function(add_mex_fortran target source)", newline, ...
"    add_library(${target} MODULE ${source})", newline, newline, ...
"    set_target_properties(${target} PROPERTIES", newline, ...
"        PREFIX ", newline, ...
'        SUFFIX ".mexa64"', newline, ...
"    )", newline, newline, ...
"    target_link_libraries(${target}", newline, ...
"        PRIVATE fortran_common Matlab::MEX", newline, ...
"    )", newline, ...
"endfunction()", newline ...
]);

%% ------------------------------------------------------------------------
% Write mex/CMakeLists.txt (auto-discovery)
%% ------------------------------------------------------------------------
write_file(fullfile(srcdir,'mex','CMakeLists.txt'), ...
[ ...
"include($${CMAKE_SOURCE_DIR}/cmake/AddMexFortran.cmake)", newline, newline, ...
"file(GLOB MEX_SOURCES ""*.f90"")", newline, newline, ...
"foreach(src $${MEX_SOURCES})", newline, ...
"    get_filename_component(name $${src} NAME_WE)", newline, ...
"    add_mex_fortran($${name} $${src})", newline, ...
"endforeach()", newline ...
]);

%% ------------------------------------------------------------------------
% Run CMake configure + build
%% ------------------------------------------------------------------------
cd(builddir)

if ispc
    cmake_cmd = 'cmake ..';
    build_cmd = 'cmake --build . --parallel';
else
    cmake_cmd = 'cmake ..';
    build_cmd = 'cmake --build . --parallel';
end

[status, out] = system(cmake_cmd);

if status ~= 0
    cd ..\
    fprintf(2, '\n===== CMake configure output =====\n');
    fprintf(2, '%s\n', out);
    error('CMake configuration failed');
end

status = system(build_cmd);
assert(status==0,'Build failed')

cd(root)
fprintf('MEX build complete.\n')

end

% ========================================================================
function mkdir_if_missing(d)
if ~exist(d,'dir')
    mkdir(d);
end
end

function write_file(fname, txt)
fid = fopen(fname,'w');
assert(fid>0,'Cannot open %s',fname)
fprintf(fid,'%s', txt);
fclose(fid);
end
