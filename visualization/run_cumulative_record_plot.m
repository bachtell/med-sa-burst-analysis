clc;
clear;

%% Select Files

[fileNames, pathName] = uigetfile( ...
    '*.txt', ...
    'Select Med-PC Files', ...
    'MultiSelect', 'on');

if isequal(fileNames,0)

    disp('No files selected.');
    return;

end

if ischar(fileNames)

    fileNames = {fileNames};

end

cd(pathName);

%% Separate Session Files

LgA1_files = [];
LgA10_files = [];

for i = 1:length(fileNames)

    filename = fileNames{i};

    upperName = upper(filename);

    if contains(upperName, 'LGA10')

        LgA10_files = [LgA10_files; dir(filename)];

    elseif contains(upperName, 'LGA1')

        LgA1_files = [LgA1_files; dir(filename)];

    end

end

%% Representative Subjects

repSubjects = {'RAT3'};

%% Package Session Files

sessionFiles = {
    LgA1_files, ...
    LgA10_files
    };

%% Run Plotting Function

plot_cumulative_records( ...
    pathName, ...
    repSubjects, ...
    sessionFiles, ...
    'Representative_Cumulative_Records.png');

disp('Cumulative record plots complete.');