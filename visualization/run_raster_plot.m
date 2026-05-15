clc;
clear;

%% Select Med-PC Files
[fileNames, pathName] = uigetfile( ...
    '*.txt', ...
    'Select Med-PC Files', ...
    'MultiSelect', 'on');

% Exit if user cancels
if isequal(fileNames,0)
    disp('No files selected.');
    return;

end

% Convert single selection to cell array
if ischar(fileNames)
    fileNames = {fileNames};

end

cd(pathName);

%% Separate Session Files
LgA1_files = [];
LgA10_files = [];

for i = 1:length(fileNames)
    filename = fileNames{i};
    disp(filename)
    
    upperName = upper(filename);

    if contains(upperName, 'LGA10')

        LgA10_files = [LgA10_files; dir(filename)];

    elseif contains(upperName, 'LGA1')

        LgA1_files = [LgA1_files; dir(filename)];

    end

end

%% Check Required Files

if isempty(LgA1_files) || isempty(LgA10_files)
    error('Both LgA1 and LgA10 files must be selected.');

end

%% Representative Subjects

repSubjects = {'RAT3'};

%% Package Session Files

sessionFiles = {
    LgA10_files, ...
    LgA1_files
};

%% Run Raster Plot

plot_cumulative_raster( ...
    pathName, ...
    repSubjects, ...
    sessionFiles, ...
    'Representative_RasterPlots.png');

disp('Raster plot generation complete.');